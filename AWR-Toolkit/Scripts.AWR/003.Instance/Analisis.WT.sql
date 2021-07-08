-- Tiempo total esperado, en segundos:

define bsnap=12926
define esnap=13213
define inum=1
define dbid=1318684407


-- 11g and forward !!!

select sum(V.TotWaitFgSec)
from (
SELECT ENDSTAT.WAIT_CLASS , ENDSTAT.EVENT_NAME ,
(NVL(ENDSTAT.TOTAL_WAITS_FG,ENDSTAT.TOTAL_WAITS)-NVL(BEGSTAT.TOTAL_WAITS_FG,BEGSTAT.TOTAL_WAITS)) as TotWaitsFg, 
(NVL(ENDSTAT.TIME_WAITED_MICRO_FG,ENDSTAT.TIME_WAITED_MICRO)-NVL(BEGSTAT.TIME_WAITED_MICRO_FG,BEGSTAT.TIME_WAITED_MICRO))/1000000 as TotWaitFgSec
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
) V
where V.TotWaitsFg > 0
and   V.TotWaitFgSec > 0;

SUM(V.TOTWAITFGSEC)
-------------------
	 3061099.29

-- 10g !!!

select sum(V.TotWaitFgSec)
from (
SELECT ENDSTAT.WAIT_CLASS , ENDSTAT.EVENT_NAME ,
(ENDSTAT.TOTAL_WAITS-BEGSTAT.TOTAL_WAITS) as TotWaitsFg, 
(ENDSTAT.TIME_WAITED_MICRO-BEGSTAT.TIME_WAITED_MICRO)/1000000 as TotWaitFgSec
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
) V
where V.TotWaitsFg > 0
and   V.TotWaitFgSec > 0;

-- 2214183,42

col wait_class format a30
col event_name format a30
set lines 140

-- 11g and forward !!!

select X.*, round((X."WaitSec"*100)/381121.569) as "Pct" from (
select V.wait_class, V.event_name , sum(V.TotWaitsFg), sum(V.TotWaitFgSec) as "WaitSec"
from (
SELECT ENDSTAT.WAIT_CLASS , ENDSTAT.EVENT_NAME ,
(NVL(ENDSTAT.TOTAL_WAITS_FG,ENDSTAT.TOTAL_WAITS)-NVL(BEGSTAT.TOTAL_WAITS_FG,BEGSTAT.TOTAL_WAITS)) as TotWaitsFg, 
(NVL(ENDSTAT.TIME_WAITED_MICRO_FG,ENDSTAT.TIME_WAITED_MICRO)-NVL(BEGSTAT.TIME_WAITED_MICRO_FG,BEGSTAT.TIME_WAITED_MICRO))/1000000 as TotWaitFgSec
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
) V
where V.TotWaitsFg > 0
and   V.TotWaitFgSec > 0
group by V.wait_class, V.event_name
order by 4 desc ) X
where rownum < 11;

-- 10g !!!
col wait_class format a30
col event_name format a30
set lines 140

select X.*, round((X."WaitSec"*100)/2214183,2) as "Pct" from (
select V.wait_class, V.event_name , sum(V.TotWaitsFg), sum(V.TotWaitFgSec) as "WaitSec"
from (
SELECT ENDSTAT.WAIT_CLASS , ENDSTAT.EVENT_NAME ,
(ENDSTAT.TOTAL_WAITS-BEGSTAT.TOTAL_WAITS) as TotWaitsFg, 
(ENDSTAT.TIME_WAITED_MICRO-BEGSTAT.TIME_WAITED_MICRO)/1000000 as TotWaitFgSec
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
) V
where V.TotWaitsFg > 0
and   V.TotWaitFgSec > 0
group by V.wait_class, V.event_name
order by 4 desc ) X
where rownum < 11;

