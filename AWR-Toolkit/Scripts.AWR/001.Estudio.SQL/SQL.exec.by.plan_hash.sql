  select v.*, V.BG/V.EXEC as AVGBG
  from (
  select A.snap_id, A.begin_interval_time, B.PLAN_HASH_VALUE, sum(B.executions_delta) as EXEC, sum(B.BUFFER_GETS_DELTA) as BG
  from dba_hist_snapshot A,
	  dba_hist_sqlstat B
  where A.snap_id = B.snap_id
  and B.sql_id = 'b4s2pjp9p1spb'
  -- and B.plan_hash_value = 298697413
  group by A.snap_id, A.begin_interval_time, B.PLAN_HASH_VALUE
  order by 1,2) V
where V.exec > 0
/

