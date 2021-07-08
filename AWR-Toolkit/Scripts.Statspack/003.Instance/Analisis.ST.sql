REM Timed columns are given in seconds !!!

define bsnap=76827
define esnap=77610
define inum=1
define dbid=103678672



set lines 140 pages 400
col fecha format a15

select	V.fecha,
	V."CPU Others (s)",
	V."CPU Parse(s)",
	V."CPU Recursive(s)",
	round((100*V."CPU Others (s)")/V."ServiceTime",2) as "CPU Others(%)",
	round((100*V."CPU Parse(s)")/V."ServiceTime",2) as "CPU Parse(%)",
	round((100*V."CPU Recursive(s)")/V."ServiceTime",2) as "CPU Recursive(%)"
from (
select	trunc(snap_time) as fecha,
	sum("ST")/100 as "ServiceTime",
	(sum("ST")-sum("ParseTimeCpu")-sum("RecursiveCpu"))/100 as "CPU Others (s)",
	sum("ParseTimeCpu")/100 as "CPU Parse(s)",
	sum("RecursiveCpu")/100 as "CPU Recursive(s)"
from (
select	snap_id,
	snap_time,
	sum(decode(stat_name,'CPU used by this session',"the_value",0)) as "ST",
	sum(decode(stat_name,'parse time cpu',"the_value",0)) as "ParseTimeCpu",
	sum(decode(stat_name,'recursive cpu usage',"the_value",0)) as "RecursiveCpu"
from (
SELECT	BEG.snap_id,
	BEG.snap_time,
	ENDSTAT.name as stat_name,
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
AND   ENDSTAT.name in ('CPU used by this session','parse time cpu','recursive cpu usage')
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
)
group by snap_id, snap_time
)
group by trunc(snap_time)
) V
order by 1;


