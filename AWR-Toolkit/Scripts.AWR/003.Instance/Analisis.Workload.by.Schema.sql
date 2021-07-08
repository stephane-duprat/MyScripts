col exec format 9999999999999
col parse format 9999999999999
col PR format 9999999999999
col BG format 9999999999999
col FILAS format 9999999999999
col ST format 9999999999999
col DBT format 9999999999999
col IOW format 9999999999999
col SCH format a10

select * from (
select	PARSING_SCHEMA_NAME as SCH,
	sum(EXECUTIONS_DELTA) as exec, 
	sum(PARSE_CALLS_DELTA) as parse, 
	sum(DISK_READS_DELTA) as PR,
	sum(BUFFER_GETS_DELTA) as BG, 
	sum(ROWS_PROCESSED_DELTA) as filas,
	sum(CPU_TIME_DELTA) as ST, 
	sum(ELAPSED_TIME_DELTA) as DBT,
	sum(IOWAIT_DELTA) as IOW
from dba_hist_sqlstat
where PARSING_SCHEMA_NAME in ('VFRUD','VFRUD2')
group by  PARSING_SCHEMA_NAME
UNION
SELECT 'TOTAL' as SCH,
	sum(EXECUTIONS_DELTA) as exec, 
	sum(PARSE_CALLS_DELTA) as parse, 
	sum(DISK_READS_DELTA) as PR,
	sum(BUFFER_GETS_DELTA) as BG, 
	sum(ROWS_PROCESSED_DELTA) as filas,
	sum(CPU_TIME_DELTA) as ST, 
	sum(ELAPSED_TIME_DELTA) as DBT,
	sum(IOWAIT_DELTA) as IOW
from dba_hist_sqlstat
 )
/

