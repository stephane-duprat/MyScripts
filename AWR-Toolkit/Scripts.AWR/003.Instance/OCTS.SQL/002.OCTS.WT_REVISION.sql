define dbid=&&1
define inum=&&2
define bsnap=&&3
define esnap=&&4
column "TotalWT" new_value vtotwt

select sum(V.TotWaitFgSec) as "TotalWT"
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

col wait_class format a25
col event_name format a40

PROMPT ***********************************
PROMPT *     Wait event summary          *
PROMPT ***********************************

select X.*, round((X."WaitSec"*100)/&&vtotwt) as "Pct" from (
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

