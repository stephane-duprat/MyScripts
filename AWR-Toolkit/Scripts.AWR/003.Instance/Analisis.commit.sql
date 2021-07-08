col "Intervalo" format a12
col wait_class format a30
col event_name format a50
set lines 140 pages 300

define bsnap=10343
define esnap=11070
define inum=1
define dbid=4140483279
		
select	A.snap_id || '-' || B.snap_id as "Intervalo",
	A.stat_name,
	(B.value-A.value)/3600 as "Commits/s"
from	DBA_HIST_SYSSTAT A,
	DBA_HIST_SYSSTAT B
where	B.snap_id between &&bsnap+1 and &&esnap
and	A.dbid = &&dbid
and	A.dbid = B.dbid
and	A.instance_number = &&inum
and	A.instance_number = B.instance_number
and	A.snap_id = (B.snap_id - 1)
and	A.stat_name = B.stat_name
and	A.stat_name = 'user commits';
