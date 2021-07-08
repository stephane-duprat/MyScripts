select distinct A.linea
from
(
select 'CPUPCT=' || to_char(round((sum(AVG_CPU_UTILIZATION)/max(CPU_UTILIZATION_LIMIT))*100,0)) || ';' ||
'RUNQUEUE=' || to_char(ceil(sum(AVG_QUEUED_PARALLEL_STMTS))) as LINEA
from GV$RSRCMGRMETRIC) A;
