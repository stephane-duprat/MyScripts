define dbid=&&1
define inum=&&2
define bsnap=&&3
define esnap=&&4

col FORCE_MATCHING_SIGNATURE format 9999999999999999999999999
PROMPT *********************************
PROMPT *    Similar SQL summary        *
PROMPT *********************************

select * from (
select A.FORCE_MATCHING_SIGNATURE, count(distinct sql_id) as ZZ
from DBA_HIST_SQLSTAT A
where A.FORCE_MATCHING_SIGNATURE > 0 
and A.dbid = &&dbid 
and A.instance_number = &&inum
and A.snap_id between &&bsnap and &&esnap
and A.parsing_user_id <> 0  -- To exclude SQL parsed by SYS !!!
group by A.FORCE_MATCHING_SIGNATURE
order by 2 desc
)
where ZZ > 10
/

select * from (
select FORCE_MATCHING_SIGNATURE, sql_id, count(*)
from DBA_HIST_SQLSTAT
where FORCE_MATCHING_SIGNATURE in 
(
select FMS from (
select A.FORCE_MATCHING_SIGNATURE as FMS, count(distinct sql_id) as ZZ
from DBA_HIST_SQLSTAT A
where A.FORCE_MATCHING_SIGNATURE > 0 and A.dbid = &&dbid 
and A.instance_number = &&inum
and A.snap_id between &&bsnap and &&esnap
and A.parsing_user_id <> 0  -- To exclude SQL parsed by SYS !!!
group by A.FORCE_MATCHING_SIGNATURE
order by 2 desc
)
where ZZ > 10
)
group by FORCE_MATCHING_SIGNATURE, sql_id
order by 3 desc
)
where rownum < 21
/

PROMPT *********************************
PROMPT *    Total Parse Calls          *
PROMPT *********************************


column "TotalParseCalls" new_value vtpc

select sum(PARSE_CALLS_DELTA) as "TotalParseCalls"
from DBA_HIST_SQLSTAT
where dbid = &&dbid
and instance_number = &&inum
and snap_id between &&bsnap and &&esnap
and parsing_user_id <> 0
/


PROMPT *******************************************
PROMPT * Parse Calls due to similar SQL parsing  *
PROMPT *******************************************


column "TotalParseSimilar" new_value vtpcs

with TT as 
(
select FMS from (
select A.FORCE_MATCHING_SIGNATURE as FMS, count(distinct sql_id) as ZZ
from DBA_HIST_SQLSTAT A
where A.FORCE_MATCHING_SIGNATURE > 0 
and A.dbid = &&dbid 
and A.instance_number = &&inum
and A.snap_id between &&bsnap and &&esnap
and A.parsing_user_id <> 0  -- To exclude SQL parsed by SYS !!!
group by A.FORCE_MATCHING_SIGNATURE
order by 2 desc
)
where ZZ > 10
)
select nvl(sum(PARSE_CALLS_DELTA),0) as "TotalParseSimilar"
from DBA_HIST_SQLSTAT A, TT
where dbid = &&dbid
and instance_number = &&inum
and A.snap_id between &&bsnap and &&esnap
and parsing_user_id <> 0
and A.FORCE_MATCHING_SIGNATURE = TT.FMS
/


PROMPT ***********************************************************
PROMPT *   Percent of Parse Calls due to similar SQL parsing     *
PROMPT ***********************************************************

select round((100*&&vtpcs)/&&vtpc,2) from dual
/

