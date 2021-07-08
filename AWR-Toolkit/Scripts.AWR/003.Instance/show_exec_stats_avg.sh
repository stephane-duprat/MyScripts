#!/bin/ksh

echo "set lines 160 pages 200
select avg(Exec), avg(AVGBG), avg(AVGPR), avg(AVGElapsed), avg(ROWS_PROCESSED_DELTA/Exec)
from 
(
select to_char(B.begin_interval_time,'DD/MM/YYYY HH24:MI') as Beg, A.snap_id, A.sql_id, 
A.executions_delta as Exec, A.buffer_gets_delta , A.disk_reads_delta, A.elapsed_time_delta, A.ROWS_PROCESSED_DELTA,
(A.buffer_gets_delta/A.executions_delta) as AVGBG, (A.disk_reads_delta/A.executions_delta) as AVGPR,
(A.elapsed_time_delta/A.executions_delta) as AVGElapsed
      from dba_hist_sqlstat A , dba_hist_snapshot B
      where A.sql_id = '$1'
      and A.snap_id = B.snap_id
      and A.executions_delta > 0
      order by 2);" | sqlplus / as sysdba
