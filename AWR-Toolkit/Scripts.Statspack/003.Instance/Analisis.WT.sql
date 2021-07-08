-- Tiempo total esperado, en segundos:

define bsnap=76835
define esnap=77253
define inum=2
define dbid=103678672

-- Total waited in micro-seconds !!!
col wt format 9999999999999999999999

select sum(WT) as wt
from 
(
select	event,
	sum("the_value") as WT
from 
(
SELECT	BEG.snap_id,
	BEG.snap_time,
	BEGSTAT.event,
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
group by BEG.snap_id,	BEG.snap_time, BEGSTAT.event
)
group by event
);

--		     WT
-----------------------
	  7694726100537

select CCCP.* from
(
select	V.*,
	round((100*V.wt/7694726100537),2) as pct
from 
(
select	event,
	sum("the_value") as WT
from 
(
SELECT	BEG.snap_id,
	BEG.snap_time,
	BEGSTAT.event,
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
group by BEG.snap_id,	BEG.snap_time, BEGSTAT.event
)
group by event
order by 2 desc
) V
) CCCP
where CCCP.pct > 1;


