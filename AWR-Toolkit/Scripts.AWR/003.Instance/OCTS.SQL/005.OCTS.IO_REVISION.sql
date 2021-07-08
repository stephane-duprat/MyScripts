define dbid=&&1
define inum=&&2
define bsnap=&&3
define esnap=&&4

set pages 300

PROMPT *********************************************
PROMPT *    I/O caracterization summary            *
PROMPT *********************************************

PROMPT Reads versus Writes Summary
PROMPT ***************************

column "IOTotal" new_value iototal
column "PRTotal" new_value prtotal

select	sum(PHYRDS) as "PRTotal",
	sum(PHYWRTS),
	sum(PHYRDS)+sum(PHYWRTS) as "IOTotal", 
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


PROMPT Direct Path reads summary
PROMPT *************************

column "PR Total" new_value prtotal

select sum(v1.PR) as "PR Total"
from
(
select  ENDSNAP.SNAP_ID,
        (ENDSNAP.VALUE - BEGSNAP.VALUE) as PR
from  DBA_HIST_SYSSTAT BEGSNAP, DBA_HIST_SYSSTAT ENDSNAP
where ENDSNAP.snap_id between &&bsnap and &&esnap
AND   BEGSNAP.dbid = &&dbid
AND   BEGSNAP.dbid = ENDSNAP.dbid
AND   BEGSNAP.instance_number = &&inum
AND   BEGSNAP.instance_number = ENDSNAP.instance_number
and   BEGSNAP.snap_id = (ENDSNAP.snap_id - 1)
and   BEGSNAP.stat_name = 'physical reads'
and   ENDSNAP.stat_name = BEGSNAP.stat_name
) V1
/

column "PRD Total" new_value prdtotal

select sum(v2.PR) as "PRD Total"
from
(
select  ENDSNAP.SNAP_ID,
        (ENDSNAP.VALUE - BEGSNAP.VALUE) as PR
from  DBA_HIST_SYSSTAT BEGSNAP, DBA_HIST_SYSSTAT ENDSNAP
where ENDSNAP.snap_id between &&bsnap and &&esnap
AND   BEGSNAP.dbid = &&dbid
AND   BEGSNAP.dbid = ENDSNAP.dbid
AND   BEGSNAP.instance_number = &&inum
AND   BEGSNAP.instance_number = ENDSNAP.instance_number
and   BEGSNAP.snap_id = (ENDSNAP.snap_id - 1)
and   BEGSNAP.stat_name = 'physical reads direct'
and   ENDSNAP.stat_name = BEGSNAP.stat_name
) V2
/

select &&prtotal as "Physical Reads",
       &&prdtotal as "Physical Reads Direct",
       round((100*&&prdtotal)/&&prtotal,2) as "PR Direct (%)"
from dual;


PROMPT Single Block vs Multi Block summary
PROMPT ***********************************

column "PR Total IO Req." new_value prtior

select sum(v1.PRTIOR) as "PR Total IO Req."
from
(
select  ENDSNAP.SNAP_ID,
        (ENDSNAP.VALUE - BEGSNAP.VALUE) as PRTIOR
from  DBA_HIST_SYSSTAT BEGSNAP, DBA_HIST_SYSSTAT ENDSNAP
where ENDSNAP.snap_id between &&bsnap and &&esnap
AND   BEGSNAP.dbid = &&dbid
AND   BEGSNAP.dbid = ENDSNAP.dbid
AND   BEGSNAP.instance_number = &&inum
AND   BEGSNAP.instance_number = ENDSNAP.instance_number
and   BEGSNAP.snap_id = (ENDSNAP.snap_id - 1)
and   BEGSNAP.stat_name = 'physical read total IO requests'
and   ENDSNAP.stat_name = BEGSNAP.stat_name
) V1
/

column "PR Total MBLCK Req." new_value prtmbr

select sum(V2.PRTMBR) as "PR Total MBLCK Req."
from 
(
select  ENDSNAP.SNAP_ID,
        (ENDSNAP.VALUE - BEGSNAP.VALUE) as PRTMBR
from  DBA_HIST_SYSSTAT BEGSNAP, DBA_HIST_SYSSTAT ENDSNAP
where ENDSNAP.snap_id between &&bsnap and &&esnap
AND   BEGSNAP.dbid = &&dbid
AND   BEGSNAP.dbid = ENDSNAP.dbid
AND   BEGSNAP.instance_number = &&inum
AND   BEGSNAP.instance_number = ENDSNAP.instance_number
and   BEGSNAP.snap_id = (ENDSNAP.snap_id - 1)
and   BEGSNAP.stat_name = 'physical read total multi block requests'
and   ENDSNAP.stat_name = BEGSNAP.stat_name
) V2
/

select &&prtior as "PR Total IO Req.",
       &&prtmbr as "PR Total MBLCK Req.",
       &&prtior-&&prtmbr as "PR Total SBLCK Req.",
       round((100*&&prtmbr)/&&prtior,2) as "MultiBlock Req. (%)",
       round((100*(&&prtior-&&prtmbr))/&&prtior,2) as "SingleBlock Req. (%)"
from dual;

PROMPT *********************************
PROMPT *    I/O Weight by tablespace   *
PROMPT *********************************

col filename format a70
set lines 140 pages 300

select	tsname, 
	round((sum(PHYRDS)+sum(PHYWRTS))*100/&&iototal,2) as "IO weight %",
	round(sum(PHYRDS)*100/&&iototal,2) as "Read weight %",
	round(sum(PHYWRTS)*100/&&iototal,2) as "Write weight %"
from
(
select ENDSNAP.SNAP_ID,
	ENDSNAP.TSNAME,
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
group by tsname
order by 2 desc;

PROMPT *****************************************************
PROMPT *    I/O unitary response time (ms) by tablespace   *
PROMPT *****************************************************

select TSNAME, avg("ASBRT"), avg("AMBRT"), avg("AWT"), avg("Reads(%)"), avg("Writes(%)"), avg("SBR(%)")
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

