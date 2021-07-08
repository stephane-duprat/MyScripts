#!/bin/ksh

echo "set lines 140 pages 200 
col username format a12
col event format a30
select sid, serial#, status, username, module, sql_id, event
      from v\$session
      where module like '$1%'
      ;" | sqlplus / as sysdba
