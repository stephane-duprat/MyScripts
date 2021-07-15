-- Time columns in DBA_HIST_FILESTATXS are in cs (hundredths of a second) !!!
define bsnap=14061
define esnap=15532
define inum=1
define dbid=161623299

-- By datafile !!!
col filename format a52
set lines 140

select V.snap_id,
	V.filename, 
	10* (V.SINGLEBLKRDTIM / V.SINGLEBLKRDS) as "AvgSingleBlkReadTime (ms)",
	10* ((V.READTIM-V.SINGLEBLKRDTIM) / (V.PHYRDS-V.SINGLEBLKRDS)) as "AvgReadTime (ms)",
	10* (V.WRITETIM / V.PHYWRTS) as "AvgWrtTime (ms)"
from (
select ENDSNAP.SNAP_ID,
	ENDSNAP.FILENAME, 
	(ENDSNAP.PHYRDS - BEGSNAP.PHYRDS) as PHYRDS, 
	(ENDSNAP.PHYWRTS - BEGSNAP.PHYWRTS) as PHYWRTS, 
	(ENDSNAP.SINGLEBLKRDS - BEGSNAP.SINGLEBLKRDS) as SINGLEBLKRDS, 
	(ENDSNAP.READTIM - BEGSNAP.READTIM) as READTIM, 
	(ENDSNAP.WRITETIM - BEGSNAP.WRITETIM) as WRITETIM, 
	(ENDSNAP.SINGLEBLKRDTIM - BEGSNAP.SINGLEBLKRDTIM) as SINGLEBLKRDTIM
from DBA_HIST_FILESTATXS BEGSNAP, DBA_HIST_FILESTATXS ENDSNAP
where ENDSNAP.snap_id between &&bsnap and &&esnap
AND   BEGSNAP.dbid = &&dbid
AND   BEGSNAP.dbid = ENDSNAP.dbid
AND   BEGSNAP.instance_number = &&inum
AND   BEGSNAP.instance_number = ENDSNAP.instance_number
and   BEGSNAP.snap_id = (ENDSNAP.snap_id - 1)
and   ENDSNAP.FILENAME = BEGSNAP.FILENAME
order by 2 desc
) V
where	V.SINGLEBLKRDS > 0
and	V.PHYWRTS > 0
and	(V.PHYRDS-V.SINGLEBLKRDS) > 0
order by 1,4 desc
/

set lines 200
col tsname format a15
-- By tablespace !!!
select V.snap_id,
	V.TSNAME,
	V."SingleBlkReads" as "SBR",
	V."PhysReads",
	V."PhysWrts",
	10*V."SBReadTime"/V."SingleBlkReads" as "ASBRT",   --- "AvgSingleBlkReadTime",
	10*(V."ReadTime" - V."SBReadTime") / (V."PhysReads" - V."SingleBlkReads") as "AMBRT", --- "AvgMultiBlkReadTime",
	10*V."WriteTime" / V."PhysWrts" as "AWT", --- "AvgWrtTime",
	round(100*V."PhysReads"/(V."PhysReads"+V."PhysWrts"),2) as "Reads(%)",
	round(100*V."PhysWrts"/(V."PhysReads"+V."PhysWrts"),2) as "Writes(%)",
	round(100*V."SingleBlkReads"/V."PhysReads",2) as "SBR(%)"
from (
select ENDSNAP.snap_id,
	ENDSNAP.TSNAME, 
	(sum(ENDSNAP.PHYRDS)-sum(BEGSNAP.PHYRDS)) as "PhysReads", 
	(sum(ENDSNAP.PHYWRTS)-sum(BEGSNAP.PHYWRTS)) as "PhysWrts", 
	(sum(ENDSNAP.SINGLEBLKRDS)-sum(BEGSNAP.SINGLEBLKRDS)) as "SingleBlkReads", 
	(sum(ENDSNAP.READTIM)-sum(BEGSNAP.READTIM)) as "ReadTime", 
	(sum(ENDSNAP.WRITETIM)-sum(BEGSNAP.WRITETIM)) as "WriteTime", 
	(sum(ENDSNAP.SINGLEBLKRDTIM)-sum(BEGSNAP.SINGLEBLKRDTIM)) as "SBReadTime"
from DBA_HIST_FILESTATXS BEGSNAP, DBA_HIST_FILESTATXS ENDSNAP
where ENDSNAP.snap_id between &&bsnap and &&esnap
AND   BEGSNAP.dbid = &&dbid
AND   BEGSNAP.dbid = ENDSNAP.dbid
AND   BEGSNAP.instance_number = &&inum
AND   BEGSNAP.instance_number = ENDSNAP.instance_number
and   BEGSNAP.snap_id = (ENDSNAP.snap_id - 1)
and   ENDSNAP.TSNAME = BEGSNAP.TSNAME
and   ENDSNAP.TSNAME not in ('SYSTEM','SYSAUX')
group by ENDSNAP.snap_id, ENDSNAP.tsname
order by 2 desc) V
where V."SingleBlkReads" > 0
and   (V."PhysReads" - V."SingleBlkReads") > 0
and   V."PhysReads" > 0
and   V."PhysWrts" > 0
and   (V."PhysReads"+V."PhysWrts") > 0
/

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8372 USERS		    2	      12	  1	     0		0	   0	  92.31       7.69	16.67
      8396 USERS		    2	      12	  1	     0		0	   0	  92.31       7.69	16.67
      8467 USERS		    2	      12	  1	     0		0	   0	  92.31       7.69	16.67
      8372 UNDOTBS2		    2	    4098	  1	     0		0	   0	  99.98        .02	  .05
      8372 UNDOTBS1		    2	    4098	328	     0		0 3.65853659	  92.59       7.41	  .05
      8396 UNDOTBS1		   21	    4117	890 2.38095238		0 3.65168539	  82.22      17.78	  .51
      8444 UNDOTBS1		    1	    4097	351	    20		0 1.62393162	  92.11       7.89	  .02
      8467 UNDOTBS1		    2	    4098       1074	    10		0 16.9180633	  79.23      20.77	  .05
      8348 LIQMER_IDX		    2	     514	  1	     5		0	   0	  99.81        .19	  .39
      8372 LIQMER_IDX		    2	     514	  1	     0		0	   0	  99.81        .19	  .39
      8396 LIQMER_IDX		    2	     514	  1	     5		0	   0	  99.81        .19	  .39

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8467 LIQMER_IDX		    2	     514	  1	     0		0	   0	  99.81        .19	  .39
      8348 LIQMER_DAT		    2	     514	  1	     0		0	   0	  99.81        .19	  .39
      8370 LIQMER_DAT		   32	      39	  1	1.5625 1.42857143	   0	   97.5        2.5	82.05
      8372 LIQMER_DAT		    2	     514	  1	     5		0	   0	  99.81        .19	  .39
      8418 LIQMER_DAT		   17	      22	  1	     0		0	   0	  95.65       4.35	77.27
      8442 LIQMER_DAT		   58	      65	  1 1.72413793 1.42857143	   0	  98.48       1.52	89.23
      8465 LIQMER_DAT		   62	      69	  1 2.09677419 1.42857143	   0	  98.57       1.43	89.86
      8489 LIQMER_DAT		   36	      43	  1 1.38888889 2.85714286	   0	  97.73       2.27	83.72
      8491 LIQMER_DAT		    2	     514	  1	    15 -.01953125	   0	  99.81        .19	  .39
      8337 INDEXT		16944	   19592       1800 .061378659 1.26888218 .755555556	  91.59       8.41	86.48
      8348 INDEXT		  800	  262944       8072	   2.8 -.00030518 8.25569871	  97.02       2.98	   .3

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8369 INDEXT		 3640	    8672	792 1.07692308 6.51828299 .404040404	  91.63       8.37	41.97
      8370 INDEXT		10272	   16376       7664  1.4953271 2.24115334 1.03340292	  68.12      31.88	62.73
      8372 INDEXT		18152	  542440       7016 1.10621419		0 2.50855188	  98.72       1.28	 3.35
      8394 INDEXT		 3216	    3232      11856 .696517413	       15 .499325236	  21.42      78.58	 99.5
      8395 INDEXT		29704	   32736       8784 .684082952 4.88126649 .573770492	  78.84      21.16	90.74
      8396 INDEXT	       471736	  741448       2848 1.40230977 .117458623 2.24719101	  99.62        .38	63.62
      8407 INDEXT		 5624	    5640      15352 .967283073	      -15 .552371027	  26.87      73.13	99.72
      8409 INDEXT		  736	     880       2008 3.58695652 11.6666667 .836653386	  30.47      69.53	83.64
      8418 INDEXT		37096	   42328       4544 .644813457 8.31804281 3.13380282	  90.31       9.69	87.64
      8442 INDEXT		20208	   31384       2528 1.31828979	 4.452398 1.17088608	  92.55       7.45	64.39
      8444 INDEXT		  248	  262392       3560 3.87096774 -.00061035 1.91011236	  98.66       1.34	  .09

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8453 INDEXT		10280	   10288      14744 .832684825		0 .607704829	   41.1       58.9	99.92
      8455 INDEXT	       171144	  174136       1552 .866171177 1.81818182 .670103093	  99.12        .88	98.28
      8456 INDEXT		  560	     720       2024 1.57142857		2 .671936759	  26.24      73.76	77.78
      8459 INDEXT		45128	   45240	832 .774685339 2.85714286	1.25	  98.19       1.81	99.75
      8463 INDEXT	       144016	  162848       7824  .42884124 4.94902294 1.14519427	  95.42       4.58	88.44
      8465 INDEXT		19448	   30528       7664 2.11846977 4.87364621 1.00208768	  79.93      20.07	63.71
      8467 INDEXT	       165200	  428392       4872 7.90363196 .056536673 6.73234811	  98.88       1.12	38.56
      8480 INDEXT		  264	     424       1488 3.33333333		1 .967741935	  22.18      77.82	62.26
      8488 INDEXT		 5464	    6184	192  1.0102489 14.7777778 1.66666667	  96.99       3.01	88.36
      8489 INDEXT		17048	   27512       6080 1.23416237 4.35015291 .671052632	   81.9       18.1	61.97
      8491 INDEXT		 3104	  134176       5384 10.4123711	-.0012207  .72808321	  96.14       3.86	 2.31

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8328 DATA 		25473	   25578       5145 .041220115	       -2 .408163265	  83.25      16.75	99.59
      8332 DATA 		57393	   58632       8190 .021953897 -.16949153 .512820513	  87.74      12.26	97.89
      8334 DATA 		85869	   89082      21063   .0342382		0 .638085743	  80.88      19.12	96.39
      8335 DATA 	       129570	  132090       8967 .021069692 .083333333 .444964871	  93.64       6.36	98.09
      8336 DATA 	       230979	  231651      12726 .049095372	    .3125 .379537954	  94.79       5.21	99.71
      8337 DATA 		27720	   33033       3003 .037878788 .513833992 .979020979	  91.67       8.33	83.92
      8338 DATA 	       944769	  954198      15645 .001111383 .066815145  .33557047	  98.39       1.61	99.01
      8339 DATA 	       210525	  211575       6972 .366084788	      -.2  .63253012	  96.81       3.19	 99.5
      8340 DATA 		 1176	    1260      39606 .892857143	      2.5 .784729586	   3.08      96.92	93.33
      8341 DATA 	       100884	  101304       3402 .004163197		0 .864197531	  96.75       3.25	99.59
      8342 DATA 		76020	   76335      18690 .011049724		0 .550561798	  80.33      19.67	99.59

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8343 DATA 	       665595	  670950      21651 .004101593 .039215686 .494665373	  96.87       3.13	 99.2
      8344 DATA 		53067	   53277      12285	     0		0 .547008547	  81.26      18.74	99.61
      8345 DATA 	       107940	  113442       7938 .003891051 .038167939 .740740741	  93.46       6.54	95.15
      8346 DATA 		95214	  101514      32466 .030877812	      -.1 .472186287	  75.77      24.23	93.79
      8347 DATA 	       343665	  349650       8127 .003666361 -.03508772 .697674419	  97.73       2.27	98.29
      8348 DATA 	       136731	 1857261      17955 .193518661 .000244111 .877192982	  99.04        .96	 7.36
      8349 DATA 		59640	   59745       4494 .014084507		0 .654205607	     93 	 7	99.82
      8350 DATA 		51282	   51492      14616 .045045045		0 .488505747	  77.89      22.11	99.59
      8351 DATA 	       349482	  351897      16086 .006008893		0 .352480418	  95.63       4.37	99.31
      8352 DATA 		84546	   84756      10269  .00496771		1 .490797546	  89.19      10.81	99.75
      8354 DATA 	       305256	  306873       9177 .002063841	.25974026 .663615561	   97.1        2.9	99.47

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8357 DATA 		59178	   59283       4389 .031937544		2  .14354067	  93.11       6.89	99.82
      8358 DATA 		26775	   32865      26082 .109803922 -.06896552 .652173913	  55.75      44.25	81.47
      8359 DATA 	       111804	  114996      14973 .011269722		0 .546984572	  88.48      11.52	97.22
      8360 DATA 	       391272	  392406      22386 .019858308 -.18518519 .609756098	   94.6        5.4	99.71
      8361 DATA 		51324	   51786      10815 .020458265 .454545455 .854368932	  82.72      17.28	99.11
      8362 DATA 	       109473	  111468      11004 .003836562		0 .477099237	  91.02       8.98	98.21
      8365 DATA 	       216111	  218316      14217 .007773783 .095238095 .339734121	  93.89       6.11	98.99
      8366 DATA 	       113085	  117495      23856 .016713092 .047619048 .563380282	  83.12      16.88	96.25
      8367 DATA 	       120792	  125139      22470  .02433936 -.04830918 .570093458	  84.78      15.22	96.53
      8368 DATA 	       192759	  194481      13335 .001089443		0 .535433071	  93.58       6.42	99.11
      8369 DATA 	       126378	  130578      16107 .079760718	      1.8 .964797914	  89.02      10.98	96.78

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8370 DATA 	     32611446	33403251      32949 .004945503 .033152102 .949649458	   99.9 	.1	97.63
      8371 DATA 	       175686	  180096      22701 .020320344 -.04761905 .703052729	  88.81      11.19	97.55
      8372 DATA 	       144060	 3758580      10752 .040816327 .000290495 2.20703125	  99.71        .29	 3.83
      8373 DATA 		80787	   82572      13041 .015596569 -.11764706 .611916264	  86.36      13.64	97.84
      8374 DATA 	       218505	  221277      12306 .032676598 -.22727273 .494880546	  94.73       5.27	98.75
      8375 DATA 	       166005	  168441      14721 .025300443		0 .456490728	  91.96       8.04	98.55
      8376 DATA 	       379575	  381444       9975 .001106501		0 .631578947	  97.45       2.55	99.51
      8377 DATA 	       108423	  109053       4704 .009684292		0 .848214286	  95.86       4.14	99.42
      8378 DATA 	       357546	  358995      19887 .004111359		0 .443505808	  94.75       5.25	 99.6
      8379 DATA 		51639	   52038       1995 .008133388 -.52631579 .736842105	  96.31       3.69	99.23
      8380 DATA 		50400	   50610       4725 .004166667		1 .311111111	  91.46       8.54	99.59

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8381 DATA 		50190	   50400       1050	     0		0	   1	  97.96       2.04	99.58
      8382 DATA 	       178941	  214536      24759 .012909283 -.00589971 .636132316	  89.65      10.35	83.41
      8383 DATA 	       216615	  230643      31395 .028114397		0  .52173913	  88.02      11.98	93.92
      8384 DATA 	       372456	  410004      27447 .010712675		0 .642693191	  93.73       6.27	90.84
      8385 DATA 	       167517	  169344      20622 .017550458		0 .376782077	  89.14      10.86	98.92
      8386 DATA 	       812385	  818811      10668 .002843479 .032679739 .767716535	  98.71       1.29	99.22
      8387 DATA 	       108759	  110019       8547 .003861749		0 .663390663	  92.79       7.21	98.85
      8388 DATA 		25767	   25872       8043 .008149959		4 .052219321	  76.28      23.72	99.59
      8389 DATA 	       348012	  353745      21567 .006637702 .073260073 .418695229	  94.25       5.75	98.38
      8390 DATA 	       111888	  115626      36645 .035660661 -.11235955 .561604585	  75.93      24.07	96.77
      8391 DATA 	       639051	  639723      13671 .006572245		0 .783410138	  97.91       2.09	99.89

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8392 DATA 		50463	   50673       5754 .004161465		1 .182481752	   89.8       10.2	99.59
      8393 DATA 	       224343	  228984      20202 .007488533 -.13574661  .27027027	  91.89       8.11	97.97
      8394 DATA 	       138033	  141309      35742 .024342005 .192307692 .658049354	  79.81      20.19	97.68
      8395 DATA 	       344694	  436296      21441 .180333861 .213204952 .920666014	  95.32       4.68	   79
      8396 DATA 	      1331295	 3186141      35721 .758577175	.36444535 2.25749559	  98.89       1.11	41.78
      8397 DATA 	       107184	  107520	504	     0		0 .416666667	  99.53        .47	99.69
      8398 DATA 	       857136	  863184      17850 .001715014 1.63194444 1.31764706	  97.97       2.03	 99.3
      8399 DATA 	       352023	  353304      11130 .005965519 .327868852 .698113208	  96.95       3.05	99.64
      8400 DATA 	       350973	  355257      22764  .00538503		0 .341328413	  93.98       6.02	98.79
      8401 DATA 	       105525	  106974      16653 .007960199 -.14492754 .895334174	  86.53      13.47	98.65
      8402 DATA 	       352023	  355299      16884 .005368967		0 .360696517	  95.46       4.54	99.08

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8403 DATA 	       132153	  133833      12915 .004767202	     .125 .357723577	   91.2        8.8	98.74
      8404 DATA 	       125853	  129864       5397 .001668613 .052356021 1.59533074	  96.01       3.99	96.91
      8405 DATA 		79926	   81522      11004 .013137152 -.13157895 .458015267	  88.11      11.89	98.04
      8406 DATA 	       242928	  251034      28182 .025069156 -.02590674 .812220566	  89.91      10.09	96.77
      8407 DATA 		55146	   59304      32361 .118050267 .101010101 .642439974	   64.7       35.3	92.99
      8408 DATA 	       168315	  168399       1617 .007485964	     -7.5 .779220779	  99.05        .95	99.95
      8409 DATA 	       108801	  111741      15876 .104226983		0  .78042328	  87.56      12.44	97.37
      8410 DATA 	       893403	  926037      17178 .002585619 .019305019  .86797066	  98.18       1.82	96.48
      8411 DATA 	       135660	  139335       4851 .012383901		0 .519480519	  96.64       3.36	97.36
      8412 DATA 	       138726	  139545      13776 .004541326		0 .259146341	  91.01       8.99	99.41
      8413 DATA 	       105273	  109557       6720 .003989627 .049019608    1.40625	  94.22       5.78	96.09

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8414 DATA 	       214389	  215586      25389 .004897639 .175438596 .653432589	  89.46      10.54	99.44
      8415 DATA 		83433	   88977       6573 .035237856 -.07575758 .926517572	  93.12       6.88	93.77
      8416 DATA 	       142212	  143094      11025 .011813349 -.47619048 .666666667	  92.85       7.15	99.38
      8417 DATA 	       119889	  129864      17283 .087581012		0 .400972053	  88.25      11.75	92.32
      8418 DATA 	     32685807	33471123      22575 .004163275 .010161515 5.17209302	  99.93        .07	97.65
      8419 DATA 	       224742	  231987      33558 .030835358 -.05797101 .488110138	  87.36      12.64	96.88
      8420 DATA 	       374976	  375564      14385 .029121864 1.07142857 1.31386861	  96.31       3.69	99.84
      8421 DATA 		25326	   25452       1680 .024875622		0	.875	  93.81       6.19	 99.5
      8422 DATA 	       736470	  740019      18060 .003136584 .473372781 .662790698	  97.62       2.38	99.52
      8423 DATA 	       328272	  328419       9282 .008955988 2.85714286 .452488688	  97.25       2.75	99.96
      8424 DATA 	       101388	  106113      13545 .014498757 -.08888889 .403100775	  88.68      11.32	95.55

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8425 DATA 		25242	   25347       9996 .008319468		2 .588235294	  71.72      28.28	99.59
      8427 DATA 		27279	   30996      11655 .084680523 -.16949153 .324324324	  72.67      27.33	88.01
      8428 DATA 		55734	   56595      10101  .01507159 .487804878  .51975052	  84.86      15.14	98.48
      8430 DATA 	       132237	  167496      36603 .063522312 .005955926 .694205393	  82.07      17.93	78.95
      8431 DATA 		58254	   68586      22344 .097332372	-.0203252 .535714286	  75.43      24.57	84.94
      8432 DATA 	       242970	  245427       9954 .032843561 .341880342 .379746835	   96.1        3.9	   99
      8433 DATA 	       111636	  112854      19047 .011286682 1.72413793 .540242558	  85.56      14.44	98.92
      8434 DATA 	       157164	  176757      20265 .037413148 -.01071811 .580310881	  89.71      10.29	88.92
      8435 DATA 	       267897	  269136      12369 .233597241 -.33898305 .356536503	  95.61       4.39	99.54
      8436 DATA 		93534	   97251      55965 .087561742	.11299435 .686679174	  63.47      36.53	96.18
      8437 DATA 	       211428	  212625      14532 .005959476	-.1754386 .086705202	   93.6        6.4	99.44

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8438 DATA 	       208971	  209895      29820 .039192041 .227272727 .549295775	  87.56      12.44	99.56
      8439 DATA 	       673827	  682248      16128 .004363138 .099750623 .807291667	  97.69       2.31	98.77
      8440 DATA 		81102	   81438      24822 .036250647	    -1.25 .752961083	  76.64      23.36	99.59
      8441 DATA 	       136773	  140910      13104 .035313987 -.10152284 .320512821	  91.49       8.51	97.06
      8442 DATA 	     32711637	33504597      15246 .006676523 .042637712 1.90082645	  99.95        .05	97.63
      8443 DATA 	       361242	  408366      23247   .0104639		0 .776874435	  94.61       5.39	88.46
      8444 DATA 	       162981	 1885233      16107 .014173431 .000487734 .573663625	  99.15        .85	 8.65
      8445 DATA 	       313803	  319116      30744 .011376564 -.07905138  .43715847	  91.21       8.79	98.34
      8446 DATA 	      1160187	 1164009      10941 .011403334	.32967033 .633397313	  99.07        .93	99.67
      8447 DATA 	       104685	  106260       8883 .008024072 -.26666667 .567375887	  92.29       7.71	98.52
      8448 DATA 	       101283	  104076      13965 .033174373		0 1.51879699	  88.17      11.83	97.32

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8449 DATA 	       407337	  409017       8043 .005155436		0 7.70234987	  98.07       1.93	99.59
      8450 DATA 	       104664	  106239      11634 .010032103 -.26666667 .577617329	  90.13       9.87	98.52
      8451 DATA 	       128919	  130410       4158 .013031438	.14084507 .353535354	  96.91       3.09	98.86
      8452 DATA 	       103572	  105336      17262   .0081103 .119047619 .608272506	  85.92      14.08	98.33
      8453 DATA 		30765	   36855      21693 .177474403 -.06896552 .629235237	  62.95      37.05	83.48
      8454 DATA 	       109641	  119049      21147 .086190385 .022321429 .526315789	  84.92      15.08	 92.1
      8455 DATA 	       463554	  491106      10773 .403189272 .457317073  .37037037	  97.85       2.15	94.39
      8456 DATA 	       107625	  109410      13965 .007804878 2.35294118 .541353383	  88.68      11.32	98.37
      8457 DATA 	       941283	  978768      18795 .006246793 .016806723 .670391061	  98.12       1.88	96.17
      8458 DATA 	       127617	  128373       3276 .003291098 .277777778 .512820513	  97.51       2.49	99.41
      8459 DATA 	       500829	  501186       9744 .532517087 -1.1764706 .280172414	  98.09       1.91	99.93

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8460 DATA 	       176547	  179403      14196 .005947425 -.07352941  .48816568	  92.67       7.33	98.41
      8461 DATA 	       255864	  261933      32949 .028726198 .103806228 .586360739	  88.83      11.17	97.68
      8462 DATA 	       115269	  117180      16947 .036436509 -.21978022 .520446097	  87.36      12.64	98.37
      8463 DATA 	       596295	  665091      23982 .338439866	7.2954823 .455341506	  96.52       3.48	89.66
      8464 DATA 	       202713	  207627      21021 .012431368 .085470085  .36963037	  90.81       9.19	97.63
      8465 DATA 	     32722935	33515580      22848 .007514913 .049807922 1.37867647	  99.93        .07	97.63
      8466 DATA 	       208173	  213402      16044 .031272067	.16064257  .54973822	  93.01       6.99	97.55
      8467 DATA 	       303156	 2026815      15309 2.96827376 .002558511 5.21262003	  99.25        .75	14.96
      8468 DATA 	       175896	  176379       7833 .010744986 .434782609  .18766756	  95.75       4.25	99.73
      8469 DATA 	       778155	  781410       9849 .000269869		0 .724946695	  98.76       1.24	99.58
      8470 DATA 	       123753	  153552       9912 .049210928 .098661029 3.72881356	  93.94       6.06	80.59

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8471 DATA 		99729	  100653       4788 .004211413		0 .701754386	  95.46       4.54	99.08
      8472 DATA 		74109	   74949       2268 .005667328		0 .925925926	  97.06       2.94	98.88
      8473 DATA 	       106470	  133350       1428 .003944773		0 .882352941	  98.94       1.06	79.84
      8474 DATA 		71547	   73899       5544 .008805401		0 .378787879	  93.02       6.98	96.82
      8475 DATA 	       125748	  126168       5166  .01002004	      -.5 .365853659	  96.07       3.93	99.67
      8476 DATA 		50442	   50652       3570	     0		0 .235294118	  93.42       6.58	99.59
      8477 DATA 	       174699	  178983      20517 .026445486		0 .634595701	  89.72      10.28	97.61
      8478 DATA 		99834	  106953      15309 .014724443	.05899705 1.24828532	  87.48      12.52	93.34
      8479 DATA 	       199290	  199605       6846 .002107482		0 .245398773	  96.68       3.32	99.84
      8480 DATA 		51891	   53466       8778 .016187778	      2.4 .717703349	   85.9       14.1	97.05
      8481 DATA 	       235326	  237846      10857 .014278065 -.08333333 .967117988	  95.63       4.37	98.94

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8486 DATA 		32550	   36624      39459 .219354839 .154639175 .750399148	  48.14      51.86	88.88
      8487 DATA 	       127407	  127785       9933 .004944783 -1.1111111 .253699789	  92.79       7.21	 99.7
      8488 DATA 		71022	   72114       6363 .239503253 2.11538462 .066006601	  91.89       8.11	98.49
      8489 DATA 	     32710755	33509553      14847  .00414084	.04258899 .678925035	  99.96        .04	97.62
      8490 DATA 	       229509	  232218       5607 .010979962 .465116279 .898876404	  97.64       2.36	98.83
      8491 DATA 	       130410	  990906      12936 .088566828 .000244045 .324675325	  98.71       1.29	13.16
      8492 DATA 		  105	     420	693	     2 1.33333333 3.63636364	  37.74      62.26	   25
      8493 DATA 	       855813	  859824      15456 .001963046 .732984293 1.12771739	  98.23       1.77	99.53
      8497 DATA 		41916	   46872       2982  .01002004		0 .985915493	  94.02       5.98	89.43
      8498 DATA 	       128268	  128583       7308 .008185986 -1.3333333 .574712644	  94.62       5.38	99.76
      8499 DATA 		50505	   50715       1155 .012474012		0 2.36363636	  97.77       2.23	99.59

   SNAP_ID TSNAME		  SBR  PhysReads   PhysWrts	 ASBRT	    AMBRT	 AWT   Reads(%)  Writes(%)     SBR(%)
---------- --------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      8500 DATA 		25368	   25473       5040	     0		2 .291666667	  83.48      16.52	99.59
      8501 DATA 		 2562	    8484      26397 2.45901639 .106382979 .747812251	  24.32      75.68	 30.2
      8502 DATA 	       102648	  108948      11613 .012274959 -.03333333  .61482821	  90.37       9.63	94.22
      8503 DATA 	       186816	  189105       9114 .042715827 -.09174312 .483870968	   95.4        4.6	98.79
      8504 DATA 		95130	  100023       5859 .013245033 .515021459 .573476703	  94.47       5.53	95.11
      8505 DATA 	       812742	  823683      10122 .005167692 -.03838772 1.12033195	  98.79       1.21	98.67
      8506 DATA 	       119784	  123984       4347 .001753156		0 1.69082126	  96.61       3.39	96.61
      8507 DATA 	       204351	  205401      12474 .003082931	       .4  .69023569	  94.27       5.73	99.49
      8508 DATA 	       156681	  157164      11172 .036188179 -.43478261 .639097744	  93.36       6.64	99.69

207 rows selected.



-- By Volume Group

select decode(substr(FILENAME,1,instr(filename,'/',2)-1),'/oradata','vg_CHRDPRO','vg_ORADATA'), sum(PHYRDS), sum(PHYWRTS), sum(SINGLEBLKRDS), sum(READTIM), sum(WRITETIM), sum(SINGLEBLKRDTIM)
from DBA_HIST_FILESTATXS
where snap_id = (select max(snap_id) from dba_hist_snapshot)
group by decode(substr(FILENAME,1,instr(filename,'/',2)-1),'/oradata','vg_CHRDPRO','vg_ORADATA')
order by 2 desc
/

-- Valores medios: esto hay que afinarlo con las medias ponderadas !!!
select	avg("AvgSingleBlkReadTime (ms)"),
	avg("AvgReadTime (ms)"),
	avg("AvgWrtTime (ms)")
from (
select	V.filename, 
	10* (V.SINGLEBLKRDTIM / V.SINGLEBLKRDS) as "AvgSingleBlkReadTime (ms)",
	10* ((V.READTIM-V.SINGLEBLKRDTIM) / (V.PHYRDS-V.SINGLEBLKRDS)) as "AvgReadTime (ms)",
	10* (V.WRITETIM / V.PHYWRTS) as "AvgWrtTime (ms)"
from (
select FILENAME, PHYRDS, PHYWRTS, SINGLEBLKRDS, READTIM, WRITETIM, SINGLEBLKRDTIM
from DBA_HIST_FILESTATXS
where snap_id = (select max(snap_id) from dba_hist_snapshot where dbid = &&dbid and instance_number = &&inum)
order by 2 desc
) V)
/

AVG("AVGSINGLEBLKREADTIME(MS)") AVG("AVGREADTIME(MS)") AVG("AVGWRTTIME(MS)")
------------------------------- ---------------------- ---------------------
		      .68669043 	    .342267911		  3.34924091



select TSNAME, avg("ASBRT"), avg("AMBRT"), avg("Reads(%)"), avg("Writes(%)"), avg("SBR(%)")
from (
select V.snap_id,
        V.TSNAME,
        V."SingleBlkReads" as "SBR",
        V."PhysReads",
        V."PhysWrts",
        10*V."SBReadTime"/V."SingleBlkReads" as "ASBRT",   --- "AvgSingleBlkReadTime",
        10*(V."ReadTime" - V."SBReadTime") / (V."PhysReads" - V."SingleBlkReads") as "AMBRT", --- "AvgMultiBlkReadTime",
        10*V."WriteTime" / V."PhysWrts" as "AWT", --- "AvgWrtTime",
        round(100*V."PhysReads"/(V."PhysReads"+V."PhysWrts"),2) as "Reads(%)",
        round(100*V."PhysWrts"/(V."PhysReads"+V."PhysWrts"),2) as "Writes(%)",
        round(100*V."SingleBlkReads"/V."PhysReads",2) as "SBR(%)"
from (
select ENDSNAP.snap_id,
        ENDSNAP.TSNAME,
        (sum(ENDSNAP.PHYRDS)-sum(BEGSNAP.PHYRDS)) as "PhysReads",
        (sum(ENDSNAP.PHYWRTS)-sum(BEGSNAP.PHYWRTS)) as "PhysWrts",
        (sum(ENDSNAP.SINGLEBLKRDS)-sum(BEGSNAP.SINGLEBLKRDS)) as "SingleBlkReads",
        (sum(ENDSNAP.READTIM)-sum(BEGSNAP.READTIM)) as "ReadTime",
        (sum(ENDSNAP.WRITETIM)-sum(BEGSNAP.WRITETIM)) as "WriteTime",
        (sum(ENDSNAP.SINGLEBLKRDTIM)-sum(BEGSNAP.SINGLEBLKRDTIM)) as "SBReadTime"
from DBA_HIST_FILESTATXS BEGSNAP, DBA_HIST_FILESTATXS ENDSNAP
where ENDSNAP.snap_id between &&bsnap and &&esnap
AND   BEGSNAP.dbid = &&dbid
AND   BEGSNAP.dbid = ENDSNAP.dbid
AND   BEGSNAP.instance_number = &&inum
AND   BEGSNAP.instance_number = ENDSNAP.instance_number
and   BEGSNAP.snap_id = (ENDSNAP.snap_id - 1)
and   ENDSNAP.TSNAME = BEGSNAP.TSNAME
and   ENDSNAP.TSNAME not in ('SYSTEM','SYSAUX')
group by ENDSNAP.snap_id, ENDSNAP.tsname
order by 2 desc) V
where V."SingleBlkReads" > 0
and   (V."PhysReads" - V."SingleBlkReads") > 0
and   V."PhysReads" > 0
and   V."PhysWrts" > 0
and   (V."PhysReads"+V."PhysWrts") > 0
)
group by TSNAME
/

TSNAME		AVG("ASBRT") AVG("AMBRT") AVG("READS(%)") AVG("WRITES(%)") AVG("SBR(%)")
--------------- ------------ ------------ --------------- ---------------- -------------
LIQMER_DAT	  3.34653763   .890415737	    98.42	      1.58	 52.9125
UNDOTBS1	   8.0952381		0	  86.5375	   13.4625	   .1575
DATA		  .091289946   .184082452      89.8769325	10.1230675    92.9853374
LIQMER_IDX		 2.5		0	    99.81	       .19	     .39
USERS			   0		0	    92.31	      7.69	   16.67
UNDOTBS2		   0		0	    99.98	       .02	     .05
INDEXT		  2.09154551	3.1726865      75.9129167	24.0870833    65.2295833

7 rows selected.


-- Total de I/O !!!
-- IO weight per datafile !!!

define bsnap=10343
define esnap=11070
define inum=1
define dbid=4140483279

select	sum(PHYRDS),
	sum(PHYWRTS),
	sum(PHYRDS)+sum(PHYWRTS), 
	round(sum(PHYRDS)*100/(sum(PHYRDS)+sum(PHYWRTS)),2) as "Read(%)",
	round(sum(PHYWRTS)*100/(sum(PHYRDS)+sum(PHYWRTS)),2) as "Write(%)"
from 
(
select ENDSNAP.SNAP_ID,
	ENDSNAP.FILENAME, 
	(ENDSNAP.PHYRDS - BEGSNAP.PHYRDS) as PHYRDS, 
	(ENDSNAP.PHYWRTS - BEGSNAP.PHYWRTS) as PHYWRTS, 
	(ENDSNAP.SINGLEBLKRDS - BEGSNAP.SINGLEBLKRDS) as SINGLEBLKRDS, 
	(ENDSNAP.READTIM - BEGSNAP.READTIM) as READTIM, 
	(ENDSNAP.WRITETIM - BEGSNAP.WRITETIM) as WRITETIM, 
	(ENDSNAP.SINGLEBLKRDTIM - BEGSNAP.SINGLEBLKRDTIM) as SINGLEBLKRDTIM
from DBA_HIST_FILESTATXS BEGSNAP, DBA_HIST_FILESTATXS ENDSNAP
where ENDSNAP.snap_id between &&bsnap and &&esnap
AND   BEGSNAP.dbid = &&dbid
AND   BEGSNAP.dbid = ENDSNAP.dbid
AND   BEGSNAP.instance_number = &&inum
AND   BEGSNAP.instance_number = ENDSNAP.instance_number
and   BEGSNAP.snap_id = (ENDSNAP.snap_id - 1)
and   ENDSNAP.FILENAME = BEGSNAP.FILENAME
order by 2 desc
) V
where	V.SINGLEBLKRDS > 0
and	V.PHYWRTS > 0
and	(V.PHYRDS-V.SINGLEBLKRDS) > 0;

SUM(PHYRDS) SUM(PHYWRTS) SUM(PHYRDS)+SUM(PHYWRTS)    Read(%)   Write(%)
----------- ------------ ------------------------ ---------- ----------
  709085827	81662875		790748702      89.67	  10.33



col filename format a70
set lines 140 pages 300

select	filename, 
	round((sum(PHYRDS)+sum(PHYWRTS))*100/790748702,2) as "IO weight %",
	round(sum(PHYRDS)*100/709085827,2) as "Read weight %",
	round(sum(PHYWRTS)*100/81662875,2) as "Write weight %"
from
(
select ENDSNAP.SNAP_ID,
	ENDSNAP.FILENAME, 
	(ENDSNAP.PHYRDS - BEGSNAP.PHYRDS) as PHYRDS, 
	(ENDSNAP.PHYWRTS - BEGSNAP.PHYWRTS) as PHYWRTS, 
	(ENDSNAP.SINGLEBLKRDS - BEGSNAP.SINGLEBLKRDS) as SINGLEBLKRDS, 
	(ENDSNAP.READTIM - BEGSNAP.READTIM) as READTIM, 
	(ENDSNAP.WRITETIM - BEGSNAP.WRITETIM) as WRITETIM, 
	(ENDSNAP.SINGLEBLKRDTIM - BEGSNAP.SINGLEBLKRDTIM) as SINGLEBLKRDTIM
from DBA_HIST_FILESTATXS BEGSNAP, DBA_HIST_FILESTATXS ENDSNAP
where ENDSNAP.snap_id between &&bsnap and &&esnap
AND   BEGSNAP.dbid = &&dbid
AND   BEGSNAP.dbid = ENDSNAP.dbid
AND   BEGSNAP.instance_number = &&inum
AND   BEGSNAP.instance_number = ENDSNAP.instance_number
and   BEGSNAP.snap_id = (ENDSNAP.snap_id - 1)
and   ENDSNAP.FILENAME = BEGSNAP.FILENAME
order by 2 desc
) V
where	V.SINGLEBLKRDS > 0
and	V.PHYWRTS > 0
and	(V.PHYRDS-V.SINGLEBLKRDS) > 0
group by filename
order by 2 desc;

FILENAME							       IO weight % Read weight % Write weight %
---------------------------------------------------------------------- ----------- ------------- --------------
/u01/app/oracle/oradata/PRONOS/datafile/D_HUGE.dbf			     41.32	   45.19	   7.72
/u01/app/oracle/oradata/PRONOS/datafile/D_REGSITEVEN.dbf		     14.48	   16.06	    .74
/u01/app/oracle/oradata/PRONOS/datafile/D_LARGE.dbf			     11.07	     9.2	  27.27
/u01/app/oracle/oradata/PRONOS/datafile/I_MEDIUM.dbf			      8.85	    8.02	  16.09
/u01/app/oracle/oradata/PRONOS/datafile/I_LARGE.dbf			       4.1	    3.05	   13.2
/u01/app/oracle/oradata/PRONOS/datafile/I_REGSITEVEN.dbf		      3.69	    3.44	   5.86
/u01/app/oracle/oradata/PRONOS/datafile/MRC.dbf 			      1.94	    1.96	    1.8
/u01/app/oracle/oradata/PRONOS/datafile/TBS_ARCHIVADO_FB.dbf		      1.75	     .82	   9.82
/u01/app/oracle/oradata/PRONOS/datafile/D_REGESTADO.dbf 		      1.62	    1.74	    .61
/u02/app/oracle/oradata/PRONOS/datafile/MRC_02.dbf			      1.61	    1.48	   2.71
/u01/app/oracle/oradata/PRONOS/datafile/JMS.dbf 			      1.48	    1.62	    .25
/u01/app/oracle/oradata/PRONOS/datafile/o1_mf_system_7bl806mg_.dbf	      1.46	    1.46	   1.52
/u01/app/oracle/oradata/PRONOS/datafile/I_HUGE.dbf			      1.36	    1.48	    .27
/u01/app/oracle/oradata/PRONOS/datafile/D_SMALL.dbf			      1.15	     .91	   3.26
/u01/app/oracle/oradata/PRONOS/datafile/o1_mf_sysaux_7bl806o3_.dbf	       .84	     .79	   1.28
/u01/app/oracle/oradata/PRONOS/datafile/D_PART.dbf			       .82	     .59	   2.74
/u01/app/oracle/oradata/PRONOS/datafile/D_MEDIUM.dbf			       .56	     .55	    .69
/u01/app/oracle/oradata/PRONOS/datafile/I_MRC.dbf			       .44	     .33	   1.39
/u01/app/oracle/oradata/PRONOS/datafile/I_REGEVTRAT.dbf 		       .41	     .39	    .58
/u01/app/oracle/oradata/PRONOS/datafile/D_REGEVTRAT.dbf 		       .35	     .33	    .45
/u01/app/oracle/oradata/PRONOS/datafile/I_TINY.dbf				.3	     .24	    .84
/u01/app/oracle/oradata/PRONOS/datafile/D_HIST.dbf			       .16	     .12	     .5
/u01/app/oracle/oradata/PRONOS/datafile/I_REGESTADO.dbf 		       .08	     .07	     .2
/u01/app/oracle/oradata/PRONOS/datafile/I_HIST.dbf			       .07	     .07	    .06
/u01/app/oracle/oradata/PRONOS/datafile/I_PART.dbf			       .05	     .04	    .08
/u01/app/oracle/oradata/PRONOS/datafile/D_TINY.dbf			       .02	     .02	    .02
/u01/app/oracle/oradata/PRONOS/datafile/I_SMALL.dbf			       .02	     .02	    .03
/u01/app/oracle/oradata/PRONOS/datafile/I_AUDCLASECB.dbf		       .01	     .01	      0
/u01/app/oracle/oradata/PRONOS/datafile/soe.dbf 				 0	       0	      0
/u01/app/oracle/oradata/PRONOS/datafile/D_AUDCLASECB.dbf			 0	       0	      0
/u01/app/oracle/oradata/PRONOS/datafile/D_REGAUDIT.dbf				 0	       0	      0
/u01/app/oracle/oradata/PRONOS/datafile/I_REGAUDITC.dbf 			 0	       0	      0
/u01/app/oracle/oradata/PRONOS/datafile/o1_mf_users_7bl806ph_.dbf		 0	       0	      0
/u02/app/oracle/oradata/PRONOS/datafile/o1_mf_mrc_8jpx7191_.dbf 		 0	       0	    .01
/u01/app/oracle/oradata/PRONOS/datafile/D_REGAUDITC.dbf 			 0	       0	      0

35 rows selected.







