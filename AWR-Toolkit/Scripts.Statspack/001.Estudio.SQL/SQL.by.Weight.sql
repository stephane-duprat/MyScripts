-- TOPn de sentencias por Buffer Gets, ordenadas por su peso proporcional a nivel de instancia:

define dbid=1012207381
define inum = 3
define bsnap = 99175

set pages 200
select	V.sql_id,
	V.the_value,
	W.the_total,
	round(((100*V.the_value)/W.the_total),2) as pct
from (
select	sql_id,
	sum(the_value) as the_value
from (
SELECT to_char(END.SNAP_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) as the_line,
ENDSTAT.hash_value as sql_id,
ABS(ABS(ENDSTAT.buffer_gets)-ABS(BEGSTAT.buffer_gets)) as the_value
FROM PERFSTAT.STATS$SNAPSHOT END,
     PERFSTAT.STATS$SNAPSHOT BEG,
     PERFSTAT.STATS$SQL_SUMMARY ENDSTAT,
     PERFSTAT.STATS$SQL_SUMMARY BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.hash_value = ENDSTAT.hash_value
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
) group by sql_id) V,
(
select sum(the_value) as the_total
from (
SELECT to_char(END.SNAP_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) as the_line,
ENDSTAT.hash_value as sql_id,
ABS(ABS(ENDSTAT.buffer_gets)-ABS(BEGSTAT.buffer_gets)) as the_value
FROM PERFSTAT.STATS$SNAPSHOT END,
     PERFSTAT.STATS$SNAPSHOT BEG,
     PERFSTAT.STATS$SQL_SUMMARY ENDSTAT,
     PERFSTAT.STATS$SQL_SUMMARY BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.hash_value = ENDSTAT.hash_value
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
)) W
where round(((100*V.the_value)/W.the_total),2) > 1
order by 4 desc;


select 'Sample total: ' || sum(pct) from (
select	V.sql_id,
	V.the_value,
	W.the_total,
	round(((100*V.the_value)/W.the_total),2) as pct
from (
select	sql_id,
	sum(the_value) as the_value
from (
SELECT to_char(END.SNAP_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) as the_line,
ENDSTAT.hash_value as sql_id,
ABS(ABS(ENDSTAT.buffer_gets)-ABS(BEGSTAT.buffer_gets)) as the_value
FROM PERFSTAT.STATS$SNAPSHOT END,
     PERFSTAT.STATS$SNAPSHOT BEG,
     PERFSTAT.STATS$SQL_SUMMARY ENDSTAT,
     PERFSTAT.STATS$SQL_SUMMARY BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.hash_value = ENDSTAT.hash_value
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
) group by sql_id) V,
(
select sum(the_value) as the_total
from (
SELECT to_char(END.SNAP_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) as the_line,
ENDSTAT.hash_value as sql_id,
ABS(ABS(ENDSTAT.buffer_gets)-ABS(BEGSTAT.buffer_gets)) as the_value
FROM PERFSTAT.STATS$SNAPSHOT END,
     PERFSTAT.STATS$SNAPSHOT BEG,
     PERFSTAT.STATS$SQL_SUMMARY ENDSTAT,
     PERFSTAT.STATS$SQL_SUMMARY BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.hash_value = ENDSTAT.hash_value
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
)) W
where round(((100*V.the_value)/W.the_total),2) > 1
);



-- TOPn de sentencias por Disk Reads, ordenadas por su peso proporcional a nivel de instancia:

set pages 200
select	V.sql_id,
	V.the_value,
	W.the_total,
	round(((100*V.the_value)/W.the_total),2) as pct
from (
select	sql_id,
	sum(the_value) as the_value
from (
SELECT to_char(END.SNAP_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) as the_line,
ENDSTAT.hash_value as sql_id,
ABS(ABS(ENDSTAT.disk_reads)-ABS(BEGSTAT.disk_reads)) as the_value
FROM PERFSTAT.STATS$SNAPSHOT END,
     PERFSTAT.STATS$SNAPSHOT BEG,
     PERFSTAT.STATS$SQL_SUMMARY ENDSTAT,
     PERFSTAT.STATS$SQL_SUMMARY BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.hash_value = ENDSTAT.hash_value
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
) group by sql_id) V,
(
select sum(the_value) as the_total
from (
SELECT to_char(END.SNAP_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) as the_line,
ENDSTAT.hash_value as sql_id,
ABS(ABS(ENDSTAT.disk_reads)-ABS(BEGSTAT.disk_reads)) as the_value
FROM PERFSTAT.STATS$SNAPSHOT END,
     PERFSTAT.STATS$SNAPSHOT BEG,
     PERFSTAT.STATS$SQL_SUMMARY ENDSTAT,
     PERFSTAT.STATS$SQL_SUMMARY BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.hash_value = ENDSTAT.hash_value
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
)) W
where round(((100*V.the_value)/W.the_total),2) > 1
order by 4 desc;


select 'Sample total: ' || sum(pct) from (
select	V.sql_id,
	V.the_value,
	W.the_total,
	round(((100*V.the_value)/W.the_total),2) as pct
from (
select	sql_id,
	sum(the_value) as the_value
from (
SELECT to_char(END.SNAP_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) as the_line,
ENDSTAT.hash_value as sql_id,
ABS(ABS(ENDSTAT.disk_reads)-ABS(BEGSTAT.disk_reads)) as the_value
FROM PERFSTAT.STATS$SNAPSHOT END,
     PERFSTAT.STATS$SNAPSHOT BEG,
     PERFSTAT.STATS$SQL_SUMMARY ENDSTAT,
     PERFSTAT.STATS$SQL_SUMMARY BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.hash_value = ENDSTAT.hash_value
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
) group by sql_id) V,
(
select sum(the_value) as the_total
from (
SELECT to_char(END.SNAP_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) as the_line,
ENDSTAT.hash_value as sql_id,
ABS(ABS(ENDSTAT.disk_reads)-ABS(BEGSTAT.disk_reads)) as the_value
FROM PERFSTAT.STATS$SNAPSHOT END,
     PERFSTAT.STATS$SNAPSHOT BEG,
     PERFSTAT.STATS$SQL_SUMMARY ENDSTAT,
     PERFSTAT.STATS$SQL_SUMMARY BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.hash_value = ENDSTAT.hash_value
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
)) W
where round(((100*V.the_value)/W.the_total),2) > 1
);

-- TOPn de sentencias por Executions, ordenadas por su peso proporcional a nivel de instancia:

set pages 200
select	V.sql_id,
	V.the_value,
	W.the_total,
	round(((100*V.the_value)/W.the_total),2) as pct
from (
select	sql_id,
	sum(the_value) as the_value
from (
SELECT to_char(END.SNAP_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) as the_line,
ENDSTAT.hash_value as sql_id,
ABS(ABS(ENDSTAT.executions)-ABS(BEGSTAT.executions)) as the_value
FROM PERFSTAT.STATS$SNAPSHOT END,
     PERFSTAT.STATS$SNAPSHOT BEG,
     PERFSTAT.STATS$SQL_SUMMARY ENDSTAT,
     PERFSTAT.STATS$SQL_SUMMARY BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.hash_value = ENDSTAT.hash_value
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
) group by sql_id) V,
(
select sum(the_value) as the_total
from (
SELECT to_char(END.SNAP_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) as the_line,
ENDSTAT.hash_value as sql_id,
ABS(ABS(ENDSTAT.executions)-ABS(BEGSTAT.executions)) as the_value
FROM PERFSTAT.STATS$SNAPSHOT END,
     PERFSTAT.STATS$SNAPSHOT BEG,
     PERFSTAT.STATS$SQL_SUMMARY ENDSTAT,
     PERFSTAT.STATS$SQL_SUMMARY BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.hash_value = ENDSTAT.hash_value
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
)) W
where round(((100*V.the_value)/W.the_total),2) > 1
order by 4 desc;


select 'Sample total: ' || sum(pct) from (
select	V.sql_id,
	V.the_value,
	W.the_total,
	round(((100*V.the_value)/W.the_total),2) as pct
from (
select	sql_id,
	sum(the_value) as the_value
from (
SELECT to_char(END.SNAP_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) as the_line,
ENDSTAT.hash_value as sql_id,
ABS(ABS(ENDSTAT.executions)-ABS(BEGSTAT.executions)) as the_value
FROM PERFSTAT.STATS$SNAPSHOT END,
     PERFSTAT.STATS$SNAPSHOT BEG,
     PERFSTAT.STATS$SQL_SUMMARY ENDSTAT,
     PERFSTAT.STATS$SQL_SUMMARY BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.hash_value = ENDSTAT.hash_value
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
) group by sql_id) V,
(
select sum(the_value) as the_total
from (
SELECT to_char(END.SNAP_TIME,'YYYYMMDDHH24MI') || '-' || to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MI') ||
       '.' || to_char(trunc((to_date(to_char(END.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS')
              -to_date(to_char(BEG.SNAP_TIME,'YYYYMMDDHH24MISS'),'YYYYMMDDHH24MISS'))*24*60*60)) as the_line,
ENDSTAT.hash_value as sql_id,
ABS(ABS(ENDSTAT.executions)-ABS(BEGSTAT.executions)) as the_value
FROM PERFSTAT.STATS$SNAPSHOT END,
     PERFSTAT.STATS$SNAPSHOT BEG,
     PERFSTAT.STATS$SQL_SUMMARY ENDSTAT,
     PERFSTAT.STATS$SQL_SUMMARY BEGSTAT
WHERE END.snap_id = BEG.snap_id + 1
AND   END.snap_id = ENDSTAT.snap_id
AND   BEG.snap_id = BEGSTAT.snap_id
AND   BEGSTAT.hash_value = ENDSTAT.hash_value
AND   END.instance_number = BEG.instance_number
AND   END.instance_number = ENDSTAT.instance_number
AND   END.instance_number = BEGSTAT.instance_number
AND   END.dbid = BEG.dbid
AND   END.dbid = ENDSTAT.dbid
AND   END.dbid = BEGSTAT.dbid
AND   END.instance_number = &&inum
AND   END.dbid = &&dbid
AND   BEG.snap_id >= &&bsnap
)) W
where round(((100*V.the_value)/W.the_total),2) > 1
);

