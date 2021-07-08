#!/bin/ksh

echo "set lines 140 pages 200
define inum=1
define bsnap=76617
define dbid=103678672
col the_time format a18
select CCCP.*, (CCCP.Gets/CCCP.exec) as AVGBG, (CCCP.Reads/CCCP.exec) as AVGReads, (CCCP.Elapsed/(1000000*CCCP.exec)) as \"AVGElpsd(s)\"
from (
SELECT to_char(BEG.SNAP_TIME,'DD/MM/YYYY HH24:MI') as the_time,
BEG.snap_id,
ENDSTAT.hash_value as sql_id,
ABS(ABS(ENDSTAT.executions)-ABS(BEGSTAT.executions)) as exec,
ABS(ABS(ENDSTAT.buffer_gets)-ABS(BEGSTAT.buffer_gets)) as Gets,
ABS(ABS(ENDSTAT.disk_reads)-ABS(BEGSTAT.disk_reads)) as Reads,
ABS(ABS(ENDSTAT.ELAPSED_TIME)-ABS(BEGSTAT.ELAPSED_TIME)) as Elapsed
FROM PERFSTAT.STATS\$SNAPSHOT END,
     PERFSTAT.STATS\$SNAPSHOT BEG,
     PERFSTAT.STATS\$SQL_SUMMARY ENDSTAT,
     PERFSTAT.STATS\$SQL_SUMMARY BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.hash_value = ENDSTAT.hash_value
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
AND   BEGSTAT.hash_value = $1
order by 2) CCCP
where CCCP.exec > 0;" | sqlplus "/ as sysdba"
