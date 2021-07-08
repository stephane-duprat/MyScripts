-- Time columns in perfstat.STATS$FILESTATXS are in cs (hundredths of a second) !!!

-- By datafile !!!
col filename format a32
set pages 1000 lines 160 

select V.snap_id,
	V.filename,
	V.PHYRDS,
	V.SINGLEBLKRDS,
	V.PHYWRTS,
	round(100*V.PHYRDS/(V.PHYRDS+V.PHYWRTS),2) as "Reads(%)",
	round(100*V.PHYWRTS/(V.PHYRDS+V.PHYWRTS),2) as "Writes(%)",
	round(100*V.SINGLEBLKRDS/V.PHYRDS,2) as "SBR(%)",
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
from perfstat.STATS$FILESTATXS BEGSNAP, perfstat.STATS$FILESTATXS ENDSNAP
where ENDSNAP.snap_id between &bsnap and &esnap
and   BEGSNAP.snap_id = (ENDSNAP.snap_id - 1)
and   ENDSNAP.FILENAME = BEGSNAP.FILENAME
order by 2 desc
) V
where	V.SINGLEBLKRDS > 0
and	V.PHYWRTS > 0
and	(V.PHYRDS-V.SINGLEBLKRDS) > 0
order by 1,4 desc
/

-- By TBS

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
from perfstat.STATS$FILESTATXS BEGSNAP, perfstat.STATS$FILESTATXS ENDSNAP
where ENDSNAP.snap_id between &bsnap and &esnap
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
from perfstat.STATS$FILESTATXS
where snap_id = (select max(snap_id) from perfstat.STATS$SNAPSHOT)
order by 2 desc
) V)
/



