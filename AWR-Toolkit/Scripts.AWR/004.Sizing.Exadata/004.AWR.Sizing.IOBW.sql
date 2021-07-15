define bsnap=12926
define esnap=13213
define dbid=1318684407
define dbblcksiz=2048

select snaps.id, snaps.tm,snaps.dur,snaps.instances,
(( (bs.db_block_size * (sysstat.IOmbpsr - lag (sysstat.IOmbpsr,1) over (order by
snaps.id)))/1024/1024))/dur/60 IOmbpsr,
(( (bs.db_block_size * (sysstat.IOmbpsw - lag (sysstat.IOmbpsw,1) over (order by
snaps.id)))/1024/1024))/dur/60 IOmbpsw,
(( ((sysstat.IOmbpsredo - lag (sysstat.IOmbpsredo,1) over (order by
snaps.id)))/1024/1024))/dur/60 IOmbpsredo,
((( (bs.db_block_size * (sysstat.IOmbpsr - lag (sysstat.IOmbpsr,1) over (order by
snaps.id)))/1024/1024))/dur/60) +
((( (bs.db_block_size * (sysstat.IOmbpsw - lag (sysstat.IOmbpsw,1) over (order by
snaps.id)))/1024/1024))/dur/60) +
((( ((sysstat.IOmbpsredo - lag (sysstat.IOmbpsredo,1) over (order by
snaps.id)))/1024/1024))/dur/60) Totmbps,
sysstat.logons_curr ,
((sysstat.logons_cum - lag (sysstat.logons_cum,1) over (order by snaps.id)))/dur/60
logons_cum,
((sysstat.execs - lag (sysstat.execs,1) over (order by snaps.id)))/dur/60 execs
from
( /* DBA_HIST_SNAPSHOT */
select distinct id,dbid,tm,instances,max(dur) over (partition by id) dur from (
select distinct s.snap_id id, s.dbid,
to_char(s.end_interval_time,'DD-MON-RR HH24:MI') tm,
count(s.instance_number) over (partition by snap_id) instances,
1440*((cast(s.end_interval_time as date) - lag(cast(s.end_interval_time as date),1) over
(order by s.snap_id))) dur
FROM dba_hist_snapshot s
where s.dbid=&&dbid
and   s.snap_id between &&bsnap and &&esnap)
) snaps,
( /* DBA_HIST_SYSSTAT */
select * from
(select snap_id, dbid, stat_name, value from
dba_hist_sysstat
) pivot
(sum(value) for (stat_name) in
('logons current' as logons_curr, 'logons cumulative' as logons_cum, 'execute count' as
execs,
'physical reads' as IOmbpsr, 'physical writes' as IOmbpsw,
'redo size' as IOmbpsredo))
) sysstat,
( /* V$PARAMETER: changed to DUAL to get DB_BLOCK_SIZE */
select &&dbblcksiz as db_block_size
from dual
) bs
where dur > 0
and snaps.id=sysstat.snap_id
and snaps.dbid=sysstat.dbid
order by id asc
/

select max(IOmbpsr), max(IOmbpsw), max(IOmbpsredo), max(Totmbps)
from (
select snaps.id, snaps.tm,snaps.dur,snaps.instances,
(( (bs.db_block_size * (sysstat.IOmbpsr - lag (sysstat.IOmbpsr,1) over (order by
snaps.id)))/1024/1024))/dur/60 IOmbpsr,
(( (bs.db_block_size * (sysstat.IOmbpsw - lag (sysstat.IOmbpsw,1) over (order by
snaps.id)))/1024/1024))/dur/60 IOmbpsw,
(( ((sysstat.IOmbpsredo - lag (sysstat.IOmbpsredo,1) over (order by
snaps.id)))/1024/1024))/dur/60 IOmbpsredo,
((( (bs.db_block_size * (sysstat.IOmbpsr - lag (sysstat.IOmbpsr,1) over (order by
snaps.id)))/1024/1024))/dur/60) +
((( (bs.db_block_size * (sysstat.IOmbpsw - lag (sysstat.IOmbpsw,1) over (order by
snaps.id)))/1024/1024))/dur/60) +
((( ((sysstat.IOmbpsredo - lag (sysstat.IOmbpsredo,1) over (order by
snaps.id)))/1024/1024))/dur/60) Totmbps,
sysstat.logons_curr ,
((sysstat.logons_cum - lag (sysstat.logons_cum,1) over (order by snaps.id)))/dur/60
logons_cum,
((sysstat.execs - lag (sysstat.execs,1) over (order by snaps.id)))/dur/60 execs
from
( /* DBA_HIST_SNAPSHOT */
select distinct id,dbid,tm,instances,max(dur) over (partition by id) dur from (
select distinct s.snap_id id, s.dbid,
to_char(s.end_interval_time,'DD-MON-RR HH24:MI') tm,
count(s.instance_number) over (partition by snap_id) instances,
1440*((cast(s.end_interval_time as date) - lag(cast(s.end_interval_time as date),1) over
(order by s.snap_id))) dur
FROM dba_hist_snapshot s
where s.dbid=&&dbid
and   s.snap_id between &&bsnap and &&esnap)
) snaps,
( /* DBA_HIST_SYSSTAT */
select * from
(select snap_id, dbid, stat_name, value from
dba_hist_sysstat
) pivot
(sum(value) for (stat_name) in
('logons current' as logons_curr, 'logons cumulative' as logons_cum, 'execute count' as
execs,
'physical reads' as IOmbpsr, 'physical writes' as IOmbpsw,
'redo size' as IOmbpsredo))
) sysstat,
( /* V$PARAMETER: changed to DUAL to get DB_BLOCK_SIZE */
select &&dbblcksiz as db_block_size
from dual
) bs
where dur > 0
and snaps.id=sysstat.snap_id
and snaps.dbid=sysstat.dbid
order by id asc
)
/

