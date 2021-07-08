define bsnap=76827
define esnap=77622
define inum=1
define dbid=103678672

col the_line format a40
col the_metric format a30

set lines 140 pages 300

-- Porcentaje de accesos a chained o migrated rows !!!

select	the_line,
	"FtchByRowid",
	"FtchByChainedRow",
	round(("FtchByChainedRow"/"FtchByRowid")*100,2) as pct
from (
select	the_line, 
	sum(decode(the_metric,'table fetch by rowid',the_value,0)) as "FtchByRowid",
	sum(decode(the_metric,'table fetch continued row',the_value,0)) as "FtchByChainedRow"
from (
SELECT to_char(END.SNAP_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) as the_line,
ENDSTAT.name as the_metric,
(ENDSTAT.value-BEGSTAT.value) as the_value
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
AND   ENDSTAT.name in ('table fetch by rowid','table fetch continued row')
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
)
group by the_line
order by the_line);


-- Valor medio y stdev !!!

select avg(pct), stddev (pct)
from (
select	the_line,
	"FtchByRowid",
	"FtchByChainedRow",
	round(("FtchByChainedRow"/"FtchByRowid")*100,2) as pct
from (
select	the_line, 
	sum(decode(the_metric,'table fetch by rowid',the_value,0)) as "FtchByRowid",
	sum(decode(the_metric,'table fetch continued row',the_value,0)) as "FtchByChainedRow"
from (
SELECT to_char(END.SNAP_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) as the_line,
ENDSTAT.name as the_metric,
(ENDSTAT.value-BEGSTAT.value) as the_value
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
AND   ENDSTAT.name in ('table fetch by rowid','table fetch continued row')
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
)
group by the_line
order by the_line)
);





