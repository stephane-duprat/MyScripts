REM Timed columns are given in seconds !!!

define bsnap=76835
define esnap=77253
define inum=2
define dbid=103678672



set lines 140 pages 400
col fecha format a15

select	V.*,
	round((100*ST/DBTime),2) as "ST (%)",
	round((100*WT/DBTime),2) as "WT (%)"
from (
select	to_char(trunc(snap_time),'DD/MM/YYYY') as fecha,
	sum(ServiceTime) as ST,
	sum(WaitTime) as WT,
	sum(DBTime) as DBTime
from (
select	ST.snap_id,
	ST.snap_time,
	ST."the_value"/100 as ServiceTime,
	WT."the_value"/1000000 as WaitTime,
	((ST."the_value"/100) + (WT."the_value"/1000000)) as DBTime
from 
(
SELECT	BEG.snap_id,
	BEG.snap_time,
	ABS(ABS(ENDSTAT.value)-ABS(BEGSTAT.value)) as "the_value"
FROM PERFSTAT.STATS$SNAPSHOT END,
     PERFSTAT.STATS$SNAPSHOT BEG,
     PERFSTAT.STATS$SYSSTAT ENDSTAT,
     PERFSTAT.STATS$SYSSTAT BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.name = ENDSTAT.name
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   ENDSTAT.name in ('CPU used by this session')
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
) ST,
(
SELECT	BEG.snap_id,
	BEG.snap_time,
	sum(ABS(ABS(ENDSTAT.TIME_WAITED_MICRO)-ABS(BEGSTAT.TIME_WAITED_MICRO))) as "the_value"
FROM PERFSTAT.STATS$SNAPSHOT END,
     PERFSTAT.STATS$SNAPSHOT BEG,
     PERFSTAT.STATS$SYSTEM_EVENT ENDSTAT,
     PERFSTAT.STATS$SYSTEM_EVENT BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.event = ENDSTAT.event
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   ENDSTAT.event not in (select event from PERFSTAT.STATS$IDLE_EVENT)
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
group by BEG.snap_id,	BEG.snap_time
) WT
where ST.snap_id = WT.snap_id)
group by to_char(trunc(snap_time),'DD/MM/YYYY')) V;




