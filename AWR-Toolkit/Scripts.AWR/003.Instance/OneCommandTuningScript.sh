#!/bin/ksh
# #####################################################################
# $Header: OneCommandTuningScript.sh 11/06/2013 sduprat_es Exp $
#
# OneCommandTuningScript.sh
#
# Copyright (c) 2013, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     OneCommandTuningScript.sh
#
#    USAGE
#     OneCommandTuningScript.sh <BEGIN AWR SNAPSHOT> <END AWR SNAPSHOT> <Instance Number>  <DBID>
#     gather_driver_from_AWR.sh -show => lists the available snapshots in the database !!!
#
#    DESCRIPTION
#     Collects instance and OS metrics from ASH Views.
#
#    NOTES
#       ### 1) Developped against Oracle RDBMS version 11.2 on Linux
#
#   VERSION  MODIFIED        (MM/DD/YY)
#    1.0.0    sduprat_es      01/06/10   - Creation and mastermind
#
# #####################################################################
#        Make sure to set the "Must set" variables below!
#        DICTIONARY STATS SHOULD BE COLLECTED WITH GATHER_DICTIONARY_STATS BEFORE LAUNCHING THIS SCRIPT: if not, some queries may run quite slow (WT & IO queries)
# Output is placed in a comma delimited file by default as follows:
#
#    /tmp/wl_app.dat seq, statistic name, value

function fn_show_snapshots
{
   ## Shows the available snapshots in the database !!!
   sqlplus $ora_access <<EOF
set lines 160 pages 500
col cmd format a60
col INSTANCE format a10
col DB_NAME format a10
select v.*,'$1 ' || v.bsnap || ' ' || v.esnap || ' ' || v.INSTANCE_NUMBER || ' ' || v.DBID as cmd from (
select B.DBID, B.DB_NAME, B.INSTANCE_NAME as instance, A.INSTANCE_NUMBER, trunc(A.BEGIN_INTERVAL_TIME), min(A.SNAP_ID) as bsnap, max(A.snap_id) as esnap
from dba_hist_snapshot A, DBA_HIST_DATABASE_INSTANCE B
where A.dbid = B.dbid
and   A.INSTANCE_NUMBER = B.INSTANCE_NUMBER
group by B.DBID, B.DB_NAME, B.INSTANCE_NAME, A.INSTANCE_NUMBER, trunc(A.BEGIN_INTERVAL_TIME)
order by 1,2,3,4,5) v;  
exit
EOF

}

. ./perfil.sh ## Carga del entorno

if [ $1 == "-show" ]
then
     fn_show_snapshots $0
     exit 0
fi

## Begin Snapshot , End Snapshot , instance_number and dbid values, passed on the command line.
bsnap=$1
esnap=$2
inst_num=$3
dbid=$4
seq=$esnap"_"$bsnap
OCTSV="1.0.0"

work_file=$WORK/work_$seq_$$.dat
out_file=$WORK/OCTS_${dbid}_${inst_num}_${bsnap}_${esnap}.txt

## Touch out file !!!
touch ${out_file}

echo "OneCommandTuningScript version "$OCTSV > ${work_file}
echo "Generated on "`date` >> ${work_file}
echo " " >> ${work_file}
echo "DBID="$dbid >> ${work_file}
echo "Instance number="${inst_num} >> ${work_file}
echo "Begin snapshot="$bsnap >> ${work_file}
echo "End snapshot="$esnap >> ${work_file}
echo " " >> ${work_file}
#
# Database instance general information 
#

echo " " >> ${work_file}
echo "#########################################################" >> ${work_file}
echo "#### General information                               ##" >> ${work_file}
echo "#########################################################" >> ${work_file}
echo " " >> ${work_file}
echo -e "Gathering general information ...\c"

sqlplus -s $ora_access <<EOF >> ${work_file}
set feedback off echo off
set lines 140
set appinfo OCTS_GENERAL_INFO

start $DSQL/001.OCTS.GENERAL_INFO.sql $dbid ${inst_num} $bsnap $esnap

exit

EOF
echo -e " [ OK ]"

#
# DBTIME REVISION !!!
#

echo " " >> ${work_file}
echo "#########################################################" >> ${work_file}
echo "#### DBTIME REVISION                                   ##" >> ${work_file}
echo "#########################################################" >> ${work_file}
echo " " >> ${work_file}

echo -e "Database time revision ..........\c"
sqlplus -s $ora_access <<EOF >> ${work_file}
set feedback off echo off
set lines 140
set appinfo OCTS_DBTIME_REVISION

start $DSQL/006.OCTS.DBTIME_REVISION.sql $dbid ${inst_num} $bsnap $esnap

exit
EOF
echo -e " [ OK ]"

#
# WAIT TIME REVISION !!!
#

echo " " >> ${work_file}
echo "#########################################################" >> ${work_file}
echo "#### WAIT TIME REVISION                                ##" >> ${work_file}
echo "#########################################################" >> ${work_file}
echo " " >> ${work_file}

echo -e "Wait time revision ..............\c"
sqlplus -s $ora_access <<EOF >> ${work_file}
set feedback off echo off
set lines 140
set appinfo OCTS_WT_REVISION

start $DSQL/002.OCTS.WT_REVISION.sql $dbid ${inst_num} $bsnap $esnap

exit
EOF
echo -e " [ OK ]"

#
# PARSING PROFILE REVISION !!!
#

echo " " >> ${work_file}
echo "#########################################################" >> ${work_file}
echo "#### PARSING PROFILE REVISION                          ##" >> ${work_file}
echo "#########################################################" >> ${work_file}
echo " " >> ${work_file}

echo -e "Parsing profile revision ........\c"
sqlplus -s $ora_access <<EOF >> ${work_file}
set feedback off echo off
set lines 140
set appinfo OCTS_PARSING_REVISION

start $DSQL/003.OCTS.PARSING_REVISION.sql $dbid ${inst_num} $bsnap $esnap

exit
EOF
echo -e " [ OK ]"

#
# SQL REVISION !!!
#

echo " " >> ${work_file}
echo "#########################################################" >> ${work_file}
echo "#### SQL REVISION                                      ##" >> ${work_file}
echo "#########################################################" >> ${work_file}
echo " " >> ${work_file}

echo -e "SQL revision ....................\c"
sqlplus -s $ora_access <<EOF >> ${work_file}
set feedback off echo off
set lines 140
set appinfo OCTS_SQL_REVISION

start $DSQL/004.OCTS.SQL_REVISION.sql $dbid ${inst_num} $bsnap $esnap

exit
EOF
echo -e " [ OK ]"

#
# I/O revision  !!!
#

echo " " >> ${work_file}
echo "#########################################################" >> ${work_file}
echo "#### I/O REVISION                                      ##" >> ${work_file}
echo "#########################################################" >> ${work_file}
echo " " >> ${work_file}

echo -e "I/O revision ....................\c"
sqlplus -s $ora_access <<EOF >> ${work_file}
set feedback off echo off
set lines 140
set appinfo OCTS_IO_REVISION

start $DSQL/005.OCTS.IO_REVISION.sql $dbid ${inst_num} $bsnap $esnap

exit
EOF
echo -e " [ OK ]"

cat ${work_file} | grep -v "^old" | grep -v "^new" > ${out_file}
echo " "
echo "File "${out_file}" generated."
rm ${work_file}
exit 0
