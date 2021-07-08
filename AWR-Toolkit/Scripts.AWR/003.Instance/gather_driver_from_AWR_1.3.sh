#!/bin/ksh
# #####################################################################
# $Header: gather_driver_from_AWR_1.3.sh 01/06/2010 sduprat_es Exp $
#
# gather_driver_from_AWR.sh
#
# Copyright (c) 2010, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     gather_driver_from_AWR_1.3.sh
#
#    USAGE
#     gather_driver_from_AWR.sh <BEGIN AWR SNAPSHOT> <END AWR SNAPSHOT> <INSTANCE_NUMBER> <DBID>
#     gather_driver_from_AWR.sh -show => lists the available snapshots in the database !!!
#
#    DESCRIPTION
#     Collects instance and OS metrics from ASH Views.
#
#    NOTES
#       ### 1) Developped against Oracle RDBMS version 10.2 on Linux
#       ### 2) Successfully tested against Oracle RDBMS version 11.1
#       ### 3) Successfully tested against Solaris 10
#       ### 4) Successfully tested against Oracle Linux 5
#       ### 5) Successfully tested against Oracle RDBMS version 11.2 with 2 RAC instances
#
#   VERSION  MODIFIED        (MM/DD/YY)
#    1.0.0    sduprat_es      01/06/10   - Creation and mastermind
#    1.1.0    sduprat_es      26/10/10   - Adaptive modifications for RAC
#    1.2.0    sduprat_es      10/03/11   - "-show" option to show available snapshots
#                                        - Aditional events:
#                                             => "physical write total IO requests"
#                                             => "physical write total bytes"
#                                             => "physical read total bytes"
#                                             => "physical read total IO requests"
#                                             => "redo writes"
#    1.3.0   sduprat_es       04/10/11   - add instance information with "-show" option
#                                        - dbid passed as fourth argument on the command line
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

WORK=/home/oracle/SDU/work

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

work_file=$WORK/work_$seq.dat
cpu_file=$WORK/wl_cpu_${dbid}_${inst_num}_${bsnap}_${esnap}.dat
io_file=$WORK/wl_io_${dbid}_${inst_num}_${bsnap}_${esnap}.dat
app_file=$WORK/wl_app_${dbid}_${inst_num}_${bsnap}_${esnap}.dat

## Touch CPU and IO files !!!
touch $cpu_file
touch $io_file

event="('redo size','logons cumulative','execute count','db block changes','CPU used by this session','session logical reads','physical reads','user calls','user commits','parse count (total)','parse count (hard)','physical write total IO requests','physical write total bytes','physical read total bytes','physical read total IO requests','redo writes','table fetch continued row','table fetch by rowid','table scans (rowid ranges)','index fast full scans (rowid ranges)','sorts (disk)','sorts (memory)','free buffer requested','free buffer inspected','dirty buffers inspected')"
time_model="('DB CPU','DB time','hard parse elapsed time','parse time elapsed','background cpu time','background elapsed time')"
os_stat="('IDLE_TIME','USER_TIME','SYS_TIME','NUM_CPUS')"

#
# Gather Instance metrics !!!
#

sqlplus $ora_access <<EOF
set heading off feedback off echo off
set linesize 500
col value format 9999999999999
col the_line format a80
col xxx format a5
set appinfo GATHER_DRIVER
spool $work_file

SELECT to_char(END.END_INTERVAL_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.END_INTERVAL_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.END_INTERVAL_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.END_INTERVAL_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) || ',' ||
ENDSTAT.stat_name || '-' || BEG.instance_number || ',' as the_line,
(ENDSTAT.value-BEGSTAT.value) as value, ',good' as xxx
FROM dba_hist_snapshot END,
     dba_hist_snapshot BEG,
     dba_hist_sysstat ENDSTAT,
     dba_hist_sysstat BEGSTAT
WHERE (END.snap_id > $bsnap and END.snap_id <= $esnap)
AND   (BEG.snap_id >= $bsnap and BEG.snap_id < $esnap)
AND   END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.stat_name = ENDSTAT.stat_name
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   ENDSTAT.stat_name in $event
AND   END.instance_number = $inst_num
AND   END.dbid = $dbid
UNION
SELECT to_char(END.END_INTERVAL_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.END_INTERVAL_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.END_INTERVAL_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.END_INTERVAL_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) || ',' ||
ENDSTAT.stat_name|| '-' || BEG.instance_number  || ',' as the_line,
(ENDSTAT.value-BEGSTAT.value) as value, ',good' as xxx
FROM dba_hist_snapshot END,
     dba_hist_snapshot BEG,
     dba_hist_sys_time_model ENDSTAT,
     dba_hist_sys_time_model BEGSTAT
WHERE (END.snap_id > $bsnap and END.snap_id <= $esnap)
AND   (BEG.snap_id >= $bsnap and BEG.snap_id < $esnap)
AND   END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.stat_name = ENDSTAT.stat_name
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   ENDSTAT.stat_name in $time_model
AND   END.instance_number = $inst_num
AND   END.dbid = $dbid
UNION
SELECT to_char(END.END_INTERVAL_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.END_INTERVAL_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.END_INTERVAL_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.END_INTERVAL_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) || ',' ||
ENDSTAT.stat_name || '-' || BEG.instance_number   || ',' as the_line,
decode(ENDSTAT.stat_name,'NUM_CPUS',ENDSTAT.value,(ENDSTAT.value-BEGSTAT.value)) as value, ',good' as xxx
FROM dba_hist_snapshot END,
     dba_hist_snapshot BEG,
     dba_hist_osstat ENDSTAT,
     dba_hist_osstat BEGSTAT
WHERE (END.snap_id > $bsnap and END.snap_id <= $esnap)
AND   (BEG.snap_id >= $bsnap and BEG.snap_id < $esnap)
AND   END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.stat_name = ENDSTAT.stat_name
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   ENDSTAT.stat_name in $os_stat
AND   END.instance_number = $inst_num
AND   END.dbid = $dbid
/
spool off
exit
EOF

# Print general Oracle workload statistics
#
grep good $work_file | grep -v xxx | awk -F, '{print $1 "," $2 "," $3}' >> $app_file

## Generate CPU file from Instance Metric file !!!
##
for snap in `cat $app_file | cut -f1 -d"," | sort -u`
do
    inter=$(echo $snap | cut -f2 -d".")                                       ## Snapshot interval in seconds
    cpu_usr=$(grep "^"$snap $app_file | grep USER_TIME | awk '{ print $NF }') ## CPU User in cs
    cpu_sys=$(grep "^"$snap $app_file | grep SYS_TIME | awk '{ print $NF }')  ## CPU System in cs
    cpu_idl=$(grep "^"$snap $app_file | grep IDLE_TIME | awk '{ print $NF }') ## CPU Idle in cs
    num_cpu=$(grep "^"$snap $app_file | grep NUM_CPUS | awk '{ print $NF }')   ## Num CPUs
    ## 
    ## CPU Usage percentage computation !!!
    ##
    cpu_usr_pct=$(echo "scale=0; "$cpu_usr"/("$inter"*"$num_cpu")" | bc -l)
    cpu_sys_pct=$(echo "scale=0; "$cpu_sys"/("$inter"*"$num_cpu")" | bc -l)
    cpu_idl_pct=$(echo "scale=0; "$cpu_idl"/("$inter"*"$num_cpu")" | bc -l)
    ##
    ## Write the results in the CPU file !!!
    ##
    echo $snap","${cpu_usr_pct}","${cpu_sys_pct}","${cpu_idl_pct} >> $cpu_file
done

# Remove work files
#
rm $work_file
