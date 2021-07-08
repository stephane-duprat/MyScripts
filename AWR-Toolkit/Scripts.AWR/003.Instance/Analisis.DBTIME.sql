define bsnap=12926
define esnap=13248
define inum=1
define dbid=1318684407


-- For 11g and forward !!!

set lines 140 pages 400

select V.*, (V.DBTIME - V.DBCPU) as ComputedWaitTime, (V.DBCPU + V.FGWT) as ComputedDBTime,
	round(100*V.DBCPU/(V.DBCPU + V.FGWT),2) as STPct,
	round(100*V.FGWT/(V.DBCPU + V.FGWT),2) as WTPct
from (
select	trunc(fecha),
	round(sum(decode(stat_name,'DB time',value,0)),2) as DBTIME,
	round(sum(decode(stat_name,'DB CPU',value,0)),2) as DBCPU,
	round(sum(decode(stat_name,'Foreground Wait Time',value,0)),2) as FGWT
from (
SELECT	BEG.BEGIN_INTERVAL_TIME as fecha,
	ENDSTAT.stat_name,
	(ENDSTAT.value-BEGSTAT.value)/1000000 as value
FROM dba_hist_snapshot END,
     dba_hist_snapshot BEG,
     dba_hist_sys_time_model ENDSTAT,
     dba_hist_sys_time_model BEGSTAT
WHERE (END.snap_id > &&bsnap and END.snap_id <= &&esnap)
AND   (BEG.snap_id >= &&bsnap and BEG.snap_id < &&esnap)
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
AND   ENDSTAT.stat_name in ('DB CPU','DB time')
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
UNION
SELECT	BEG.BEGIN_INTERVAL_TIME as fecha,
	'Foreground Wait Time' as stat_name,
	sum((NVL(ENDSTAT.TIME_WAITED_MICRO_FG,ENDSTAT.TIME_WAITED_MICRO)-NVL(BEGSTAT.TIME_WAITED_MICRO_FG,BEGSTAT.TIME_WAITED_MICRO))/1000000) as value
FROM dba_hist_snapshot END,
     dba_hist_snapshot BEG,
     dba_hist_system_event ENDSTAT,
     dba_hist_system_event BEGSTAT
WHERE (BEG.snap_id between &&bsnap and &&esnap)
AND   BEG.dbid = &&dbid
AND   BEG.dbid = BEGSTAT.dbid
AND   BEG.dbid = ENDSTAT.dbid
AND   BEG.dbid = END.dbid
AND   END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.WAIT_CLASS NOT IN ('Idle')
AND   BEGSTAT.WAIT_CLASS = ENDSTAT.WAIT_CLASS
AND   BEGSTAT.EVENT_NAME = ENDSTAT.EVENT_NAME
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.instance_number = &&inum
group by BEG.BEGIN_INTERVAL_TIME
)
group by trunc(fecha)
) V
order by 1;

-- For 10g !!!
set lines 140 pages 400

select V.*, (V.DBTIME - V.DBCPU) as ComputedWaitTime, (V.DBCPU + V.FGWT) as ComputedDBTime,
	round(100*V.DBCPU/(V.DBCPU + V.FGWT),2) as STPct,
	round(100*V.FGWT/(V.DBCPU + V.FGWT),2) as WTPct
from (
select	trunc(fecha),
	round(sum(decode(stat_name,'DB time',value,0)),2) as DBTIME,
	round(sum(decode(stat_name,'DB CPU',value,0)),2) as DBCPU,
	round(sum(decode(stat_name,'Foreground Wait Time',value,0)),2) as FGWT
from (
SELECT	BEG.BEGIN_INTERVAL_TIME as fecha,
	ENDSTAT.stat_name,
	(ENDSTAT.value-BEGSTAT.value)/1000000 as value
FROM dba_hist_snapshot END,
     dba_hist_snapshot BEG,
     dba_hist_sys_time_model ENDSTAT,
     dba_hist_sys_time_model BEGSTAT
WHERE (END.snap_id > &&bsnap and END.snap_id <= &&esnap)
AND   (BEG.snap_id >= &&bsnap and BEG.snap_id < &&esnap)
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
AND   ENDSTAT.stat_name in ('DB CPU','DB time')
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
UNION
SELECT	BEG.BEGIN_INTERVAL_TIME as fecha,
	'Foreground Wait Time' as stat_name,
	sum((ENDSTAT.TIME_WAITED_MICRO-BEGSTAT.TIME_WAITED_MICRO)/1000000) as value
FROM dba_hist_snapshot END,
     dba_hist_snapshot BEG,
     dba_hist_system_event ENDSTAT,
     dba_hist_system_event BEGSTAT
WHERE (BEG.snap_id between &&bsnap and &&esnap)
AND   BEG.dbid = &&dbid
AND   BEG.dbid = BEGSTAT.dbid
AND   BEG.dbid = ENDSTAT.dbid
AND   BEG.dbid = END.dbid
AND   END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.WAIT_CLASS NOT IN ('Idle')
AND   BEGSTAT.WAIT_CLASS = ENDSTAT.WAIT_CLASS
AND   BEGSTAT.EVENT_NAME = ENDSTAT.EVENT_NAME
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.instance_number = &&inum
group by BEG.BEGIN_INTERVAL_TIME
)
group by trunc(fecha)
) V
order by 1;