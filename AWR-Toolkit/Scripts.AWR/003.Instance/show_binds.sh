#!/bin/ksh

echo "set lines 140 pages 200
col VALUE_STRING format a30
select to_char(B.begin_interval_time,'DD/MM/YYYY HH24:MI') as Beg, A.snap_id, A.sql_id, A.name, A.position , A.DATATYPE_STRING,A.VALUE_STRING
      from dba_hist_sqlbind A , dba_hist_snapshot B
      where A.sql_id = '$1'
      and A.snap_id = B.snap_id
      order by 2,5;" | sqlplus / as sysdba
