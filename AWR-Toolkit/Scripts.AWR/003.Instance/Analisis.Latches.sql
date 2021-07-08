define bsnap=33457
define esnap=33831
define inum=1
define dbid=2077324248
define latchname='cache buffers chains'
set lines 140
col latch format a25

select	to_char(fecha,'DD/MM/YYYY HH24:MI') as fecha,
	latch_name as latch,
	"Gets" as "Gets",
	"Misses" as "Misses",
	"Willing-to-wait Gets" as "WTWGets",
	"Willing-to-wait Misses" as "WTWMiss",
	"Immediate Gets" as "IG",
	"Immediate Misses" as "IM",
	"Sleeps",
	"Spin Gets",
	round((100*"Misses")/"Gets",2) as "PctMiss" 
from (
SELECT	BEG.BEGIN_INTERVAL_TIME as fecha,
	ENDSTAT.latch_name,
	(ENDSTAT.GETS-BEGSTAT.GETS) as "Gets",
	(ENDSTAT.MISSES-BEGSTAT.MISSES) as "Misses",
	(ENDSTAT.IMMEDIATE_GETS-BEGSTAT.IMMEDIATE_GETS) as "Immediate Gets",
	(ENDSTAT.IMMEDIATE_MISSES-BEGSTAT.IMMEDIATE_MISSES) as "Immediate Misses",
	((ENDSTAT.GETS-ENDSTAT.IMMEDIATE_GETS)-(BEGSTAT.GETS-BEGSTAT.IMMEDIATE_GETS)) as "Willing-to-wait Gets",
	((ENDSTAT.MISSES-ENDSTAT.IMMEDIATE_MISSES)-(BEGSTAT.MISSES-BEGSTAT.IMMEDIATE_MISSES)) as "Willing-to-wait Misses",
	(ENDSTAT.SLEEPS-BEGSTAT.SLEEPS) as "Sleeps",
	(ENDSTAT.SPIN_GETS-BEGSTAT.SPIN_GETS) as "Spin Gets"
FROM dba_hist_snapshot END,
     dba_hist_snapshot BEG,
     dba_hist_latch ENDSTAT,
     dba_hist_latch BEGSTAT
WHERE (END.snap_id > &&bsnap and END.snap_id <= &&esnap)
AND   (BEG.snap_id >= &&bsnap and BEG.snap_id < &&esnap)
AND   END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.latch_name = ENDSTAT.latch_name
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   ENDSTAT.latch_name = '&&latchname'
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid)
order by fecha;

