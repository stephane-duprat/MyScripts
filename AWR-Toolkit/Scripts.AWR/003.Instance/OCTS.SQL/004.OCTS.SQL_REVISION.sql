define dbid=&&1
define inum=&&2
define bsnap=&&3
define esnap=&&4

set pages 300

PROMPT *********************************
PROMPT *    TOP SQL by Gets            *
PROMPT *********************************

PROMPT SAMPLE TOTAL:


select sum(pct) as "SampleTotal" from (
select sql_id, A, B, round((A/B)*100,2) as pct
from 
(select sql_id, sum(BUFFER_GETS_DELTA) as A from dba_hist_sqlstat
 where snap_id between &&bsnap and &&esnap
 and   dbid = &&dbid
 and instance_number = &&inum
 group by sql_id),
(select sum(BUFFER_GETS_DELTA) as B from dba_hist_sqlstat
  where snap_id between &&bsnap and &&esnap
 and   dbid = &&dbid
 and instance_number = &&inum)
)
where pct > 1;

PROMPT TOP SQL by Gets (weight > 1%)

select * from (
select sql_id, A, B, round((A/B)*100,2) as pct
from 
(select sql_id, sum(BUFFER_GETS_DELTA) as A from dba_hist_sqlstat 
 where snap_id between &&bsnap and &&esnap
 and   dbid = &&dbid
 and instance_number = &&inum
group by sql_id),
(select sum(BUFFER_GETS_DELTA) as B from dba_hist_sqlstat
 where snap_id between &&bsnap and &&esnap
 and   dbid = &&dbid
 and instance_number = &&inum
)
)
where pct > 1
order by pct desc;

PROMPT *********************************
PROMPT *    TOP SQL by Reads           *
PROMPT *********************************


PROMPT SAMPLE TOTAL:


select sum(pct) as "SampleTotal" from (
select sql_id, A, B, round((A/B)*100,2) as pct
from 
(select sql_id, sum(DISK_READS_DELTA) as A from dba_hist_sqlstat
 where snap_id between &&bsnap and &&esnap
 and   dbid = &&dbid
 and instance_number = &&inum
 group by sql_id),
(select sum(DISK_READS_DELTA) as B from dba_hist_sqlstat
  where snap_id between &&bsnap and &&esnap
 and   dbid = &&dbid
 and instance_number = &&inum)
)
where pct > 1;

PROMPT TOP SQL by Reads (weight > 1%)

select * from (
select sql_id, A, B, round((A/B)*100,2) as pct
from 
(select sql_id, sum(DISK_READS_DELTA) as A from dba_hist_sqlstat 
 where snap_id between &&bsnap and &&esnap
 and   dbid = &&dbid
 and instance_number = &&inum
group by sql_id),
(select sum(DISK_READS_DELTA) as B from dba_hist_sqlstat
 where snap_id between &&bsnap and &&esnap
 and   dbid = &&dbid
 and instance_number = &&inum
)
)
where pct > 1
order by pct desc;

PROMPT *********************************
PROMPT *    TOP SQL by Exec            *
PROMPT *********************************


PROMPT SAMPLE TOTAL:


select sum(pct) as "SampleTotal" from (
select sql_id, A, B, round((A/B)*100,2) as pct
from 
(select sql_id, sum(EXECUTIONS_DELTA) as A from dba_hist_sqlstat
 where snap_id between &&bsnap and &&esnap
 and   dbid = &&dbid
 and instance_number = &&inum
 group by sql_id),
(select sum(EXECUTIONS_DELTA) as B from dba_hist_sqlstat
  where snap_id between &&bsnap and &&esnap
 and   dbid = &&dbid
 and instance_number = &&inum)
)
where pct > 1;

PROMPT TOP SQL by Exec (weight > 1%)

select * from (
select sql_id, A, B, round((A/B)*100,2) as pct
from 
(select sql_id, sum(EXECUTIONS_DELTA) as A from dba_hist_sqlstat 
 where snap_id between &&bsnap and &&esnap
 and   dbid = &&dbid
 and instance_number = &&inum
group by sql_id),
(select sum(EXECUTIONS_DELTA) as B from dba_hist_sqlstat
 where snap_id between &&bsnap and &&esnap
 and   dbid = &&dbid
 and instance_number = &&inum
)
)
where pct > 1
order by pct desc;

