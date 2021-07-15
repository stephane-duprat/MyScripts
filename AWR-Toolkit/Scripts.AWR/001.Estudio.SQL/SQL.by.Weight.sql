-- TOPn de sentencias por Buffer Gets, ordenadas por su peso proporcional a nivel de instancia:

define bsnap=12343
define esnap=13050
define inum=1
define dbid=243561075

set pages 200

select 'Sample total: ' || sum(pct) from (
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

-- TOPn de sentencias por Disk Reads, ordenadas por su peso proporcional a nivel de instancia:

set pages 200

select 'Sample total: ' || sum(pct) from (
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
 and instance_number = &&inum)
)
where pct > 1
order by pct desc;



