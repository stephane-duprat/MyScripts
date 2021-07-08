variable v_secs NUMBER
exec :v_secs := 3600

set lines 140 pages 200
select min(cpu), max(cpu), avg(cpu), stddev(cpu), 
'[' || round(greatest(0,avg(cpu)-2*stddev(cpu)),2) || ' - ' || round((avg(cpu)+2*stddev(cpu)),2) || ']' as CI95 from 
(
select 
	to_char(to_date(tday||' '||tmod*3600,'YYMMDD SSSSS'),'DD/MM/YYYY HH24:MI') as "BEGIN TIME",
	samples npts,
	round(total/3600,1) aas,
	round(cpu/3600,1) cpu,
	round(io/3600,1) io,
	round(waits/3600,1) wait
from (
	select
		to_char(sample_time,'YYMMDD') tday
		, trunc(to_char(sample_time,'SSSSS')/3600) tmod
		, (max(sample_id) - min(sample_id) + 1 ) samples
		, sum(decode(session_state,'ON CPU',10,decode(session_type,'BACKGROUND',0,10))) total
		, sum(decode(session_state,'ON CPU' ,10,0)) cpu
		, sum(decode(session_state,'WAITING',10,0)) -
		sum(decode(session_type,'BACKGROUND',decode(session_state,'WAITING',10,0)))-
		sum(decode(event,'db file sequential read',10,
				'db file scattered read',10,
				'db file parallel read',10,
				'direct path read',10,
				'direct path read temp',10,
				'direct path write',10,
				'direct path write temp',10, 0)) waits
		, sum(decode(session_type,'FOREGROUND',
			decode(event,'db file sequential read',10,
			'db file scattered read',10,
			'db file parallel read',10,
			'direct path read',10,
			'direct path read temp',10,
			'direct path write',10,
			'direct path write temp',10, 0))) IO
	from
		dba_hist_active_sess_history
	group by trunc(to_char(sample_time,'SSSSS')/3600),
	to_char(sample_time,'YYMMDD')
	) ash
);
