--- Zonemaps were introduced in 12.1, and are similar to storage indexes on Exadata !!!
REM Ref. https://docs.oracle.com/database/121/DWHSG/zone_maps.htm#DWHSG8947

--- While Storage Indexes are maintained automatically and transparently, Zone maps are not !!!
--- Zone Maps require Exadata features !!!

--- Get all labs scripts (optional) !!!

wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/OKr2yAGkytLaadBqjdMiQKkiUjwgoyvyYaB0YVT2AA4G2sZWr3GG_QZRhv_4gYKS/n/c4u04/b/data-management-library-files/o/Cloud_21c_Labs.zip



---*************************************
--- STEP1: setup environment !!!
---*************************************
--- Machine: rdbms21coniaas !!!
-- Scripts in /home/oracle/labs/M104784GC10

[oracle@rdbms21coniaas ~]$ sqlplus / as sysdba


SQL> show pdbs

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 ORCLPDB1			  READ WRITE NO

col comp_name format a40
col status format a20
set lines 120 pages 100
select COMP_NAME, VERSION_FULL, status from dba_registry;

COMP_NAME				 VERSION_FULL			STATUS
---------------------------------------- ------------------------------ --------------------
Oracle Database Catalog Views		 21.3.0.0.0			VALID
Oracle Database Packages and Types	 21.3.0.0.0			VALID
Oracle Real Application Clusters	 21.3.0.0.0			OPTION OFF
JServer JAVA Virtual Machine		 21.3.0.0.0			VALID
Oracle XDK				 21.3.0.0.0			VALID
Oracle Database Java Packages		 21.3.0.0.0			VALID
OLAP Analytic Workspace 		 21.3.0.0.0			VALID
Oracle XML Database			 21.3.0.0.0			VALID
Oracle Workspace Manager		 21.3.0.0.0			VALID
Oracle Text				 21.3.0.0.0			VALID
Oracle Multimedia			 21.3.0.0.0			VALID
Oracle OLAP API 			 21.3.0.0.0			VALID
Spatial 				 21.3.0.0.0			VALID
Oracle Locator				 21.3.0.0.0			VALID
Oracle Label Security			 21.3.0.0.0			VALID
Oracle Database Vault			 21.3.0.0.0			VALID

16 rows selected.

[oracle@rdbms21coniaas ~]$ lsnrctl status LISTENER

LSNRCTL for Linux: Version 21.0.0.0.0 - Production on 20-AUG-2021 10:05:14

Copyright (c) 1991, 2021, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=rdbms21coniaas.sub06221433571.skynet.oraclevcn.com)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 21.0.0.0.0 - Production
Start Date                20-AUG-2021 08:41:04
Uptime                    0 days 1 hr. 24 min. 9 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/oracle/homes/OraDBHome21cEE/network/admin/listener.ora
Listener Log File         /opt/oracle/diag/tnslsnr/rdbms21coniaas/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=rdbms21coniaas.sub06221433571.skynet.oraclevcn.com)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=rdbms21coniaas.sub06221433571.skynet.oraclevcn.com)(PORT=5500))(Security=(my_wallet_directory=/opt/oracle/homes/OraDBHome21cEE/admin/ORCLCDB/xdb_wallet))(Presentation=HTTP)(Session=RAW))
Services Summary...
Service "ORCLCDB" has 1 instance(s).
  Instance "ORCLCDB", status READY, has 1 handler(s) for this service...
Service "ORCLCDBXDB" has 1 instance(s).
  Instance "ORCLCDB", status READY, has 1 handler(s) for this service...
Service "c9e72d01b8eaf15ee0538701000aaefe" has 1 instance(s).
  Instance "ORCLCDB", status READY, has 1 handler(s) for this service...
Service "orclpdb1" has 1 instance(s).
  Instance "ORCLCDB", status READY, has 1 handler(s) for this service...
The command completed successfully

---- Since Zone maps require Exadata Storage, turn "_exadata_feature_on" to true:
sqlplus / as sysdba
ALTER SYSTEM SET "_exadata_feature_on"=true SCOPE=SPFILE;
--- And bounce the instance !!!
shutdown immediate
startup

--- Create a schema and a table in the PDB LABS !!!

[oracle@rdbms21coniaas ~]$ sqlplus system/Oracle_4U@rdbms21coniaas:1521/orclpdb1

SQL*Plus: Release 21.0.0.0.0 - Production on Fri Aug 20 10:06:08 2021
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Last Successful login time: Fri Aug 20 2021 10:04:03 +00:00

Connected to:
Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0

SQL> create user USUZM identified by "Oracle_4U" default tablespace USERS temporary tablespace TEMP;

User created.

SQL>

SQL> alter user USUZM quota unlimited on USERS;

User altered.

SQL> grant connect, resource , CREATE MATERIALIZED ZONEMAP to USUZM;

Grant succeeded.

---- Create plustrace role in the PDB, and grant to USUZM !!!

[oracle@rdbms21coniaas ~]$ cd $ORACLE_HOME/sqlplus/admin
[oracle@rdbms21coniaas admin]$ sqlplus sys/Oracle_4U@rdbms21coniaas:1521/orclpdb1 as sysdba

SQL*Plus: Release 21.0.0.0.0 - Production on Fri Aug 20 10:10:05 2021
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.


Connected to:
Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0

SQL> !ls
glogin.sql  help  libsqlplus.def  plustrce.sql	pupbld.sql  pupdel.sql

SQL> @plustrce.sql
SQL>
SQL> drop role plustrace;

Role dropped.

SQL> create role plustrace;

Role created.

SQL>
SQL> grant select on v_$sesstat to plustrace;

Grant succeeded.

SQL> grant select on v_$statname to plustrace;

Grant succeeded.

SQL> grant select on v_$mystat to plustrace;

Grant succeeded.

SQL> grant plustrace to dba with admin option;

Grant succeeded.

SQL>
SQL> set echo off
SQL>


grant plustrace, dba  to USUZM;

Grant succeeded.

SQL> connect USUZM/Oracle_4U@rdbms21coniaas:1521/orclpdb1
Connected.
SQL>

CREATE TABLE sales_zm (sale_id NUMBER(10), customer_id NUMBER(10), amount_sold FLOAT);

--- Populate the table !!!

DECLARE
    i NUMBER(10);
  BEGIN
    FOR i IN 1..80
    LOOP
      INSERT INTO sales_zm
      SELECT ROWNUM, MOD(ROWNUM,1000), MOD(ROWNUM,1000)+1
      FROM   dual
      CONNECT BY LEVEL <= 100000;
     COMMIT;
   END LOOP;
END;
/

SQL> select count(*) from sales_zm;

  COUNT(*)
----------
   8000000   <==== 8 millions rows !!!

--- Collect stats on the table !!!

SQL> EXEC dbms_stats.gather_table_stats(ownname=>NULL, tabname=>'SALES_ZM')

PL/SQL procedure successfully completed.

SQL>

---**************************************************
--- STEP2: do some queries, and get exec stats !!!
---**************************************************

[oracle@rdbms21coniaas admin]$ sqlplus USUZM/Oracle_4U@rdbms21coniaas:1521/orclpdb1

SQL*Plus: Release 21.0.0.0.0 - Production on Fri Aug 20 10:11:38 2021
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Last Successful login time: Fri Aug 20 2021 10:11:11 +00:00

Connected to:
Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0


SQL> set autotrace on statistics
SQL> SELECT COUNT(DISTINCT sale_id) FROM sales_zm WHERE customer_id = 50;

SQL> r
  1* SELECT COUNT(DISTINCT sale_id) FROM sales_zm WHERE customer_id = 50

COUNT(DISTINCTSALE_ID)
----------------------
		   100


Statistics
----------------------------------------------------------
	  0  recursive calls
	  0  db block gets
      19550  consistent gets
	  0  physical reads
	  0  redo size
	582  bytes sent via SQL*Net to client
	 52  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed

---*********************************************************
--- STEP3: create a zonemap with clustering attributes !!!
---*********************************************************

SQL> set autotrace off
SQL> ALTER TABLE sales_zm ADD CLUSTERING BY LINEAR ORDER (customer_id) WITH MATERIALIZED ZONEMAP;

Table altered.

-- Since attribute clustering is a property of the table, any existing rows are not re-ordered. Therefore move the table to cluster the rows together. !!!
ALTER TABLE sales_zm MOVE;


---*********************************************************
--- STEP4: re-run the query, and observe the consistent gets !!!
---*********************************************************

SQL> set autotrace on statistics
SQL> SELECT COUNT(DISTINCT sale_id) FROM sales_zm WHERE customer_id = 50;

COUNT(DISTINCTSALE_ID)
----------------------
		   100


Statistics
----------------------------------------------------------
	 67  recursive calls
	  6  db block gets
       1078  consistent gets    <===== Number of consistent gets drops by 20X !!!
	  0  physical reads
       1396  redo size
	582  bytes sent via SQL*Net to client
	 52  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed



---*********************************************************
--- STEP5: View Zone maps details !!!
---*********************************************************

SQL> set autotrace off
SQL> select table_name from user_tables;


TABLE_NAME
--------------------------------------------------------------------------------
ZMAP$_SALES_ZM
SALES_ZM

SQL> desc ZMAP$_SALES_ZM
 Name					   Null?    Type
 ----------------------------------------- -------- ----------------------------
 ZONE_ID$				   NOT NULL NUMBER
 MIN_1_CUSTOMER_ID				    NUMBER
 MAX_1_CUSTOMER_ID				    NUMBER
 ZONE_LEVEL$					    NUMBER
 ZONE_STATE$					    NUMBER
 ZONE_ROWS$					    NUMBER


set lines 120 pages 100
select * from ZMAP$_SALES_ZM

  ZONE_ID$ MIN_1_CUSTOMER_ID MAX_1_CUSTOMER_ID ZONE_LEVEL$ ZONE_STATE$ ZONE_ROWS$
---------- ----------------- ----------------- ----------- ----------- ----------
3.1776E+11		   0		    42		 0	     0	   341338
3.1776E+11		  42		    99		 0	     0	   458569
3.1776E+11		  99		   150		 0	     0	   407952
3.1776E+11		 150		   202		 0	     0	   408405
3.1776E+11		 202		   252		 0	     0	   407035
3.1776E+11		 252		   303		 0	     0	   408388
3.1776E+11		 303		   354		 0	     0	   407041
3.1776E+11		 354		   405		 0	     0	   408393
3.1776E+11		 405		   457		 0	     0	   410686
3.1776E+11		 457		   508		 0	     0	   413238
3.1776E+11		 508		   560		 0	     0	   411915
3.1776E+11		 560		   612		 0	     0	   413243
3.1776E+11		 612		   663		 0	     0	   411905
3.1776E+11		 663		   715		 0	     0	   413254
3.1776E+11		 715		   766		 0	     0	   411907
3.1776E+11		 766		   818		 0	     0	   413234
3.1776E+11		 818		   869		 0	     0	   411903
3.1776E+11		 869		   921		 0	     0	   413240
3.1776E+11		 921		   972		 0	     0	   411904
3.1776E+11		 972		   999		 0	     0	   216450

20 rows selected.

SQL> connect system/Oracle_4U@rdbms21coniaas:1521/orclpdb1
Connected.

COL zonemap_name FORMAT A20
SELECT zonemap_name,automatic,partly_stale, incomplete
FROM dba_zonemaps;

ZONEMAP_NAME	     AUTOMATIC PARTLY_STALE INCOMPLETE
-------------------- --------- ------------ ------------
ZMAP$_SALES_ZM	     NO        NO	    NO

---*********************************************************
--- STEP5: Perform some DMLs on the base table !!!
---*********************************************************

connect USUZM/Oracle_4U@rdbms21coniaas:1521/orclpdb1

SQL> update sales_zm set amount_sold = amount_sold*1.2 where rownum <= 10000;

10000 rows updated.

SQL> commit;

Commit complete.

SQL>

set lines 120 pages 100
select * from ZMAP$_SALES_ZM;

  ZONE_ID$ MIN_1_CUSTOMER_ID MAX_1_CUSTOMER_ID ZONE_LEVEL$ ZONE_STATE$ ZONE_ROWS$
---------- ----------------- ----------------- ----------- ----------- ----------
3.1776E+11		   0		    42		 0	     0	   341338
3.1776E+11		  42		    99		 0	     0	   458569
3.1776E+11		  99		   150		 0	     0	   407952
3.1776E+11		 150		   202		 0	     0	   408405
3.1776E+11		 202		   252		 0	     0	   407035
3.1776E+11		 252		   303		 0	     0	   408388
3.1776E+11		 303		   354		 0	     0	   407041
3.1776E+11		 354		   405		 0	     0	   408393
3.1776E+11		 405		   457		 0	     0	   410686
3.1776E+11		 457		   508		 0	     0	   413238
3.1776E+11		 508		   560		 0	     0	   411915
3.1776E+11		 560		   612		 0	     0	   413243
3.1776E+11		 612		   663		 0	     0	   411905
3.1776E+11		 663		   715		 0	     0	   413254
3.1776E+11		 715		   766		 0	     0	   411907
3.1776E+11		 766		   818		 0	     0	   413234
3.1776E+11		 818		   869		 0	     0	   411903
3.1776E+11		 869		   921		 0	     0	   413240
3.1776E+11		 921		   972		 0	     0	   411904
3.1776E+11		 972		   999		 0	     0	   216450

20 rows selected.

SQL> connect system/Oracle_4U@rdbms21coniaas:1521/orclpdb1
Connected.
SQL> SELECT zonemap_name,automatic,partly_stale, incomplete FROM dba_zonemaps;

ZONEMAP_NAME	     AUTOMATIC PARTLY_STALE INCOMPLETE
-------------------- --------- ------------ ------------
ZMAP$_SALES_ZM	     NO        NO	    NO

--- => As customerID was neither updated nor created, the Zone Maps is not stale !!!!

--- Now I create new rows !!!

connect USUZM/Oracle_4U@rdbms21coniaas:1521/orclpdb1
insert into SALES_ZM (SALE_ID,CUSTOMER_ID,AMOUNT_SOLD) values (99999,50,345);

--- Now let's check the Zone Map again !!!

  ZONE_ID$ MIN_1_CUSTOMER_ID MAX_1_CUSTOMER_ID ZONE_LEVEL$ ZONE_STATE$ ZONE_ROWS$
---------- ----------------- ----------------- ----------- ----------- ----------
3.1776E+11		   0		    42		 0	     0	   341338
3.1776E+11		  42		    99		 0	     0	   458569
3.1776E+11		  99		   150		 0	     0	   407952
3.1776E+11		 150		   202		 0	     0	   408405
3.1776E+11		 202		   252		 0	     0	   407035
3.1776E+11		 252		   303		 0	     0	   408388
3.1776E+11		 303		   354		 0	     0	   407041
3.1776E+11		 354		   405		 0	     0	   408393
3.1776E+11		 405		   457		 0	     0	   410686
3.1776E+11		 457		   508		 0	     0	   413238
3.1776E+11		 508		   560		 0	     0	   411915
3.1776E+11		 560		   612		 0	     0	   413243
3.1776E+11		 612		   663		 0	     0	   411905
3.1776E+11		 663		   715		 0	     0	   413254
3.1776E+11		 715		   766		 0	     0	   411907
3.1776E+11		 766		   818		 0	     0	   413234
3.1776E+11		 818		   869		 0	     0	   411903
3.1776E+11		 869		   921		 0	     0	   413240
3.1776E+11		 921		   972		 0	     0	   411904
3.1776E+11		 972		   999		 0	     0	   216450

20 rows selected.

SQL> 	connect system/Oracle_4U@rdbms21coniaas:1521/orclpdb1
Connected.
SQL> SELECT zonemap_name,automatic,partly_stale, incomplete FROM dba_zonemaps;

ZONEMAP_NAME	     AUTOMATIC PARTLY_STALE INCOMPLETE
-------------------- --------- ------------ ------------
ZMAP$_SALES_ZM	     NO        YES	    YES

SQL>

--- Let's run the query and observe !!!
connect USUZM/Oracle_4U@rdbms21coniaas:1521/orclpdb1

set autotrace on statistics
SELECT COUNT(DISTINCT sale_id) FROM sales_zm WHERE customer_id = 50;

COUNT(DISTINCTSALE_ID)
----------------------
		   101


Statistics
----------------------------------------------------------
	 14  recursive calls
	  0  db block gets
       1059  consistent gets
	  0  physical reads
	132  redo size
	583  bytes sent via SQL*Net to client
	 52  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed

Execution Plan
----------------------------------------------------------
Plan hash value: 1350322768

-----------------------------------------------------------------------------------------------
| Id  | Operation			  | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT		  |	      |     1 |    13 |  5605	(2)| 00:00:01 |
|   1 |  SORT AGGREGATE 		  |	      |     1 |    13 | 	   |	      |
|   2 |   VIEW				  | VM_NWVW_1 |  7695 |    97K|  5605	(2)| 00:00:01 |
|   3 |    HASH GROUP BY		  |	      |  7695 | 69255 |  5605	(2)| 00:00:01 |
|*  4 |     TABLE ACCESS FULL WITH ZONEMAP| SALES_ZM  |  8000 | 72000 |  5604	(2)| 00:00:01 |
-----------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - filter(SYS_ZMAP_FILTER('/* ZM_PRUNING */ SELECT zm."ZONE_ID$", CASE WHEN
	      BITAND(zm."ZONE_STATE$",1)=1 THEN 1 ELSE CASE WHEN (zm."MIN_1_CUSTOMER_ID" > :1 OR
	      zm."MAX_1_CUSTOMER_ID" < :2) THEN 3 ELSE 2 END END FROM "USUZM"."ZMAP$_SALES_ZM" zm
	      WHERE zm."ZONE_LEVEL$"=0 ORDER BY zm."ZONE_ID$"',SYS_OP_ZONE_ID(ROWID),50,50)<3 AND
	      "CUSTOMER_ID"=50)


Statistics
----------------------------------------------------------
	 14  recursive calls
	  0  db block gets
       1054  consistent gets
	  0  physical reads
	  0  redo size
	583  bytes sent via SQL*Net to client
	 52  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed

SQL>

--- Refresh the Zone Map:
connect USUZM/Oracle_4U@rdbms21coniaas:1521/orclpdb1
ALTER MATERIALIZED ZONEMAP ZMAP$_SALES_ZM REBUILD;

SQL> 	connect system/Oracle_4U@rdbms21coniaas:1521/orclpdb1
Connected.
SQL> SELECT zonemap_name,automatic,partly_stale, incomplete FROM dba_zonemaps;

ZONEMAP_NAME	     AUTOMATIC PARTLY_STALE INCOMPLETE
-------------------- --------- ------------ ------------
ZMAP$_SALES_ZM	     NO        NO	    NO



---**************************
--- STEP6: AUTO Zone Map !!!
---**************************

SQL> connect USUZM/Oracle_4U@rdbms21coniaas:1521/orclpdb1
Connected.
SQL> DROP TABLE sales_zm PURGE;

Table dropped.

SELECT zonemap_name, automatic, partly_stale, incomplete
    FROM   dba_zonemaps;

no rows selected

SQL> EXEC DBMS_AUTO_ZONEMAP.CONFIGURE('AUTO_ZONEMAP_MODE','ON')

PL/SQL procedure successfully completed.

---******************************************************************************
--- STEP7: Show how automatic zone maps are created without DBA intervention !!!
---******************************************************************************

CREATE TABLE sales_zm (sale_id NUMBER(10), customer_id NUMBER(10), amount_sold FLOAT);

--- Populate the table !!!

DECLARE
    i NUMBER(10);
  BEGIN
    FOR i IN 1..80
    LOOP
      INSERT INTO sales_zm
      SELECT ROWNUM, MOD(ROWNUM,1000), MOD(ROWNUM,1000)+1
      FROM   dual
      CONNECT BY LEVEL <= 100000;
     COMMIT;
   END LOOP;
END;
/

SQL> select count(*) from sales_zm;

  COUNT(*)
----------
   8000000   <==== 8 millions rows !!!

--- Collect stats on the table !!!

SQL> EXEC dbms_stats.gather_table_stats(ownname=>NULL, tabname=>'SALES_ZM')

PL/SQL procedure successfully completed.

--- Query the SALES_ZM table at least twenty times to see the “consistent gets” value.

set autotrace traceonly explain statistics
SELECT COUNT(DISTINCT sale_id) FROM sales_zm WHERE customer_id = 50;

Execution Plan
----------------------------------------------------------
Plan hash value: 2639661232

----------------------------------------------------------------------------------
| Id  | Operation	     | Name	 | Rows  | Bytes | Cost (%CPU)| Time	 |
----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |		 |     1 |    13 |  5605   (2)| 00:00:01 |
|   1 |  SORT AGGREGATE      |		 |     1 |    13 |	      | 	 |
|   2 |   VIEW		     | VM_NWVW_1 |  7695 |    97K|  5605   (2)| 00:00:01 |
|   3 |    HASH GROUP BY     |		 |  7695 | 69255 |  5605   (2)| 00:00:01 |
|*  4 |     TABLE ACCESS FULL| SALES_ZM  |  8000 | 72000 |  5604   (2)| 00:00:01 |
----------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - filter("CUSTOMER_ID"=50)


Statistics
----------------------------------------------------------
	 11  recursive calls
	 12  db block gets
      19553  consistent gets
	  0  physical reads
       2084  redo size
	582  bytes sent via SQL*Net to client
	 52  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed

---- After 20+ executions, wake-up the background process responsible for AUTO Zone Maps !!!
---- This would happen automatically after a certain amount of time !!!

sqlplus sys/Oracle_4U@rdbms21coniaas:1521/orclpdb1 as sysdba

BEGIN
 sys.dbms_auto_zonemap_internal.zmap_execute;
END;
/

PL/SQL procedure successfully completed.


-- Then re-run the query !!!

sqlplus USUZM/Oracle_4U@rdbms21coniaas:1521/orclpdb1
col zonemap_name format a30
SELECT zonemap_name, automatic, partly_stale, incomplete
    FROM   dba_zonemaps;

ZONEMAP_NAME		       AUTOMATIC PARTLY_STALE INCOMPLETE
------------------------------ --------- ------------ ------------
ZMAP$_SALES_ZM		       YES	 NO	      NO

--- Check the Auto Zone Maps actions !!!

SQL> SELECT task_id, msg_id, action_msg  FROM dba_zonemap_auto_actions;

   TASK_ID     MSG_ID
---------- ----------
ACTION_MSG
--------------------------------------------------------------------------------
	 7	   63
BS:Current execution task id: 7 Execution name: SYS_ZMAP_2021-08-20/10:47:13 Tas
k Name: ZMAP_TASK1

	 7	   64
BS:******** Zonemap Background Action Report for Task ID: 7 ****************

	 7	   65
TP:Trying to create zonemap on table: SALES_ZM owner:USUZM

   TASK_ID     MSG_ID
---------- ----------
ACTION_MSG
--------------------------------------------------------------------------------

	 7	   66
AL:Block count : 20297, sample percent is : 2.463418

	 7	   67
TP:col name:AMOUNT_SOLD: clustering ratio: .94

	 7	   68
TP:col name:CUSTOMER_ID: clustering ratio: .95

   TASK_ID     MSG_ID
---------- ----------
ACTION_MSG
--------------------------------------------------------------------------------

	 7	   69
TP:col name:SALE_ID: clustering ratio: .43

	 7	   70
TP:Candidate column list:SALE_ID

	 7	   71
TP:New zonemap name: ZMAP$_SALES_ZM

   TASK_ID     MSG_ID
---------- ----------
ACTION_MSG
--------------------------------------------------------------------------------

	 7	   72
TP:Creating new zonemap ZMAP$_SALES_ZM on table SALES_ZM owner USUZMtable space
USERS

	 7	   73
BS:succesfully created zonemap: ZN:ZMAP$_SALES_ZM BT:SALES_ZM SN:USUZM CL:SALE_I
D CT:+00 00:00:02.360038 TS:2021-08-20/10:47:17 DP:2


   TASK_ID     MSG_ID
---------- ----------
ACTION_MSG
--------------------------------------------------------------------------------
	 7	   74
BS:****** End of Zonemap Background Action Report for Task ID: 7 **********


12 rows selected.

SQL> set long 1000000
  1* SELECT dbms_auto_zonemap.activity_report(systimestamp-2, systimestamp, 'TEXT') as CCCP FROM dual
SQL> /

CCCP
--------------------------------------------------------------------------------
/orarep/autozonemap/main%3flevel%3d GENERAL SUMMARY
-------------------------------------------------------------------------------
 Activity Start    18-AUG-2021 10:53:18.000000000 +00:00
 Activity End	   20-AUG-2021 10:53:18.314786000 +00:00
 Total Executions  1
-------------------------------------------------------------------------------


EXECUTION SUMMARY
-------------------------------------------------------------------------------
 zonemaps created		       1

CCCP
--------------------------------------------------------------------------------
 zonemaps compiled		       0
 zonemaps dropped		       0
 Stale zonemaps complete refreshed     0
 Partly stale zonemaps fast refreshed  0
 Incomplete zonemaps fast refreshed    0
-------------------------------------------------------------------------------


NEW ZONEMAPS DETAILS
-------------------------------------------------------------------------------
 Zonemap	 Base Table  Schema  Operation time  Date created	  DOP  C

CCCP
--------------------------------------------------------------------------------
olumn list
 ZMAP$_SALES_ZM  SALES_ZM    USUZM   00:00:02.36     2021-08-20/10:47:17  2    S
ALE_ID
-------------------------------------------------------------------------------


ZONEMAPS MAINTENANCE DETAILS
-------------------------------------------------------------------------------
 Zonemap  Previous State  Current State  Refresh Type  Operation Time  Dop  Date
 Maintained
-------------------------------------------------------------------------------

CCCP
--------------------------------------------------------------------------------


FINDINGS
-------------------------------------------------------------------------------
 Execution Name  Finding Name  Finding Reason  Finding Type  Message

---- See how many Zone maps were automatically created !!!
---
SQL> set feedback 1
SQL> r
  1  SELECT * FROM dba_zonemap_auto_actions
  2* WHERE action_msg LIKE '%succesfully created zonemap:%' ORDER BY TIME_STAMP

   TASK_ID     MSG_ID
---------- ----------
EXEC_NAME
--------------------------------------------------------------------------------
ACTION_MSG
--------------------------------------------------------------------------------
TIME_STAMP
---------------------------------------------------------------------------
	 7	   73
SYS_ZMAP_2021-08-20/10:47:13
BS:succesfully created zonemap: ZN:ZMAP$_SALES_ZM BT:SALES_ZM SN:USUZM CL:SALE_I
D CT:+00 00:00:02.360038 TS:2021-08-20/10:47:17 DP:2
20-AUG-21 10.47.17.000000000 AM

   TASK_ID     MSG_ID
---------- ----------
EXEC_NAME
--------------------------------------------------------------------------------
ACTION_MSG
--------------------------------------------------------------------------------
TIME_STAMP
---------------------------------------------------------------------------


1 row selected.

SQL>

---- Update the SALE_ID column vales in SALES_ZM table.

UPDATE sales_zm SET sale_id=sale_id*10 WHERE customer_id = 50;
UPDATE sales_zm SET sale_id=sale_id*9 WHERE customer_id = 51;
UPDATE sales_zm SET sale_id=sale_id*8 WHERE customer_id = 775;
UPDATE sales_zm SET sale_id=sale_id*7 WHERE customer_id = 777;
COMMIT;

8000 rows updated.

SQL>
8000 rows updated.

SQL>
8000 rows updated.

SQL>
8000 rows updated.

SQL>

Commit complete.


-- Display the status of the zone map maintenance.

SELECT zonemap_name, automatic, partly_stale, incomplete
    FROM   dba_zonemaps;

ZONEMAP_NAME		       AUTOMATIC PARTLY_STALE INCOMPLETE
------------------------------ --------- ------------ ------------
ZMAP$_SALES_ZM		       YES	 YES	      NO

1 row selected.

-- Display the activity report until you see actions to automatic zone map maintenance.

SQL> SELECT dbms_auto_zonemap.activity_report(systimestamp-2, systimestamp, 'TEXT') as CCCP FROM dual;

CCCP
--------------------------------------------------------------------------------
/orarep/autozonemap/main%3flevel%3d GENERAL SUMMARY
-------------------------------------------------------------------------------
 Activity Start    18-AUG-2021 10:59:53.000000000 +00:00
 Activity End	   20-AUG-2021 10:59:53.524698000 +00:00
 Total Executions  2
-------------------------------------------------------------------------------


EXECUTION SUMMARY
-------------------------------------------------------------------------------
 zonemaps created		       1

CCCP
--------------------------------------------------------------------------------
 zonemaps compiled		       0
 zonemaps dropped		       0
 Stale zonemaps complete refreshed     0
 Partly stale zonemaps fast refreshed  1
 Incomplete zonemaps fast refreshed    0
-------------------------------------------------------------------------------


NEW ZONEMAPS DETAILS
-------------------------------------------------------------------------------
 Zonemap	 Base Table  Schema  Operation time  Date created	  DOP  C

CCCP
--------------------------------------------------------------------------------
olumn list
 ZMAP$_SALES_ZM  SALES_ZM    USUZM   00:00:02.36     2021-08-20/10:47:17  2    S
ALE_ID
-------------------------------------------------------------------------------


ZONEMAPS MAINTENANCE DETAILS
-------------------------------------------------------------------------------
 Zonemap	 Previous State  Current State	Refresh Type  Operation Time  Do
p  Date Maintained
 ZMAP$_SALES_ZM  PARTLY_STALE	 VALID		REBUILD       00:00:02.25     0

CCCP
--------------------------------------------------------------------------------
   2021-08-20/10:59:31
-------------------------------------------------------------------------------


FINDINGS
-------------------------------------------------------------------------------
 Execution Name  Finding Name  Finding Reason  Finding Type  Message




1 row selected.

SQL> SELECT zonemap_name, automatic, partly_stale, incomplete
    FROM   dba_zonemaps;  2

ZONEMAP_NAME		       AUTOMATIC PARTLY_STALE INCOMPLETE
------------------------------ --------- ------------ ------------
ZMAP$_SALES_ZM		       YES	 NO	      NO

1 row selected.

-- => The Zone Map was refreshed automatically !!!


set autotrace traceonly explain statistics
SELECT sum(amount_sold) FROM sales_zm WHERE sale_id between 50 and 100;

Execution Plan
----------------------------------------------------------
Plan hash value: 249658771

--------------------------------------------------------------------------------
------------

| Id  | Operation			| Name	   | Rows  | Bytes | Cost (%CPU)
| Time	   |

--------------------------------------------------------------------------------
------------

|   0 | SELECT STATEMENT		|	   |	 1 |	 9 |  5595   (2)
| 00:00:01 |

|   1 |  SORT AGGREGATE 		|	   |	 1 |	 9 |
|	   |

|*  2 |   TABLE ACCESS FULL WITH ZONEMAP| SALES_ZM |  4159 | 37431 |  5595   (2)
| 00:00:01 |

--------------------------------------------------------------------------------
------------


Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(SYS_ZMAP_FILTER('/* ZM_PRUNING */ SELECT zm."ZONE_ID$", CASE WHEN
	      BITAND(zm."ZONE_STATE$",1)=1 THEN 1 ELSE CASE WHEN (zm."MAX_1_SALE
_ID" < :1 OR

	      zm."MIN_1_SALE_ID" > :2) THEN 3 ELSE 2 END END FROM "USUZM"."ZMAP$
_SALES_ZM" zm

	      WHERE zm."ZONE_LEVEL$"=0 ORDER BY zm."ZONE_ID$"',SYS_OP_ZONE_ID(RO
WID),50,100)<3

	      AND "SALE_ID"<=100 AND "SALE_ID">=50)


Statistics
----------------------------------------------------------
	 14  recursive calls
	  0  db block gets
      19436  consistent gets
	  0  physical reads
	  0  redo size
	578  bytes sent via SQL*Net to client
	 52  bytes received via SQL*Net from client
	  2  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
	  1  rows processed

SQL>
