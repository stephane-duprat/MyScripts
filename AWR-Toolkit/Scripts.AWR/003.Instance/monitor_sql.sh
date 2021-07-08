#!/bin/ksh

echo "set lines 140 pages 200 
 select EXECUTIONS, DISK_READS, BUFFER_GETS, USER_IO_WAIT_TIME, ROWS_PROCESSED, ELAPSED_TIME, CPU_TIME
 from v\$sql where sql_id = '$1'
      ;" | sqlplus / as sysdba
