select 'CPUPCT=' || to_char(round((sum(AVG_CPU_UTILIZATION)/max(CPU_UTILIZATION_LIMIT))*100,0)) || ';' ||
'RUNQUEUE=' || to_char(ceil(sum(AVG_QUEUED_PARALLEL_STMTS))) || ';' ||
'CPUCOUNT=' || to_char(avg(NUM_CPUS)/2) as LINEA
from V$RSRCMGRMETRIC;
