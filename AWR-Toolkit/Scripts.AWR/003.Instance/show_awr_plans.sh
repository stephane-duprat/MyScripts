#!/bin/ksh

echo "set lines 140 pages 200
select * from table (dbms_xplan.display_awr('$1',null,1134630566));" | sqlplus / as sysdba
