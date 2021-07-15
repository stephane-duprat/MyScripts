define bsnap=12343
define esnap=13050
define dbid=243561075

--- DIRECT READS !!!


SELECT snaps.id,
snaps.tm,
snaps.dur,
snaps.instances,
((sysstat.PhysReads
- lag (sysstat.PhysReads,1) over (order by snaps.id)))/dur/60 PhysReads,
((sysstat.PhysReadsDirect
- lag (sysstat.PhysReadsDirect,1) over (order by snaps.id)))/dur/60 PhysReadsDirect
FROM
(
/* DBA_HIST_SNAPSHOT */
SELECT DISTINCT id,
dbid,
tm,
instances,
MAX(dur) over (partition BY id) dur
FROM
( SELECT DISTINCT s.snap_id id,
s.dbid,
TO_CHAR(s.end_interval_time,'DD-MON-RR HH24:MI') tm,
COUNT(s.instance_number) over (partition BY snap_id) instances,
1440*((CAST(s.end_interval_time AS DATE) - lag(CAST(s.end_interval_time AS DATE),1) over
(order by s.snap_id))) dur
FROM dba_hist_snapshot s
where s.dbid=&&dbid
and   s.snap_id between &&bsnap and &&esnap
)
) snaps,
(
/* DBA_HIST_SYSSTAT */
SELECT *
FROM
(SELECT snap_id, dbid, stat_name, value FROM dba_hist_sysstat
) pivot (SUM(value) FOR (stat_name) IN ('physical reads' AS PhysReads, 'physical reads direct'
AS PhysReadsDirect))
) sysstat
WHERE dur
> 0
AND snaps.id =sysstat.snap_id
AND snaps.dbid=sysstat.dbid
ORDER BY id ASC
/

select PR,PRD,round((PRD*100)/PR,2) as PCT
from (
select sum(PhysReads) as PR,
       sum(PhysReadsDirect) as PRD
from (
SELECT snaps.id,
snaps.tm,
snaps.dur,
snaps.instances,
((sysstat.PhysReads
- lag (sysstat.PhysReads,1) over (order by snaps.id)))/dur/60 PhysReads,
((sysstat.PhysReadsDirect
- lag (sysstat.PhysReadsDirect,1) over (order by snaps.id)))/dur/60 PhysReadsDirect
FROM
(
/* DBA_HIST_SNAPSHOT */
SELECT DISTINCT id,
dbid,
tm,
instances,
MAX(dur) over (partition BY id) dur
FROM
( SELECT DISTINCT s.snap_id id,
s.dbid,
TO_CHAR(s.end_interval_time,'DD-MON-RR HH24:MI') tm,
COUNT(s.instance_number) over (partition BY snap_id) instances,
1440*((CAST(s.end_interval_time AS DATE) - lag(CAST(s.end_interval_time AS DATE),1) over
(order by s.snap_id))) dur
FROM dba_hist_snapshot s
where s.dbid=&&dbid
and   s.snap_id between &&bsnap and &&esnap
)
) snaps,
(
/* DBA_HIST_SYSSTAT */
SELECT *
FROM
(SELECT snap_id, dbid, stat_name, value FROM dba_hist_sysstat
) pivot (SUM(value) FOR (stat_name) IN ('physical reads' AS PhysReads, 'physical reads direct'
AS PhysReadsDirect))
) sysstat
WHERE dur
> 0
AND snaps.id =sysstat.snap_id
AND snaps.dbid=sysstat.dbid
ORDER BY id ASC
))
/

--- Multiblock vs Single Block !!!

select V.*, (V.PhysReadsReq-V.PhysReadsMBlock) as PhysReadsSBlock
from (
SELECT snaps.id,
snaps.tm,
snaps.dur,
snaps.instances,
((sysstat.PhysReadsReq
- lag (sysstat.PhysReadsReq,1) over (order by snaps.id)))/dur/60 PhysReadsReq,
((sysstat.PhysReadsMBlock
- lag (sysstat.PhysReadsMBlock,1) over (order by snaps.id)))/dur/60 PhysReadsMBlock
FROM
(
/* DBA_HIST_SNAPSHOT */
SELECT DISTINCT id,
dbid,
tm,
instances,
MAX(dur) over (partition BY id) dur
FROM
( SELECT DISTINCT s.snap_id id,
s.dbid,
TO_CHAR(s.end_interval_time,'DD-MON-RR HH24:MI') tm,
COUNT(s.instance_number) over (partition BY snap_id) instances,
1440*((CAST(s.end_interval_time AS DATE) - lag(CAST(s.end_interval_time AS DATE),1) over
(order by s.snap_id))) dur
FROM dba_hist_snapshot s
where s.dbid=&&dbid
and   s.snap_id between &&bsnap and &&esnap
)
) snaps,
(
/* DBA_HIST_SYSSTAT */
SELECT *
FROM
(SELECT snap_id, dbid, stat_name, value FROM dba_hist_sysstat
) pivot (SUM(value) FOR (stat_name) IN ('physical read total IO requests' AS PhysReadsReq, 'physical read total multi block requests'
AS PhysReadsMBlock))
) sysstat
WHERE dur
> 0
AND snaps.id =sysstat.snap_id
AND snaps.dbid=sysstat.dbid
ORDER BY id ASC) V
/

select	W.*, 
	round((W.PhysReadsMBlock*100)/W.PhysReadsReq,2) as "MultiblockReads (%)",
	round((W.PhysReadsSBlock*100)/W.PhysReadsReq,2) as "SingleblockReads (%)"
from 
(
select sum(V.PhysReadsReq) as PhysReadsReq,
       sum(V.PhysReadsMBlock) as PhysReadsMBlock,
       sum(V.PhysReadsReq-V.PhysReadsMBlock) as PhysReadsSBlock
from (
SELECT snaps.id,
snaps.tm,
snaps.dur,
snaps.instances,
((sysstat.PhysReadsReq
- lag (sysstat.PhysReadsReq,1) over (order by snaps.id)))/dur/60 PhysReadsReq,
((sysstat.PhysReadsMBlock
- lag (sysstat.PhysReadsMBlock,1) over (order by snaps.id)))/dur/60 PhysReadsMBlock
FROM
(
/* DBA_HIST_SNAPSHOT */
SELECT DISTINCT id,
dbid,
tm,
instances,
MAX(dur) over (partition BY id) dur
FROM
( SELECT DISTINCT s.snap_id id,
s.dbid,
TO_CHAR(s.end_interval_time,'DD-MON-RR HH24:MI') tm,
COUNT(s.instance_number) over (partition BY snap_id) instances,
1440*((CAST(s.end_interval_time AS DATE) - lag(CAST(s.end_interval_time AS DATE),1) over
(order by s.snap_id))) dur
FROM dba_hist_snapshot s
where s.dbid=&&dbid
and   s.snap_id between &&bsnap and &&esnap
)
) snaps,
(
/* DBA_HIST_SYSSTAT */
SELECT *
FROM
(SELECT snap_id, dbid, stat_name, value FROM dba_hist_sysstat
) pivot (SUM(value) FOR (stat_name) IN ('physical read total IO requests' AS PhysReadsReq, 'physical read total multi block requests'
AS PhysReadsMBlock))
) sysstat
WHERE dur
> 0
AND snaps.id =sysstat.snap_id
AND snaps.dbid=sysstat.dbid
ORDER BY id ASC) V ) W
/




-- OPTIMIZED READS (query for Exadata FlashCache eficiency) !!!

SELECT snaps.id,
snaps.tm,
snaps.dur,
snaps.instances,
((sysstat.PhysReads
- lag (sysstat.PhysReads,1) over (order by snaps.id)))/dur/60 PhysReads,
((sysstat.PhysReadsOpt
- lag (sysstat.PhysReadsOpt,1) over (order by snaps.id)))/dur/60 PhysReadsOpt
FROM
(
/* DBA_HIST_SNAPSHOT */
SELECT DISTINCT id,
dbid,
tm,
instances,
MAX(dur) over (partition BY id) dur
FROM
( SELECT DISTINCT s.snap_id id,
s.dbid,
TO_CHAR(s.end_interval_time,'DD-MON-RR HH24:MI') tm,
COUNT(s.instance_number) over (partition BY snap_id) instances,
1440*((CAST(s.end_interval_time AS DATE) - lag(CAST(s.end_interval_time AS DATE),1) over
(order by s.snap_id))) dur
FROM dba_hist_snapshot s
where s.dbid=&&dbid
and   s.snap_id between &&bsnap and &&esnap
)
) snaps,
(
/* DBA_HIST_SYSSTAT */
SELECT *
FROM
(SELECT snap_id, dbid, stat_name, value FROM dba_hist_sysstat
) pivot (SUM(value) FOR (stat_name) IN ('physical read total IO requests' AS PhysReads, 'physical read requests optimized'
AS PhysReadsOpt))
) sysstat
WHERE dur
> 0
AND snaps.id =sysstat.snap_id
AND snaps.dbid=sysstat.dbid
ORDER BY id ASC
/

select PR,PRD,round((PRD*100)/PR,2) as PCT
from (
select sum(PhysReads) as PR,
       sum(PhysReadsDirect) as PRD
from (
SELECT snaps.id,
snaps.tm,
snaps.dur,
snaps.instances,
((sysstat.PhysReads
- lag (sysstat.PhysReads,1) over (order by snaps.id)))/dur/60 PhysReads,
((sysstat.PhysReadsDirect
- lag (sysstat.PhysReadsDirect,1) over (order by snaps.id)))/dur/60 PhysReadsDirect
FROM
(
/* DBA_HIST_SNAPSHOT */
SELECT DISTINCT id,
dbid,
tm,
instances,
MAX(dur) over (partition BY id) dur
FROM
( SELECT DISTINCT s.snap_id id,
s.dbid,
TO_CHAR(s.end_interval_time,'DD-MON-RR HH24:MI') tm,
COUNT(s.instance_number) over (partition BY snap_id) instances,
1440*((CAST(s.end_interval_time AS DATE) - lag(CAST(s.end_interval_time AS DATE),1) over
(order by s.snap_id))) dur
FROM dba_hist_snapshot s
where s.dbid=&&dbid
and   s.snap_id between &&bsnap and &&esnap
)
) snaps,
(
/* DBA_HIST_SYSSTAT */
SELECT *
FROM
(SELECT snap_id, dbid, stat_name, value FROM dba_hist_sysstat
) pivot (SUM(value) FOR (stat_name) IN ('physical reads' AS PhysReads, 'physical reads direct'
AS PhysReadsDirect))
) sysstat
WHERE dur
> 0
AND snaps.id =sysstat.snap_id
AND snaps.dbid=sysstat.dbid
ORDER BY id ASC
))
/


