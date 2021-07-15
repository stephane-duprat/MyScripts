col segment_name format a30
set lines 140

-- Top10 de segmentos por PR:

select * from (
select B.owner, B.object_name, B.object_type, sum(A.PHYSICAL_READS_DELTA)
from DBA_HIST_SEG_STAT A, dba_objects B
where A.obj# = B.object_id
group by B.owner, B.object_name, B.object_type
order by 4 desc
)
where rownum < 11;


-- Top10 de segmentos por LR:

select * from (
select B.owner, B.object_name, B.object_type, sum(A.LOGICAL_READS_DELTA)
from DBA_HIST_SEG_STAT A, dba_objects B
where A.obj# = B.object_id
group by B.owner, B.object_name, B.object_type
order by 4 desc
)
where rownum < 11;


-- Top10 de segmentos por PW:

select * from (
select B.owner, B.object_name, B.object_type, sum(A.PHYSICAL_WRITES_DELTA)
from DBA_HIST_SEG_STAT A, dba_objects B
where A.obj# = B.object_id
group by B.owner, B.object_name, B.object_type
order by 4 desc
)
where rownum < 11;

-- Top10 de segmentos por FTS:

select * from (
select B.owner, B.object_name, B.object_type, sum(A.TABLE_SCANS_DELTA)
from DBA_HIST_SEG_STAT A, dba_objects B
where A.obj# = B.object_id
group by B.owner, B.object_name, B.object_type
order by 4 desc
)
where rownum < 11;


