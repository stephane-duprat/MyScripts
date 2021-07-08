#!/bin/ksh

echo "set lines 140 pages 200 long 1000000
select sql_text 
      from dba_hist_sqltext A
      where A.sql_id = '$1'
      ;" | sqlplus / as sysdba

echo "set lines 140 pages 200 long 1000000
select sql_fulltext 
      from v\$sql A
      where A.sql_id = '$1'
      ;" | sqlplus / as sysdba
