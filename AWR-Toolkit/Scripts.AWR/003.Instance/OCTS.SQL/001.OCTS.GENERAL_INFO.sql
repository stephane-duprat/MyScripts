define dbid=&&1
define inum=&&2
define bsnap=&&3
define esnap=&&4

select distinct DB_NAME, INSTANCE_NAME, HOST_NAME, VERSION
from DBA_HIST_DATABASE_INSTANCE
where  dbid = &&dbid
and    INSTANCE_NUMBER = &&inum
;

select begin_interval_time
from dba_hist_snapshot
where dbid = &&dbid
and   INSTANCE_NUMBER = &&inum
and   snap_id = &&bsnap;

select end_interval_time
from dba_hist_snapshot
where dbid = &&dbid
and   INSTANCE_NUMBER = &&inum
and   snap_id = &&esnap;



