SQL> set timing on
SQL> select count(*) from SALES_JSON_CHECK_10M;

  COUNT(*)
----------
  10000000

Elapsed: 00:00:09.46


--- Sin IMC !!!

select ch.channel_desc, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
group by ch.channel_desc;

CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
Internet			       4901286614
Direct Sales			       4904074408
Partners			       4902190890
Catalog 			       4899139710
Tele Sales			       4901183505

Elapsed: 00:01:40.51


alter session force parallel query parallel 4;

select ch.channel_desc, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
group by ch.channel_desc;


CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
Internet			       4901286614
Partners			       4902190890
Catalog 			       4899139710
Tele Sales			       4901183505
Direct Sales			       4904074408

Elapsed: 00:00:45.80


--- Con IMC !!!

-- Estos cambios se hacen en la CDB !!!

SQL> alter system set inmemory_virtual_columns = 'ENABLE' scope=spfile sid='*';

System altered.

SQL> alter system set max_string_size = 'EXTENDED' scope=spfile sid='*';

System altered.

SQL> 

SQL> alter system set inmemory_size = 4G scope=spfile sid='*';

System altered.

SQL> exit

[oracle@clu1cn1 ~]$ srvctl stop database -d jsondb_fra19r -o immediate
[oracle@clu1cn1 ~]$ srvctl start database -d jsondb_fra19r
[oracle@clu1cn1 ~]$ srvctl status database -d jsondb_fra19r
Instance jsondb1 is running on node clu1cn1
Instance jsondb2 is running on node clu1cn2

[oracle@clu1cn1 ~]$ sqlplus / as sysdba

SQL*Plus: Release 18.0.0.0.0 - Production on Tue Oct 9 13:57:26 2018
Version 18.2.0.0.0

Copyright (c) 1982, 2018, Oracle.  All rights reserved.


Connected to:
Oracle Database 18c EE Extreme Perf Release 18.0.0.0.0 - Production
Version 18.2.0.0.0

SQL> show pdbs

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  MOUNTED
	 3 JSONPDB			  MOUNTED
SQL> alter pluggable database all open;
alter pluggable database all open
*
ERROR at line 1:
ORA-14694: database must in UPGRADE mode to begin MAX_STRING_SIZE migration


SQL> alter pluggable database JSONPDB open upgrade;

Pluggable database altered.

SQL> 

SQL> alter pluggable database PDB$SEED open upgrade;

Pluggable database altered.

SQL> show pdbs

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  MIGRATE    YES
	 3 JSONPDB			  MIGRATE    YES
SQL> 

SQL> alter session set container = PDB$SEED;

Session altered.

SQL> show parameter max_string_size

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
max_string_size 		     string	 EXTENDED
SQL> @?/rdbms/admin/utl32k.sql

Session altered.


Session altered.

DOC>#######################################################################
DOC>#######################################################################
DOC>   The following statement will cause an "ORA-01722: invalid number"
DOC>   error if the database has not been opened for UPGRADE.
DOC>
DOC>   Perform a "SHUTDOWN ABORT"  and
DOC>   restart using UPGRADE.
DOC>#######################################################################
DOC>#######################################################################
DOC>#

no rows selected

DOC>#######################################################################
DOC>#######################################################################
DOC>   The following statement will cause an "ORA-01722: invalid number"
DOC>   error if the database does not have compatible >= 12.0.0
DOC>
DOC>   Set compatible >= 12.0.0 and retry.
DOC>#######################################################################
DOC>#######################################################################
DOC>#

PL/SQL procedure successfully completed.


Session altered.


0 rows updated.


Commit complete.


System altered.


PL/SQL procedure successfully completed.


Commit complete.


System altered.


Session altered.


Session altered.


Table created.


Table created.


Table created.


Table truncated.


0 rows created.


PL/SQL procedure successfully completed.


STARTTIME
--------------------------------------------------------------------------------
10/09/2018 14:02:42.346873000


PL/SQL procedure successfully completed.

No errors.

PL/SQL procedure successfully completed.


Session altered.


Session altered.


0 rows created.


no rows selected


no rows selected

DOC>#######################################################################
DOC>#######################################################################
DOC>   The following statement will cause an "ORA-01722: invalid number"
DOC>   error if we encountered an error while modifying a column to
DOC>   account for data type length change as a result of enabling or
DOC>   disabling 32k types.
DOC>
DOC>   Contact Oracle support for assistance.
DOC>#######################################################################
DOC>#######################################################################
DOC>#

PL/SQL procedure successfully completed.


PL/SQL procedure successfully completed.


Commit complete.


Package altered.


Package altered.


Session altered.

SQL> 
SQL> 
SQL> alter session set container = JSONPDB;

Session altered.

SQL> show parameter max_string_size

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
max_string_size 		     string	 EXTENDED
SQL> @?/rdbms/admin/utl32k.sql

Session altered.


Session altered.

DOC>#######################################################################
DOC>#######################################################################
DOC>   The following statement will cause an "ORA-01722: invalid number"
DOC>   error if the database has not been opened for UPGRADE.
DOC>
DOC>   Perform a "SHUTDOWN ABORT"  and
DOC>   restart using UPGRADE.
DOC>#######################################################################
DOC>#######################################################################
DOC>#

no rows selected

DOC>#######################################################################
DOC>#######################################################################
DOC>   The following statement will cause an "ORA-01722: invalid number"
DOC>   error if the database does not have compatible >= 12.0.0
DOC>
DOC>   Set compatible >= 12.0.0 and retry.
DOC>#######################################################################
DOC>#######################################################################
DOC>#

PL/SQL procedure successfully completed.


Session altered.


0 rows updated.


Commit complete.


System altered.


PL/SQL procedure successfully completed.


Commit complete.


System altered.


Session altered.


Session altered.


Table created.


Table created.


Table created.


Table truncated.


0 rows created.


PL/SQL procedure successfully completed.


STARTTIME
--------------------------------------------------------------------------------
10/09/2018 14:03:27.607566000


PL/SQL procedure successfully completed.

No errors.

PL/SQL procedure successfully completed.


Session altered.


Session altered.


0 rows created.


no rows selected


no rows selected

DOC>#######################################################################
DOC>#######################################################################
DOC>   The following statement will cause an "ORA-01722: invalid number"
DOC>   error if we encountered an error while modifying a column to
DOC>   account for data type length change as a result of enabling or
DOC>   disabling 32k types.
DOC>
DOC>   Contact Oracle support for assistance.
DOC>#######################################################################
DOC>#######################################################################
DOC>#

PL/SQL procedure successfully completed.


PL/SQL procedure successfully completed.


Commit complete.


Package altered.


Package altered.


Session altered.

SQL> 

[oracle@clu1cn1 ~]$ srvctl stop database -d jsondb_fra19r -o immediate
[oracle@clu1cn1 ~]$ srvctl start database -d jsondb_fra19r
[oracle@clu1cn1 ~]$ srvctl status database -d jsondb_fra19r
Instance jsondb1 is running on node clu1cn1
Instance jsondb2 is running on node clu1cn2
[oracle@clu1cn1 ~]$ sqlplus / as sysdba

SQL*Plus: Release 18.0.0.0.0 - Production on Tue Oct 9 14:07:32 2018
Version 18.2.0.0.0

Copyright (c) 1982, 2018, Oracle.  All rights reserved.


Connected to:
Oracle Database 18c EE Extreme Perf Release 18.0.0.0.0 - Production
Version 18.2.0.0.0

SQL> show pdbs

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 JSONPDB			  READ WRITE NO
SQL> 

SQL> alter system set inmemory_size = 8G scope=both sid='*';

System altered.


sqlplus sh/sh@JSONPDB


Table altered.

  SELECT table_name,
	    inmemory,
	    inmemory_priority,
	    inmemory_distribute,
	    inmemory_compression,
	    inmemory_duplicate
  FROM   user_tables
  where inmemory = 'ENABLED'
ORDER BY table_name
/

TABLE_NAME													 INMEMORY
-------------------------------------------------------------------------------------------------------------------------------- --------
INMEMORY INMEMORY_DISTRI INMEMORY_COMPRESS INMEMORY_DUPL
-------- --------------- ----------------- -------------
CHANNELS													 ENABLED
CRITICAL AUTO		 FOR QUERY LOW	   NO DUPLICATE

SALES_JSON_CHECK_10M												 ENABLED
CRITICAL AUTO		 FOR QUERY LOW	   NO DUPLICATE


col owner format a30
col name format a30
set lines 140 pages 300
col owner format a12
col segment_name format a30

SELECT v.inst_id,v.owner, v.segment_name name,
       v.populate_status status, v.bytes_not_populated, v.bytes/1024/1024/1024 as OriginalGB, 
FROM   gv$im_segments v
where  v.bytes_not_populated > 0;


alter table SALES_JSON_CHECK_10M inmemory priority critical;

OWNER			       NAME			      STATUS	    BYTES_NOT_POPULATED
------------------------------ ------------------------------ ------------- -------------------
SH			       SALES_JSON_CHECK_10M	      STARTED		     5412585472
SH			       SALES_JSON_CHECK_10M	      STARTED		     5244870656

col owner format a30
col name format a30
set lines 140 pages 300
col owner format a12
col segment_name format a30

SELECT inst_id,
       owner,
       segment_name,
         im_size_mb,
       on_disk_size_mb,
       not_populated_mb,
       round(not_populated_mb/on_disk_size_mb * 100,2) npopulated_percent,
       populate_status
FROM
(
          SELECT inst_id,
                 owner,
                 segment_name,
                 partition_name,
                 round(inmemory_size/1024/1024,2)       im_size_mb,
                 round(bytes/1024/1024,2)               on_disk_size_mb,
                 round(bytes_not_populated/1024/1024,2) not_populated_mb,
                 populate_status
          FROM   GV$IM_SEGMENTS
)
ORDER BY populate_status,
         2,
         3,
         4,
         1;


   INST_ID OWNER	SEGMENT_NAME		  IM_SIZE_MB ON_DISK_SIZE_MB NOT_POPULATED_MB NPOPULATED_PERCENT POPULATE_STAT
---------- ------------ ------------------------- ---------- --------------- ---------------- ------------------ -------------
	 2 SH		SALES_JSON_CHECK_10M	      2860.5	     5611.72	      3084.09		   54.96 COMPLETED
	 1 SH		SALES_JSON_CHECK_10M	     3392.06	     5611.72	      2527.63		   45.04 COMPLETED

SQL> 

--- Sin parallel !!!

select a.name, b.value
from v$mystat b, v$statname a
where a.statistic# = b.statistic#
and value > 0
and a.name like 'IM%';


select /*+ INMEMORY */ ch.channel_desc, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
group by ch.channel_desc;

Elapsed: 00:04:01.18
SQL> SQL> select a.name, b.value
from v$mystat b, v$statname a
where a.statistic# = b.statistic#
and value > 0
and a.name like 'IM%';  2    3    4    5  

NAME								      VALUE
---------------------------------------------------------------- ----------
IM scan CUs no cleanout 						135
IM scan smu colmap miss due to invalid blocks				 59
IM scan smu colmap miss due to untracked changes			 50
IM scan CUs current							135
IM scan CUs readlist creation accumulated time			      22669
IM scan CUs readlist creation number					135
IM scan delta - only base scan						135
IM scan CUs memcompress for query low					135
IM scan segments disk							  1
IM scan bytes in-memory 					 5392834453
IM scan bytes uncompressed					 5280595192

NAME								      VALUE
---------------------------------------------------------------- ----------
IM scan CUs columns accessed						 43
IM scan CUs columns theoretical max					270
IM scan rows							   10356976
IM simd decode calls							792
IM simd decode selective calls						792
IM scan rows valid						    1715322
IM scan rows range excluded					    1098216
IM scan rows excluded						   10214022
IM scan rows projected						    1715322
IM scan rows cache no delta					    3229436
IM scan blocks cache						     421430

NAME								      VALUE
---------------------------------------------------------------- ----------
IM scan CUs split pieces						217
IM scan CUs invalid or missing revert to on disk extent 		209
IM scan CUs no rows valid						 82

25 rows selected.

Elapsed: 00:00:00.00
SQL> 


select /*+ NO_INMEMORY */ ch.channel_desc, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
group by ch.channel_desc;

CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
Tele Sales			       4901183505
Internet			       4901286614
Direct Sales			       4904074408
Partners			       4902190890
Catalog 			       4899139710

Elapsed: 00:01:23.68
SQL> select a.name, b.value
from v$mystat b, v$statname a
where a.statistic# = b.statistic#
and value > 0
and a.name like 'IM%';  2    3    4    5  

NAME								      VALUE
---------------------------------------------------------------- ----------
IM scan segments disk							  4

Elapsed: 00:00:00.01
SQL> 


select /*+ INMEMORY */ sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M c;

SUM(C.SALES_JSON.TOTAL_SOLD)
----------------------------
		  2.4508E+10

Elapsed: 00:02:36.42
SQL> select a.name, b.value
from v$mystat b, v$statname a
where a.statistic# = b.statistic#
and value > 0
and a.name like 'IM%';  2    3    4    5  

NAME								      VALUE
---------------------------------------------------------------- ----------
IM scan CUs no cleanout 						 72
IM scan smu colmap miss due to untracked changes			 50
IM scan CUs current							 72
IM scan CUs readlist creation accumulated time			      12604
IM scan CUs readlist creation number					 72
IM scan delta - only base scan						 72
IM scan CUs memcompress for query low					 72
IM scan bytes in-memory 					 2877716797
IM scan bytes uncompressed					 2817835180
IM scan CUs columns accessed						 43
IM scan CUs columns theoretical max					144

NAME								      VALUE
---------------------------------------------------------------- ----------
IM scan rows							    5526696
IM simd decode calls							265
IM simd decode selective calls						265
IM scan rows valid						    1756566
IM scan rows range excluded					     582400
IM scan rows excluded						    3187730
IM scan rows projected						    1756566
IM scan rows cache no delta					    3187730
IM scan blocks cache						     227695
IM scan CUs split pieces						117
IM scan CUs invalid or missing revert to on disk extent 		180

NAME								      VALUE
---------------------------------------------------------------- ----------
IM scan CUs no rows valid						 29

23 rows selected.

Elapsed: 00:00:00.00
SQL> 


select /*+ NO_INMEMORY */ sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M c;

SUM(C.SALES_JSON.TOTAL_SOLD)
----------------------------
		  2.4508E+10

Elapsed: 00:00:59.84
SQL> 




--- Con campo VARCHAR2 para el JSON !!!


create table SALES_JSON_CHECK_10M_V2
(
ID VARCHAR2(50),
sales_json VARCHAR2(32767),
CONSTRAINT sales_json_10m_v2_pk primary Key (id),
CONSTRAINT sales_json_10m_v2_check CHECK (sales_json IS JSON)
) tablespace SH;

alter session enable parallel DML;
alter session force parallel query parallel 4;

insert /*+ APPEND NOLOGGING */
into SALES_JSON_CHECK_10M_V2
select * from SALES_JSON_CHECK_10M;

commit;

alter table SALES_JSON_CHECK_10M no inmemory;

alter table SALES_JSON_CHECK_10M_V2 inmemory priority critical;

col owner format a30
col name format a30
set lines 140 pages 300
col owner format a12
col segment_name format a30

SELECT inst_id,
       owner,
       segment_name,
         im_size_mb,
       on_disk_size_mb,
       not_populated_mb,
       round(not_populated_mb/on_disk_size_mb * 100,2) npopulated_percent,
       populate_status
FROM
(
          SELECT inst_id,
                 owner,
                 segment_name,
                 partition_name,
                 round(inmemory_size/1024/1024,2)       im_size_mb,
                 round(bytes/1024/1024,2)               on_disk_size_mb,
                 round(bytes_not_populated/1024/1024,2) not_populated_mb,
                 populate_status
          FROM   GV$IM_SEGMENTS
)
ORDER BY populate_status,
         2,
         3,
         4,
         1;


   INST_ID OWNER	SEGMENT_NAME			    IM_SIZE_MB ON_DISK_SIZE_MB NOT_POPULATED_MB NPOPULATED_PERCENT POPULATE_STAT
---------- ------------ ----------------------------------- ---------- --------------- ---------------- ------------------ -------------
	 1 SH		SALES_JSON_CHECK_10M_V2 	       2343.75	       3255.35		1762.77 	     54.15 COMPLETED
	 2 SH		SALES_JSON_CHECK_10M_V2 	       2672.81	       3255.35		1492.58 	     45.85 COMPLETED

Elapsed: 00:00:00.02


select /*+ INMEMORY */ ch.channel_desc, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M_V2 c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
group by ch.channel_desc;

CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
Internet			       4901286614
Direct Sales			       4904074408
Partners			       4902190890
Catalog 			       4899139710
Tele Sales			       4901183505

Elapsed: 00:01:21.60

select a.name, b.value
from v$mystat b, v$statname a
where a.statistic# = b.statistic#
and value > 0
and a.name like 'IM%';

NAME								      VALUE
---------------------------------------------------------------- ----------
IM scan CUs no cleanout 						 41
IM scan CUs current							 41
IM scan CUs readlist creation accumulated time				128
IM scan CUs readlist creation number					 41
IM scan delta - only base scan						 41
IM scan rows pcode aggregated					    4077120
IM scan CUs memcompress for query low					 41
IM scan EUs memcompress for query low					 41
IM scan segments disk							  1
IM scan bytes in-memory 					 1279300041
IM scan bytes uncompressed					 1231101717

NAME								      VALUE
---------------------------------------------------------------- ----------
IM scan CUs columns accessed						 41
IM scan CUs columns theoretical max					 82
IM scan EU bytes in-memory					  472563116
IM scan EU bytes uncompressed					  472558517
IM scan EUs columns accessed						 41
IM scan EUs columns theoretical max					123
IM scan EU rows 						    4289088
IM scan rows							    4289088
IM simd decode calls						       3988
IM simd decode selective calls					       3988
IM scan rows valid						    4077120

NAME								      VALUE
---------------------------------------------------------------- ----------
IM scan rows range excluded					     211968
IM scan rows optimized						    4289088
IM scan rows projected						    4077119
IM scan CUs split pieces						106
IM scan EUs split pieces						 26
IM scan CUs invalid or missing revert to on disk extent 		155

28 rows selected.

Elapsed: 00:00:00.00

select /*+ NO_INMEMORY */ ch.channel_desc, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M_V2 c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
group by ch.channel_desc;

CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
Internet			       4901286614
Direct Sales			       4904074408
Partners			       4902190890
Catalog 			       4899139710
Tele Sales			       4901183505

Elapsed: 00:01:29.86
SQL> select a.name, b.value
from v$mystat b, v$statname a
where a.statistic# = b.statistic#
and value > 0
and a.name like 'IM%';  2    3    4    5  

NAME								      VALUE
---------------------------------------------------------------- ----------
IM scan segments disk							  2

Elapsed: 00:00:00.00


--- Con paralllel QUERY !!!

alter session force parallel query parallel 4;

select /*+ INMEMORY */ ch.channel_desc, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M_V2 c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
group by ch.channel_desc;

CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
Tele Sales			       4901183505
Direct Sales			       4904074408
Internet			       4901286614
Partners			       4902190890
Catalog 			       4899139710

Elapsed: 00:00:11.69


select /*+ NO_INMEMORY */ ch.channel_desc, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M_V2 c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
group by ch.channel_desc;

CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
Tele Sales			       4901183505
Internet			       4901286614
Partners			       4902190890
Catalog 			       4899139710
Direct Sales			       4904074408

Elapsed: 00:00:26.78
SQL> 

--- Parallel 2 !!!
alter session force parallel query parallel 2;
set timing on

select /*+ INMEMORY */ ch.channel_desc, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M_V2 c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
group by ch.channel_desc;

CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
Internet			       4901286614
Partners			       4902190890
Direct Sales			       4904074408
Catalog 			       4899139710
Tele Sales			       4901183505

Elapsed: 00:00:21.52

alter session force parallel query parallel 2;
set timing on

select /*+ NO_INMEMORY */ ch.channel_desc, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M_V2 c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
group by ch.channel_desc;

CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
Internet			       4901286614
Direct Sales			       4904074408
Partners			       4902190890
Catalog 			       4899139710
Tele Sales			       4901183505

Elapsed: 00:00:43.65



--- Otro ejemplo: con filtro !!!

alter session force parallel query parallel 4;
set timing on

select /*+ INMEMORY */ ch.channel_desc, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M_V2 c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
and   c.sales_json.PROMOID = 37
group by ch.channel_desc;

CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
Internet				  9241614
Partners				 10047359
Catalog 				  9562730
Direct Sales				  9973792
Tele Sales				  9890685

Elapsed: 00:00:10.57

alter session force parallel query parallel 4;
set timing on

select /*+ NO_INMEMORY */ ch.channel_desc, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M_V2 c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
and   c.sales_json.PROMOID = 37
group by ch.channel_desc;

CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
Internet				  9241614
Partners				 10047359
Catalog 				  9562730
Direct Sales				  9973792
Tele Sales				  9890685

Elapsed: 00:00:26.44
SQL> 

alter session force parallel query parallel 4;
set timing on
select /*+ INMEMORY */ sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M_V2 c;

SUM(C.SALES_JSON.TOTAL_SOLD)
----------------------------
		  2.4508E+10

Elapsed: 00:00:05.26

alter session force parallel query parallel 4;
set timing on
select /*+ NO_INMEMORY */ sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK_10M_V2 c;

SUM(C.SALES_JSON.TOTAL_SOLD)
----------------------------
		  2.4508E+10

Elapsed: 00:00:26.10


alter session force parallel query parallel 4;
set timing on

select /*+ INMEMORY */ ch.channel_desc, sum(c.sales_json.TOTAL_SOLD), sum(c.sales_json.QUANTITY_SOLD)
from SALES_JSON_CHECK_10M_V2 c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
group by ch.channel_desc;

CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
SUM(C.SALES_JSON.QUANTITY_SOLD)
-------------------------------
Direct Sales			       4904074408
		       98996075

Tele Sales			       4901183505
		       99056126

Internet			       4901286614
		       99019318


CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
SUM(C.SALES_JSON.QUANTITY_SOLD)
-------------------------------
Partners			       4902190890
		       99043708

Catalog 			       4899139710
		       98966195


Elapsed: 00:00:13.47
SQL> SQL> 

alter session force parallel query parallel 4;
set timing on

select /*+ NO_INMEMORY */ ch.channel_desc, sum(c.sales_json.TOTAL_SOLD), sum(c.sales_json.QUANTITY_SOLD)
from SALES_JSON_CHECK_10M_V2 c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
group by ch.channel_desc;

CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
SUM(C.SALES_JSON.QUANTITY_SOLD)
-------------------------------
Internet			       4901286614
		       99019318

Partners			       4902190890
		       99043708

Catalog 			       4899139710
		       98966195


CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
SUM(C.SALES_JSON.QUANTITY_SOLD)
-------------------------------
Direct Sales			       4904074408
		       98996075

Tele Sales			       4901183505
		       99056126


Elapsed: 00:00:27.01

