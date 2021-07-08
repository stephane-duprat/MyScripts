#!/bin/ksh
# #####################################################################
# $Header: graph_dbtime_w.sh 28/11/2011 sduprat_es Exp $
#
# graph_dbtime.sh
#
# Copyright (c) 2011, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     graph_dbtime_w.sh
#
#    USAGE
#     graph_dbtime_w.sh <BEGIN AWR SNAPSHOT> <END AWR SNAPSHOT> <INSTANCE_NUMBER> <DBID>
#     graph_dbtime_w.sh -show => lists the available snapshots in the database !!!
#
#    DESCRIPTION
#     Collects instance and OS metrics from ASH Views.
#
#    NOTES
#       ### 1) Developped against Oracle RDBMS version 11.2 on Linux
#
#   VERSION  MODIFIED        (MM/DD/YY)
#    1.0.0    sduprat_es      01/12/11   - Creation and mastermind. The main query was freely adapted from "aveactn.sql" script (http://ashmasters.com/)
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

. ./perfil.sh ## Carga del entorno !!!

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
tmp=/tmp/$$.tmp

sqlplus $ora_access > $tmp <<EOF
set echo off term off feedback off lines 140

Def v_secs=3600 --  bucket size
Def v_days=1 --  total time analyze
Def v_bars=5 -- size of one AAS in characters

col aveact format 999.99
col graph format a50
col fpct format 9.99
col spct format 9.99
col tpct format 9.99
col aas1 format 9.99
col aas2 format 9.99

select to_char(start_time,'DD/MM/YYYY HH24:MI') as "BEGIN TIME",
       samples,
       round(fpct * (total/&v_secs),2) aas1,
       decode(fpct,null,null,first) first,
       round(spct * (total/&v_secs),2) aas2,
       decode(spct,null,null,second) second,
        substr(substr(rpad('+',round((cpu*&v_bars)/&v_secs),'+') ||
        rpad('-',round((waits*&v_bars)/&v_secs),'-')  ||
        rpad(' ',p.value * &v_bars,' '),0,(p.value * &v_bars)) ||
        p.value  ||
        substr(rpad('+',round((cpu*&v_bars)/&v_secs),'+') ||
        rpad('-',round((waits*&v_bars)/&v_secs),'-')  ||
        rpad(' ',p.value * &v_bars,' '),(p.value * &v_bars),10) ,0,50)
        graph
from (
select start_time
     , max(samples) samples
     , sum(top.total) total
     , round(max(decode(top.seq,1,pct,null)),2) fpct 
     , substr(max(decode(top.seq,1,decode(top.event,'ON CPU','CPU',event),null)),0,15) first
     , round(max(decode(top.seq,2,pct,null)),2) spct
     , substr(max(decode(top.seq,2,decode(top.event,'ON CPU','CPU',event),null)),0,15) second
     , round(max(decode(top.seq,3,pct,null)),2) tpct
     , substr(max(decode(top.seq,3,decode(top.event,'ON CPU','CPU',event),null)),0,10) third
     , sum(waits) waits
     , sum(cpu) cpu
from (
  select
       to_date(tday||' '||tmod*&v_secs,'YYMMDD SSSSS') start_time
     , event
     , total
     , row_number() over ( partition by id order by total desc ) seq
     , ratio_to_report( sum(total)) over ( partition by id ) pct
     , max(samples) samples
     , sum(decode(event,'ON CPU',total,0))    cpu
     , sum(decode(event,'ON CPU',0,total))    waits
  from (
    select
         to_char(sample_time,'YYMMDD')                      tday
       , trunc(to_char(sample_time,'SSSSS')/&v_secs)          tmod
       , to_char(sample_time,'YYMMDD')||trunc(to_char(sample_time,'SSSSS')/&v_secs) id
       , decode(ash.session_state,'ON CPU','ON CPU',ash.event)     event
       , sum(decode(session_state,'ON CPU',10,decode(session_type,'BACKGROUND',0,10))) total
       , (max(sample_id)-min(sample_id)+1)                    samples
     from
        dba_hist_active_sess_history ash
     where
           dbid = $dbid
     and   instance_number = ${inst_num}
     and   snap_id between $bsnap and $esnap
     group by  trunc(to_char(sample_time,'SSSSS')/&v_secs)
            ,  to_char(sample_time,'YYMMDD')
            ,  decode(ash.session_state,'ON CPU','ON CPU',ash.event)
  )  chunks
  group by id, tday, tmod, event, total
) top
group by start_time
) aveact,
  (select value 
   from dba_hist_osstat 
   where stat_name = 'NUM_CPUS' 
   and snap_id = $bsnap
   and dbid = $dbid
   and instance_number = ${inst_num}) p
order by start_time
/
exit
EOF

echo " "
cat $tmp | grep -A1 "BEGIN TIME" | tail -2
cat $tmp | grep "^[0-9][0-9]/[0-1][0-9]"
echo " "

rm $tmp 2>/dev/null
exit 0
