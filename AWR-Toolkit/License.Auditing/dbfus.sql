store set save_settings.sql replace

col plan_plus_exp format a100
set linesize 200 pagesize 999 heading on trimspool on tab off
set verify off heading off numwidth 32 
set timing off
set feedback off echo off
define PROGRAM_NAME=DBfus_Report
col spool_name new_val spool_name
select '&&program_name' || '_' || sys_context('USERENV', 'CURRENT_SCHEMA') || '_' || sys_context('USERENV', 'SERVER_HOST') || '_' || sys_context('USERENV', 'INSTANCE_NAME') || '_' || to_char(sysdate, 'yyyymmddhh24miss') spool_name from dual;
set heading off trimspool on
set sqlprompt '' sqlnumber off termout off 

alter session set nls_numeric_characters='.,';
alter session set nls_length_semantics=BYTE;
alter session set nls_sort='BINARY';
alter session set nls_date_format='YYYY/mm/dd HH24:MI:SS';
alter session set nls_timestamp_format='YYYY/mm/dd HH24:MI:SS';
alter session set nls_timestamp_tz_format='YYYY/mm/dd HH24:MI:SS TZR';
alter session set nls_language=AMERICAN;

-- ####################################################################################################
spool &&SPOOL_NAME..html 
prompt <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN""http://www.w3.org/TR/html4/strict.dtd">
spool off

set markup html on spool on preformat off entmap off head " -
<title>Oracle DB Features Usage</title> -
<style type='text/css'> -
body {font:8pt Arial,Helvetica,sans-serif; color:black; background:White;} -
 table {font:8pt Arial,sans-serif; color:black; background:White; border-collapse:collapse; padding:0px 0px 0px 0px; margin:12px 0px 12px 0px; white-space:nowrap; width:50%;} -
 table.wrap{white-space:normal; width:100%;} -
 td {font:8pt Arial,Helvetica,sans-serif; color:Black; border:1px solid LightGray ; padding:0px 4px 0px 4px; margin:0px 0px 0px 0px; background-color:#FFFFCC\9; white-space:nowrap\9; /* IE 8 and below */} -
 table tr:nth-child(odd) {background-color:#E0E0E0;/*#F5F5F5;*/} /*couleur des lignes pair*/ -
 table tr:nth-child(even) {background-color:#FFFFCC;} /* couleur des lignes impair*/ -
 p {font:8pt Arial,Helvetica,sans-serif; color:black; background:White;} -
 th {font:bold 8pt Arial,Helvetica,sans-serif; color:White; background:#0066CC;border:1px solid LightGray ; padding:0px 4px 0px 4px; text-transform: lowercase;} -
 th:first-letter {text-transform: uppercase;} -
 h1 {font:12pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White;border-bottom:1px solid LightGray; margin-top:20pt; margin-bottom:20pt; padding:0px 0px 0px 0px; text-transform: uppercase;} -
 h2 {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:20pt; margin-bottom:20pt; text-transform: capitalize;} -
 h3 {font:bold 8pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:10pt; margin-bottom:10pt; text-transform: lowercase;} -
 a {font: 8pt Arial,Helvetica,sans-serif; color:#663300; vertical-align:top;margin-top:0pt; margin-bottom:4pt;} -
 a:link {text-decoration:underline;} -
 a:visited {text-decoration:underline;} -
 a:hover {text-decoration:none;} -
 a:active {text-decoration:none;} -
 caption {font-weight:bold ;} -
 li {padding: 0px; margin: 12pt;} - 
 span {text-align:left; display:block;} -
 span.center{text-align:center;} -
 .error{font-weight:bold ;color:white; background-color:#FF0000;} - 
 .warning{font-weight:bold ;color:black; background-color:#FFFF00} -
 .section{text-align:left;padding:0px 0px 0px 0px;} - 
 .inicio{text-align:left;padding:0px 0px 0px 0px;}</style>" BODY "" TABLE ""

COLUMN WARNING HEAD 'WARNING' ENTMAP OFF

prompt <H1 id="inicio">INICIO</H1>
column LINKS_INICIO new_value LINKS_INICIO noprint

select
'<div class="inicio"> <a href="#inicio">Inicio</a></div>' as LINKS_INICIO
from dual;

column LINKS_SECTIONS new_value LINKS_SECTIONS noprint

select
'<div class="section"> <a href="#executivedbfus">DB Feature Usage Executive Summary</a></div>'
||'<div class="section"> <a href="#dbfus">DB Feature Usage Summary</a></div>'
|| '<div class="section"> <a href="#dbfud">DB Feature Usage Details</a></div>'
|| '<div class="section"> <a href="#dbhws">DB Feature High Water Mark Statistics</a> </div>'
|| '<div class="section"> <a href="#cpus">CPU Usage Statistics</a></div>'
|| '<div class="section"> <a href="#dboptions">DB Options</a></div>'  as LINKS_SECTIONS
from dual;

spool &&SPOOL_NAME..html append

set head on
set markup html off entmap off 

-- ####################################################################################################
prompt <H1 id="env">Envorinment Info</H1>
set markup html on entmap on
select fu.db_name "DB Name"
   , fu.dbid "DB Id"
   , cv.banner "Release"
   , fu.total_samples "Total Samples"
   , fu.last_sample_date "Last Sample Time"
from (select distinct f.dbid, di.db_name, f.version, max(f.last_sample_date) last_sample_date , max(f.total_samples) total_samples
        from dba_feature_usage_statistics f,
             dba_hist_database_instance di
       where f.dbid = di.dbid
         and f.version = di.version
		group by f.dbid, di.db_name, f.version
     ) fu
	 , v$database cd
	 , v$instance ci
	 , (select banner from v$version where BANNER like '%Edition%') cv;
                 
set markup html off entmap off
-- ####################################################################################################
set head off
prompt <H1 id="inicio">Sections</H1>
prompt &LINKS_SECTIONS

select '<p>Generated on: ' || to_char(sysdate, 'DD/MM/YYYY HH24:MI') ||'</p>' from dual;
set head on
-- ####################################################################################################
prompt <H1 id="executivedbfus">DB Feature Usage Executive Summary</H1>
set markup html on entmap on
with features as
 (select a OPTIONS, b NAME
    from (select 'Active Data Guard' a,
                 'Active Data Guard - Real-Time Query on Physical Standby' b
            from dual
          union all
          select 'Advanced Compression', 'HeapCompression'
            from dual
          union all
          select 'Advanced Compression', 'Backup BZIP2 Compression'
            from dual
          union all
          select 'Advanced Compression', 'Backup DEFAULT Compression'
            from dual
          union all
          select 'Advanced Compression', 'Backup HIGH Compression'
            from dual
          union all
          select 'Advanced Compression', 'Backup LOW Compression'
            from dual
          union all
          select 'Advanced Compression', 'Backup MEDIUM Compression'
            from dual
          union all
          select 'Advanced Compression', 'Backup ZLIB, Compression'
            from dual
          union all
          select 'Advanced Compression', 'SecureFile Compression (user)'
            from dual
          union all
          select 'Advanced Compression', 'SecureFile Deduplication (user)'
            from dual
          union all
          select 'Advanced Compression', 'Data Guard'
            from dual
          union all
          select 'Advanced Compression', 'Oracle Utility Datapump (Export)'
            from dual
          union all
          select 'Advanced Compression', 'Oracle Utility Datapump (Import)'
            from dual
          union all
          select 'Advanced Security',
                 'ASO native encryption and checksumming'
            from dual
          union all
          select 'Advanced Security', 'Transparent Data Encryption'
            from dual
          union all
          select 'Advanced Security', 'Encrypted Tablespaces'
            from dual
          union all
          select 'Advanced Security', 'Backup Encryption'
            from dual
          union all
          select 'Advanced Security', 'SecureFile Encryption (user)'
            from dual
          union all
          select 'Change Management Pack (GC)', 'Change Management Pack (GC)'
            from dual
          union all
          select 'Data Masking Pack', 'Data Masking Pack (GC)'
            from dual
          union all
          select 'Data Mining', 'Data Mining'
            from dual
          union all
          select 'Diagnostic Pack', 'Diagnostic Pack'
            from dual
          union all
          select 'Diagnostic Pack', 'ADDM'
            from dual
          union all
          select 'Diagnostic Pack', 'AWR Baseline'
            from dual
          union all
          select 'Diagnostic Pack', 'AWR Baseline Template'
            from dual
          union all
          select 'Diagnostic Pack', 'AWR Report'
            from dual
          union all
          select 'Diagnostic Pack', 'Baseline Adaptive Thresholds'
            from dual
          union all
          select 'Diagnostic Pack', 'Baseline Static Computations'
            from dual
          union all
          select 'Tuning Pack', 'Tuning Pack'
            from dual
          union all
          select 'Tuning Pack', 'Real-Time SQL Monitoring'
            from dual
          union all
          select 'Tuning Pack', 'SQL Tuning Advisor'
            from dual
          union all
          select 'Tuning Pack', 'SQL Access Advisor'
            from dual
          union all
          select 'Tuning Pack', 'SQL Profile'
            from dual
          union all
          select 'Tuning Pack', 'Automatic SQL Tuning Advisor'
            from dual
          union all
          select 'Database Vault', 'Oracle Database Vault'
            from dual
          union all
          select 'WebLogic Server Management Pack Enterprise Edition',
                 'EM AS Provisioning and Patch Automation (GC)'
            from dual
          union all
          select 'Configuration Management Pack for Oracle Database',
                 'EM Config Management Pack (GC)'
            from dual
          union all
          select 'Provisioning and Patch Automation Pack for Database',
                 'EM Database Provisioning and Patch Automation (GC)'
            from dual
          union all
          select 'Provisioning and Patch Automation Pack',
                 'EM Standalone Provisioning and Patch Automation Pack (GC)'
            from dual
          union all
          select 'Exadata', 'Exadata'
            from dual
          union all
          select 'Label Security', 'Label Security'
            from dual
          union all
          select 'OLAP', 'OLAP - Analytic Workspaces'
            from dual
          union all
          select 'Partitioning', 'Partitioning (user)'
            from dual
          union all
          select 'Real Application Clusters',
                 'Real Application Clusters (RAC)'
            from dual
          union all
          select 'Real Application Testing',
                 'Database Replay: Workload Capture'
            from dual
          union all
          select 'Real Application Testing',
                 'Database Replay: Workload Replay'
            from dual
          union all
          select 'Real Application Testing', 'SQL Performance Analyzer'
            from dual
          union all
          select 'Spatial',
                 'Spatial (Not used because this does not differential usage of spatial over locator, which is free)'
            from dual
          union all
          select 'Total Recall', 'Flashback Data Archive'
            from dual))
select t.o "Option/Management Pack",
       t.u "Used",
       t.n "Feature being Used",
       t.v "Version",
       t.cu "Currently Used",
       t.du "Detected Usage",
       t.lud "Last Usage Date",
       t.ts "Total Samples",
       t.lsd "Last Sample Date",
       d.DBID "DBID",
       d.name "DB Name",
       i.version "Curr DB Version",
       i.host_name "Host Name",
       to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS') "ReportGen Time"
  from (select f.OPTIONS o,
               'YES' u,
               f_stat.version v,
               case
                 when f_stat.name in
                      ('Oracle Utility Datapump (Export)',
                       'Oracle Utility Datapump (Import)') then
                  'Data Pump Compression'
                 when f_stat.name in ('Data Guard') then
                  'Data Guard Network Compression'
                 else
                  f_stat.name
               end n,
               f_stat.CURRENTLY_USED cu,
               (f_stat.DETECTED_USAGES) du,
               to_char(f_stat.LAST_USAGE_DATE, 'DD-MON-YY HH24:MI:SS') lud,
               (f_stat.TOTAL_SAMPLES) ts,
               to_char(f_stat.LAST_SAMPLE_DATE, 'DD-MON-YY HH24:MI:SS') lsd
          from features f, sys.dba_feature_usage_statistics f_stat
         where f.name = f_stat.name
           and ((f_stat.currently_used = 'TRUE' and
               f_stat.detected_usages > 0 and
               (sysdate - f_stat.last_usage_date) < 366 and
               f_stat.total_samples > 0) or
               (f_stat.detected_usages > 0 and
               (sysdate - f_stat.last_usage_date) < 366 and
               f_stat.total_samples > 0))
           and (f_stat.name not in
               ('Data Guard',
                 'Oracle Utility Datapump (Export)',
                 'Oracle Utility Datapump (Import)') or
               (f_stat.name in
               ('Data Guard',
                  'Oracle Utility Datapump (Export)',
                  'Oracle Utility Datapump (Import)') and
               f_stat.feature_info is not null and
               trim(substr(to_char(feature_info),
                             instr(to_char(feature_info),
                                   'compression used: ',
                                   1,
                                   1) + 18,
                             2)) != '0'))) t,
       v$instance i,
       v$database d
 order by t.o, t.n, t.v;
                 
set markup html off entmap off
prompt &LINKS_INICIO

-- ####################################################################################################
prompt <H1 id="dbfus">DB Feature Usage Summary</H1>
set markup html on entmap on
select name "Feature Name", currently_used "Curr- ently Used", detected_usages "Detected Usages" , total_samples "Total Samples",
              last_usage_date "Last Usage Time"
         from dba_feature_usage_statistics
         order by currently_used desc, name asc;
                 
set markup html off entmap off
prompt &LINKS_INICIO

-- ####################################################################################################
prompt <H1 id="dbfud">DB Feature Usage Details</H1>
set markup html on entmap on
select name "Feature Name", detected_usages "Detected Usages", total_samples "Total Samples",
             first_usage_date "First Usage Date",
             last_usage_date "Last Usage Date",
             aux_count "Aux Count",
             (case when length(feature_info) > 80 then
                substr(feature_info, 1, 76) || ' ...'
              else
                 feature_info
              end) "Feature Info"
        from dba_feature_usage_statistics
       where detected_usages > 0
       order by name asc;
 

set markup html off entmap off
prompt &LINKS_INICIO
-- ####################################################################################################
prompt <H1 id="dbhws">DB Feature High Water Mark Statistics</H1>
set markup html on entmap on
select description "Name", highwater "High Water Mark", last_value "Last Value"
        from dba_high_water_mark_statistics 
        order by description;

set markup html off entmap off 
prompt &LINKS_INICIO

-- ####################################################################################################
prompt <H1 id="cpus">CPU Usage Statistics</H1>

set markup html on entmap on
select timestamp "Timestamp", cpu_count "CPU Count", cpu_core_count "CPU Core Count" , cpu_socket_count "CPU Socket Count" 
        from dba_cpu_usage_statistics 
        order by timestamp;
		
select * from v$license;

set markup html off entmap off 
prompt &LINKS_INICIO
-- ####################################################################################################
prompt <H1 id="dboptions">DB Options</H1>
set markup html on entmap on
Select parameter, value
from v$option 
order by 2 desc, 1;

set markup html off entmap off 
prompt &LINKS_INICIO
-- ####################################################################################################

set markup html off entmap off
set termout on

prompt Output file is &&SPOOL_NAME..html
@save_settings.sql
set sqlprompt 'SQL> ' 

--host explorer "&&SPOOL_NAME..html"

undef PROGRAM_NAME
undef SPOOL_NAME
undef LINKS_SECTION