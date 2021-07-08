#!/bin/ksh

echo "set lines 160 pages 200
select to_char(B.begin_interval_time,'DD/MM/YYYY HH24:MI') as Beg, A.snap_id, A.instance_number as inum, A.sql_id, 
A.executions_delta as Exec, A.buffer_gets_delta as BG, A.disk_reads_delta as DR, A.elapsed_time_delta as ET, A.ROWS_PROCESSED_DELTA,
(A.buffer_gets_delta/decode(A.executions_delta,0,1,A.executions_delta)) as AVGBG, (A.disk_reads_delta/decode(A.executions_delta,0,1,A.executions_delta)) as AVGPR,
(A.elapsed_time_delta/decode(A.executions_delta,0,1,A.executions_delta)) as AVGElapsed
      from dba_hist_sqlstat A , dba_hist_snapshot B
      where A.sql_id = '$1'
      and A.snap_id = B.snap_id
      and A.executions_delta >= 0
      and A.dbid = B.dbid
      and A.instance_number = B.instance_number
      order by 2;" | sqlplus / as sysdba
