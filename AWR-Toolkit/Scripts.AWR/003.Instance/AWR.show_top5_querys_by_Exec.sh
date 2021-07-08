#!/bin/ksh
# #####################################################################
# $Header: AWR.show_top5_querys_by_Exec.sh 30/03/2011 sduprat_es Exp $
#
# AWR.show_top5_querys_by_Exec.sh
#
# Copyright (c) 2011, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     AWR.show_top5_querys_by_Exec.sh
#
#    USAGE
#     AWR.show_top5_querys_by_Exec.sh <AWR SNAPSHOT> <INSTANCE_NUMBER>
#     AWR.show_top5_querys_by_Exec.sh -show => lists the available snapshots in the database !!!
#
#    DESCRIPTION
#     Collects instance info from ASH Views.
#
#    NOTES
#       ### 1) Developped against Oracle RDBMS version 11.2 on Linux
#
#   VERSION  MODIFIED        (MM/DD/YY)
#    1.0.0    sduprat_es      30/03/11   - Creation and mastermind
#
# #####################################################################
#        Make sure to set the "Must set" variables below!
#
# Output is placed in a comma delimited file by default as follows:
#
#    /tmp/wl_app.dat seq, statistic name, value


function fn_show_snapshots
{
   ## Shows the available snapshots in the database !!!
   sqlplus $ora_access <<EOF
set lines 160 pages 500
col cmd format a70
col INSTANCE format a10
col DB_NAME format a10
select v.*,'$1 ' || v.bsnap || ' ' || v.INSTANCE_NUMBER || ' ' || v.DBID as cmd from (
select B.DBID, B.DB_NAME, B.INSTANCE_NAME as instance, A.INSTANCE_NUMBER, trunc(A.BEGIN_INTERVAL_TIME), min(A.SNAP_ID) as bsnap, max(A.snap_id) as esnap
from dba_hist_snapshot A, DBA_HIST_DATABASE_INSTANCE B
where A.dbid = B.dbid
and   A.INSTANCE_NUMBER = B.INSTANCE_NUMBER
group by B.DBID, B.DB_NAME, B.INSTANCE_NAME, A.INSTANCE_NUMBER, trunc(A.BEGIN_INTERVAL_TIME)
order by 1,2,3,4,5) v;  
exit
EOF

}


. ./perfil.sh

if [ $1 == "-show" ]
then
     fn_show_snapshots $0
     exit 0
fi

## Begin Snapshot and instance_number (RAC) values, passed on the command line.
bsnap=$1
inst_num=$2
dbid=$3

#
# Gather Instance metrics !!!
#

sqlplus -s $ora_access <<EOF
set heading on feedback off echo off
set linesize 500
col "Begin Snap=$bsnap - Instance=$inst_num" format a68

select V."Begin Snap=$bsnap - Instance=$inst_num" ,
       V.TotalMetric as TotalMetric,
       V.TotalExec as TotalExec,
       V.TotalMetric/V.TotalExec as BGPerExec
from (
SELECT to_char(BEG.END_INTERVAL_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.BEGIN_INTERVAL_TIME,'YYYYMMDDHH24MI') || ',' ||
BEGSTAT.sql_id || ',' as "Begin Snap=$bsnap - Instance=$inst_num",
sum(BEGSTAT.EXECUTIONS_DELTA) as TotalMetric,
sum(BEGSTAT.EXECUTIONS_DELTA) as TotalExec
FROM dba_hist_snapshot BEG,
     dba_hist_sqlstat BEGSTAT
WHERE (BEG.snap_id = $bsnap)
AND   BEG.dbid = $dbid
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEG.instance_number = $inst_num
AND   BEG.instance_number = BEGSTAT.instance_number
AND   BEG.dbid = BEGSTAT.dbid
group by to_char(BEG.END_INTERVAL_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.BEGIN_INTERVAL_TIME,'YYYYMMDDHH24MI') || ',' ||
BEGSTAT.sql_id || ','
having sum(BEGSTAT.EXECUTIONS_DELTA) > 0
order by 2 desc
) V where rownum < 6
/
exit
EOF

# Remove work files
#
