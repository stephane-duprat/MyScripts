#!/bin/ksh
# #####################################################################
# $Header: graph_dbtime.sh 28/11/2011 sduprat_es Exp $
#
# graph_dbtime.sh
#
# Copyright (c) 2011, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     graph_dbtime.sh
#
#    USAGE
#     graph_dbtime.sh <BEGIN AWR SNAPSHOT> <END AWR SNAPSHOT> <INSTANCE_NUMBER> <DBID>
#     graph_dbtime.sh -show => lists the available snapshots in the database !!!
#
#    DESCRIPTION
#     Collects instance and OS metrics from ASH Views.
#
#    NOTES
#       ### 1) Developped against Oracle RDBMS version 11.2 on Linux
#
#   VERSION  MODIFIED        (MM/DD/YY)
#    1.0.0    sduprat_es      29/11/11   - Creation and mastermind. The main query was freely adapted from "aveact.sql" script (http://ashmasters.com/)
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
col cmd format a50
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


ORACLE_SID="MRWL"                       # ------ Must set
ORACLE_HOME="/opt/oracle/product/10.2.0"  # ------ Must set
LD_LIBRARY_PATH="$ORACLE_HOME/lib"
PATH=$PATH:$ORACLE_HOME/bin

export ORACLE_SID ORACLE_HOME LD_LIBRARY_PATH PATH

ora_access="/ as sysdba"                 # ------ Must set
export ora_access

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

sqlplus $ora_access <<EOF
set echo off term off feedback off lines 140
column f_secs new_value v_secs
column f_samples new_value samples
select 3600 f_secs from dual;
select &v_secs f_samples from dual;
column f_bars new_value v_bars
select 5 f_bars from dual;
column aas format 999.99
column f_graph new_value v_graph
select 30 f_graph from dual;
column graph format a60 
column total format 99999
column npts format 99999
col waits for 99999
col cpu for 9999

select
        tday tm,
        samples npts,
        total/&samples aas,
        substr(
        substr(substr(rpad('+',round((cpu*&v_bars)/&samples),'+') ||
        rpad('-',round((waits*&v_bars)/&samples),'-')  ||
        rpad(' ',p.value * &v_bars,' '),0,(p.value * &v_bars)) ||
        p.value  ||
        substr(rpad('+',round((cpu*&v_bars)/&samples),'+') ||
        rpad('-',round((waits*&v_bars)/&samples),'-')  ||
        rpad(' ',p.value * &v_bars,' '),(p.value * &v_bars),10) ,0,30)
        ,0,&v_graph)
        graph,
        -- total,
        cpu,
        waits
from (
   select
       to_char(sample_time,'DD/MM/YYYY HH24')                   tday
  --    , trunc(to_char(sample_time,'SSSSS')/&v_secs) tmod
     , sum(decode(session_state,'ON CPU',10,decode(session_type,'BACKGROUND',0,10)))  total
     , (max(sample_id) - min(sample_id) + 1 )      samples
     , sum(decode(session_state,'ON CPU' ,10,0))    cpu
     , sum(decode(session_type,'BACKGROUND',0,decode(session_state,'WAITING',10,0))) waits
       /* for waits I want to subtract out the BACKGROUND
          but for CPU I want to count everyon */
   from
      dba_hist_active_sess_history
   where  dbid = $dbid
   and    instance_number = ${inst_num}
   and  snap_id between $bsnap and $esnap
   group by  to_char(sample_time,'DD/MM/YYYY HH24')
) ash,
  (select value 
   from dba_hist_osstat 
   where stat_name = 'NUM_CPUS' 
   and snap_id = $bsnap
   and dbid = $dbid
   and instance_number = ${inst_num}) p
order by to_date(tday,'DD/MM/YYYY HH24')
/
exit
EOF

exit 0
