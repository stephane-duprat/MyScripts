define bsnap=12926
define esnap=13213
define dbid=1318684407

select snaps.id, snaps.tm,snaps.dur,
osstat.num_cpus CPUs,
(((timemodel.dbt -lag(timemodel.dbt,1) over (order by snaps.id)))/1000000)/dur/60
aas ,
round(100*(((((timemodel.dbc - lag(timemodel.dbc,1) over (order by
snaps.id)))/1000000) +
(((timemodel.bgc - lag(timemodel.bgc,1) over (order by snaps.id)))/1000000)) /
(osstat.num_cpus * 60 * dur)),2) oracpupct,
greatest((((timemodel.dbt - lag(timemodel.dbt,1) over (order by
snaps.id)))/1000000)/dur/60,
osstat.num_cpus * ((((((timemodel.dbc - lag(timemodel.dbc,1) over (order by
snaps.id)))/1000000) +
(((timemodel.bgc - lag(timemodel.bgc,1) over (order by snaps.id)))/1000000)) /
(osstat.num_cpus * 60 * dur)))) cpuneed
from
( /* DBA_HIST_SNAPSHOT */
select distinct id,dbid,tm,instances,max(dur) over (partition by id) dur from (
select distinct s.snap_id id, s.dbid,
to_char(s.end_interval_time,'DD-MON-RR HH24:MI') tm,
count(s.instance_number) over (partition by snap_id) instances,
1440*((cast(s.end_interval_time as date)
- lag(cast(s.end_interval_time as date),1) over (order by s.snap_id))) dur
from
dba_hist_snapshot s
where s.dbid=&&dbid
and   s.snap_id between &&bsnap and &&esnap)
) snaps,
( /* Data from DBA_HIST_OSSTAT */
select *
from
(select snap_id,dbid,stat_name,value from
dba_hist_osstat
) pivot
(sum(value) for (stat_name)
in ('NUM_CPUS' as num_cpus,'BUSY_TIME' as busy_time,'LOAD' as load,'USER_TIME' as
user_time,
'SYS_TIME' as sys_time, 'IOWAIT_TIME' as iowait_time))
) osstat,
( /* DBA_HIST_TIME_MODEL */
select * from
(select snap_id,dbid,stat_name,value from
dba_hist_sys_time_model
) pivot
(sum(value) for (stat_name)
in ('DB time' as dbt, 'DB CPU' as dbc, 'background cpu time' as bgc,
'RMAN cpu time (backup/restore)' as rmanc))
) timemodel
where dur > 0
and snaps.id=osstat.snap_id
and snaps.dbid=osstat.dbid
and snaps.id=timemodel.snap_id
and snaps.dbid=timemodel.dbid
order by id asc
/


select max(aas), max(oracpupct), max(cpuneed)
from (
select snaps.id, snaps.tm,snaps.dur,
osstat.num_cpus CPUs,
(((timemodel.dbt -lag(timemodel.dbt,1) over (order by snaps.id)))/1000000)/dur/60
aas ,
round(100*(((((timemodel.dbc - lag(timemodel.dbc,1) over (order by
snaps.id)))/1000000) +
(((timemodel.bgc - lag(timemodel.bgc,1) over (order by snaps.id)))/1000000)) /
(osstat.num_cpus * 60 * dur)),2) oracpupct,
greatest((((timemodel.dbt - lag(timemodel.dbt,1) over (order by
snaps.id)))/1000000)/dur/60,
osstat.num_cpus * ((((((timemodel.dbc - lag(timemodel.dbc,1) over (order by
snaps.id)))/1000000) +
(((timemodel.bgc - lag(timemodel.bgc,1) over (order by snaps.id)))/1000000)) /
(osstat.num_cpus * 60 * dur)))) cpuneed
from
( /* DBA_HIST_SNAPSHOT */
select distinct id,dbid,tm,instances,max(dur) over (partition by id) dur from (
select distinct s.snap_id id, s.dbid,
to_char(s.end_interval_time,'DD-MON-RR HH24:MI') tm,
count(s.instance_number) over (partition by snap_id) instances,
1440*((cast(s.end_interval_time as date)
- lag(cast(s.end_interval_time as date),1) over (order by s.snap_id))) dur
from
dba_hist_snapshot s
where s.dbid=&&dbid
and   s.snap_id between &&bsnap and &&esnap)
) snaps,
( /* Data from DBA_HIST_OSSTAT */
select *
from
(select snap_id,dbid,stat_name,value from
dba_hist_osstat
) pivot
(sum(value) for (stat_name)
in ('NUM_CPUS' as num_cpus,'BUSY_TIME' as busy_time,'LOAD' as load,'USER_TIME' as
user_time,
'SYS_TIME' as sys_time, 'IOWAIT_TIME' as iowait_time))
) osstat,
( /* DBA_HIST_TIME_MODEL */
select * from
(select snap_id,dbid,stat_name,value from
dba_hist_sys_time_model
) pivot
(sum(value) for (stat_name)
in ('DB time' as dbt, 'DB CPU' as dbc, 'background cpu time' as bgc,
'RMAN cpu time (backup/restore)' as rmanc))
) timemodel
where dur > 0
and snaps.id=osstat.snap_id
and snaps.dbid=osstat.dbid
and snaps.id=timemodel.snap_id
and snaps.dbid=timemodel.dbid
order by id asc
)
/



