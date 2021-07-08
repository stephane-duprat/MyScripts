select substr(DD,1,10) as DD, sum(GB)/(select count(*) from v$thread) as Gbytes from (
select A.inst_id, A.thread#, to_char(A.FIRST_TIME,'DD/MM/YYYY') as DD , sum(A.BLOCKS*A.BLOCK_SIZE/1024/1024/1024) as GB
from gv$archived_log A, gv$instance B
where trunc(A.FIRST_TIME) >= trunc(sysdate-7)
and A.inst_id = B.inst_id
and A.thread# = B.thread#
group by  A.inst_id, A.thread#,to_char(A.FIRST_TIME,'DD/MM/YYYY')
order by 1
)
group by substr(DD,1,10)
order by 1
/
