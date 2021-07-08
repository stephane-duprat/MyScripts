select * from v$license;

select banner from v$version where BANNER like '%Edition%';

select decode(count(*), 0, 'No', 'Yes') Partitioning
from ( select 1 
       from dba_part_tables
       where owner not in ('SYSMAN', 'SH', 'SYS', 'SYSTEM')
         and rownum = 1 );

select decode(count(*), 0, 'No', 'Yes') Spatial
from ( select 1
       from all_sdo_geom_metadata 
       where rownum = 1 );

select decode(count(*), 0, 'No', 'Yes') RAC
from ( select 1 
       from v$active_instances 
       where rownum = 1 );

Col name  format a50 heading "Option"
Col value format a5  heading "?"      justify center wrap
Break on value dup skip 1
Spool option
Select parameter name, value
from v$option 
order by 2 desc, 1
/


Set feedback off
Set linesize 122
Col name             format a70     heading "Feature"
Col version          format a10     heading "Version"
Col detected_usages  format 999,990 heading "Detected|usages"
Col currently_used   format a06     heading "Curr.|used?"
Col first_usage_date format a10     heading "First use"
Col last_usage_date  format a10     heading "Last use"
Col nop noprint
Break on nop skip 1 on name
Select decode(detected_usages,0,2,1) nop,
       name, version, detected_usages, currently_used,
       to_char(first_usage_date,'DD/MM/YYYY') first_usage_date, 
       to_char(last_usage_date,'DD/MM/YYYY') last_usage_date
from dba_feature_usage_statistics
order by nop, 1, 2
/


