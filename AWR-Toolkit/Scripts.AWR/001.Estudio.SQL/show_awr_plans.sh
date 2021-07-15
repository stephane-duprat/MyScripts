#!/bin/ksh

echo "set lines 140 pages 200
select * from table (dbms_xplan.display_awr('$1'));" | sqlplus / as sysdba
