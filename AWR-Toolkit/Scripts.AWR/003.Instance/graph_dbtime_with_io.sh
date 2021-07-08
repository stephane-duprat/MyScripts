#!/bin/bash
# #####################################################################
# $Header: graph_dbtime_with_io.sh 16/05/2012 sduprat_es Exp $
#
# graph_dbtime_with_io.sh
#
# Copyright (c) 2012, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     graph_dbtime_with_io.sh
#
#    USAGE
#     graph_dbtime_with_io.sh <BEGIN AWR SNAPSHOT> <END AWR SNAPSHOT> <INSTANCE_NUMBER> <DBID>
#     graph_dbtime_with_io.sh -show => lists the available snapshots in the database !!!
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
Def v_graph=80 -- width of graph in characters

col graph format a80       -- Should be equal to v_graph !!!
col aas format 9.99
col cpu format 9.99
col io format 9.99
col wait format 9.99

select 
	to_char(to_date(tday||' '||tmod*&v_secs,'YYMMDD SSSSS'),'DD/MM/YYYY HH24:MI') as "BEGIN TIME",
	samples npts,
	round(total/&v_secs,1) aas,
	round(cpu/&v_secs,1) cpu,
	round(io/&v_secs,1) io,
	round(waits/&v_secs,1) wait,
-- substr, ie trunc, the whole graph to make sure it doesn't overflow
	substr(
-- substr, ie trunc, the graph below the # of CPU cores line
-- draw the whole graph and trunc at # of cores line
		substr(
			rpad('+',round((cpu*&v_bars)/&v_secs),'+')||
			rpad('o',round((io*&v_bars)/&v_secs),'o')||
			rpad('-',round((waits*&v_bars)/&v_secs),'-')||
			rpad(' ',p.value * &v_bars,' '),0,(p.value * &v_bars))||
			p.value||
-- draw the whole graph, then cut off the amount we drew before the # of cores
			substr(
				rpad('+',round((cpu*&v_bars)/&v_secs),'+')||
				rpad('o',round((io*&v_bars)/&v_secs),'o')||
				rpad('-',round((waits*&v_bars)/&v_secs),'-')||
				rpad(' ',p.value * &v_bars,' '),(p.value * &v_bars),( &v_graph-&v_bars*p.value) ), 0,&v_graph) graph
from (
	select
		to_char(sample_time,'YYMMDD') tday
		, trunc(to_char(sample_time,'SSSSS')/&v_secs) tmod
		, (max(sample_id) - min(sample_id) + 1 ) samples
		, sum(decode(session_state,'ON CPU',10,decode(session_type,'BACKGROUND',0,10))) total
		, sum(decode(session_state,'ON CPU' ,10,0)) cpu
		, sum(decode(session_state,'WAITING',10,0)) -
		sum(decode(session_type,'BACKGROUND',decode(session_state,'WAITING',10,0)))-
		sum(decode(event,'db file sequential read',10,
				'db file scattered read',10,
				'db file parallel read',10,
				'direct path read',10,
				'direct path read temp',10,
				'direct path write',10,
				'direct path write temp',10, 0)) waits
		, sum(decode(session_type,'FOREGROUND',
			decode(event,'db file sequential read',10,
			'db file scattered read',10,
			'db file parallel read',10,
			'direct path read',10,
			'direct path read temp',10,
			'direct path write',10,
			'direct path write temp',10, 0))) IO
	from
		dba_hist_active_sess_history
	where dbid = $dbid
	and   instance_number = ${inst_num}
	and   snap_id between $bsnap and $esnap
	group by trunc(to_char(sample_time,'SSSSS')/&v_secs),
	to_char(sample_time,'YYMMDD')
	) ash,
(select value 
from dba_hist_osstat 
where stat_name = 'NUM_CPUS' 
and snap_id = $bsnap
and dbid = $dbid
and instance_number = ${inst_num}) p
order by to_date(tday||' '||tmod*&v_secs,'YYMMDD SSSSS')
/

exit
EOF

echo " "
cat $tmp | grep -A1 "BEGIN TIME" | tail -2
cat $tmp | grep "^[0-9][0-9]/[0-1][0-9]"
echo " "

## rm $tmp 2>/dev/null
exit 0
