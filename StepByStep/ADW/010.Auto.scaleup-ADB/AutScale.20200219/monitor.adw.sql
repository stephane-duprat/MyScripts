select A.linea || B.linea
from
(
select 'CPUPCT=' || to_char(round((sum(AVG_CPU_UTILIZATION)/max(CPU_UTILIZATION_LIMIT))*100,0)) || ';' ||
'RUNQUEUE=' || to_char(ceil(sum(AVG_QUEUED_PARALLEL_STMTS))) || ';' ||
'CPUCOUNT=' as LINEA
from V$RSRCMGRMETRIC) A,
(select sum(to_number(value)) as num_cpu from gv$parameter where name = 'cpu_count') B;
