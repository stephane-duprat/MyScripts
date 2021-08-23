--- Demonstrate Auto IMC 21c feature !!!
--- Environment: rdbms21coniaas (21.3)
-- *************************
-- Step1: Initial setup !!!
-- *************************

sqlplus / as sysdba
SET ECHO ON
ALTER SYSTEM SET sga_target=5G SCOPE=spfile;
ALTER SYSTEM SET inmemory_size=110M SCOPE=SPFILE;
ALTER SYSTEM SET query_rewrite_integrity=stale_tolerated SCOPE=SPFILE;
ALTER SYSTEM SET "_exadata_feature_on"=true scope=spfile;
ALTER SYSTEM SET INMEMORY_AUTOMATIC_LEVEL=LOW SCOPE=SPFILE;
CONNECT sys/Oracle_4U@rdbms21coniaas:1521/orclpdb1 as sysdba
ALTER SYSTEM SET INMEMORY_AUTOMATIC_LEVEL=LOW SCOPE=SPFILE;
ALTER SYSTEM SET query_rewrite_integrity=stale_tolerated SCOPE=SPFILE;

sqlplus / as sysdba
shutdown immediate
startup
alter pluggable database ORCLPDB1 open;



SQL> shutdown immediate
Database closed.
Database dismounted.
ORACLE instance shut down.
SQL> startup
ORACLE instance started.

Total System Global Area 5368706960 bytes
Fixed Size		    9697168 bytes
Variable Size		 1073741824 bytes
Database Buffers	 4160749568 bytes
Redo Buffers		    7077888 bytes
In-Memory Area		  117440512 bytes
Database mounted.
Database opened.
SQL>



--- Create a new tablespace !!!

sqlplus sys/Oracle_4U@rdbms21coniaas:1521/orclpdb1 as sysdba

DROP TABLESPACE imtbs INCLUDING CONTENTS AND DATAFILES cascade constraints;
CREATE TABLESPACE imtbs DATAFILE '/opt/oracle/oradata/ORCLCDB/ORCLPDB1/imtbs.dbf' SIZE 10G reuse;

--- Create and populate HR schema !!!
sys/Oracle_4U@rdbms21coniaas:1521/orclpdb1 as sysdba
@/home/oracle/labs/M104783GC10/hr_main.sql Oracle_4U imtbs temp /tmp
@/home/oracle/labs/M104783GC10/IM_21c_emp.sql

---***************************************
-- Step 2: configure the IMC tables !!!
---***************************************
sqlplus sys/Oracle_4U@rdbms21coniaas:1521/orclpdb1 as sysdba

COL table_name FORMAT A18

SELECT table_name, inmemory, inmemory_compression
FROM   dba_tables WHERE  owner='HR';

TABLE_NAME	   INMEMORY INMEMORY_COMPRESS
------------------ -------- -----------------
COUNTRIES	   DISABLED
REGIONS 	   DISABLED
LOCATIONS	   DISABLED
DEPARTMENTS	   DISABLED
JOBS		   DISABLED
EMPLOYEES	   DISABLED
JOB_HISTORY	   DISABLED
EMP		   ENABLED  FOR QUERY LOW

8 rows selected.

SQL> ALTER TABLE hr.job_history INMEMORY MEMCOMPRESS FOR CAPACITY LOW;

Table altered.


SQL> SELECT table_name, inmemory, inmemory_compression
FROM   dba_tables WHERE  owner='HR';  2

TABLE_NAME	   INMEMORY INMEMORY_COMPRESS
------------------ -------- -----------------
COUNTRIES	   DISABLED
REGIONS 	   DISABLED
LOCATIONS	   DISABLED
DEPARTMENTS	   DISABLED
JOBS		   DISABLED
EMPLOYEES	   DISABLED
JOB_HISTORY	   ENABLED  FOR CAPACITY LOW
EMP		   ENABLED  FOR QUERY LOW

8 rows selected.

---***************************************
-- Step 3: configure Auto IMC !!!
---***************************************
[oracle@rdbms21coniaas ~]$ sqlplus / as sysdba

SQL*Plus: Release 21.0.0.0.0 - Production on Mon Aug 23 07:53:15 2021
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.


Connected to:
Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0

SQL> ALTER SYSTEM SET INMEMORY_AUTOMATIC_LEVEL=HIGH SCOPE=SPFILE;

System altered.

SQL>


SQL> shutdown immediate
Database closed.
Database dismounted.
ORACLE instance shut down.
SQL> startup
ORACLE instance started.

Total System Global Area 5368706960 bytes
Fixed Size		    9697168 bytes
Variable Size		 1073741824 bytes
Database Buffers	 4160749568 bytes
Redo Buffers		    7077888 bytes
In-Memory Area		  117440512 bytes
Database mounted.
Database opened.
SQL> show pdbs

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 ORCLPDB1			  MOUNTED
SQL> alter pluggable database ORCLPDB1 open;

Pluggable database altered.

SQL> show pdbs

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 ORCLPDB1			  READ WRITE NO
SQL>

[oracle@rdbms21coniaas ~]$ sqlplus sys/Oracle_4U@rdbms21coniaas:1521/orclpdb1 as sysdba

SQL*Plus: Release 21.0.0.0.0 - Production on Mon Aug 23 08:01:35 2021
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.


Connected to:
Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0

SQL> COL table_name FORMAT A18

SELECT table_name, inmemory, inmemory_compression
FROM   dba_tables WHERE  owner='HR';

TABLE_NAME	   INMEMORY INMEMORY_COMPRESS
------------------ -------- -----------------
COUNTRIES	   DISABLED
REGIONS 	   DISABLED
LOCATIONS	   DISABLED
DEPARTMENTS	   DISABLED
JOBS		   DISABLED
EMPLOYEES	   DISABLED
JOB_HISTORY	   ENABLED  FOR CAPACITY LOW
EMP		   ENABLED  FOR QUERY LOW

8 rows selected.

-- Why are the HR tables not enabled to INMEMORY, except those already manually set to INMEMORY? Display the INMEMORY_AUTOMATIC_LEVEL in the PDB.

SQL> SHOW PARAMETER INMEMORY_AUTOMATIC_LEVEL

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
inmemory_automatic_level	     string	 LOW
SQL>

SQL> SELECT ispdb_modifiable FROM v$parameter WHERE name='inmemory_automatic_level';

ISPDB
-----
TRUE

SQL>

SQL> shutdown immediate
Pluggable Database closed.
SQL> startup
Pluggable Database opened.
SQL> SHOW PARAMETER INMEMORY_AUTOMATIC_LEVEL

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
inmemory_automatic_level	     string	 HIGH
SQL>

---***************************************
-- Step 4: Test !!!
---***************************************

sqlplus sys/Oracle_4U@rdbms21coniaas:1521/orclpdb1 as sysdba

--- After a while (5mn):

SQL> r
  1  SELECT table_name, inmemory, inmemory_compression
  2* FROM   dba_tables WHERE  owner='HR'

TABLE_NAME	   INMEMORY INMEMORY_COMPRESS
------------------ -------- -----------------
COUNTRIES	   DISABLED
REGIONS 	   ENABLED  AUTO
LOCATIONS	   ENABLED  AUTO
DEPARTMENTS	   ENABLED  AUTO
JOBS		   ENABLED  AUTO
EMPLOYEES	   ENABLED  AUTO
JOB_HISTORY	   ENABLED  FOR CAPACITY LOW
EMP		   ENABLED  FOR QUERY LOW

8 rows selected.

-- Observe that HR.JOB_HISTORY and HR.JOB_EMP which were manually specified as INMEMORY, retain their previous settings.

SQL> ALTER TABLE hr.countries INMEMORY;
ALTER TABLE hr.countries INMEMORY
*
ERROR at line 1:
ORA-64358: in-memory column store feature not supported for IOTs

-- Populate the employees table !!!

sqlplus sys/Oracle_4U@rdbms21coniaas:1521/orclpdb1 as sysdba
begin
for i in (select constraint_name, table_name from dba_constraints where table_name='EMPLOYEES') LOOP
execute immediate 'alter table hr.employees drop constraint '||i.constraint_name||' CASCADE';
end loop;
end;
/
drop index hr.EMP_EMP_ID_PK;

INSERT INTO hr.employees SELECT * FROM hr.employees;
/
/
/
/
/
/
/
/
COMMIT;
/
/
/
/
/
/
COMMIT;

SELECT /*+ FULL(hr.employees) NO_PARALLEL(hr.employees) */ count(*) FROM hr.employees;
SELECT /*+ FULL(hr.departments) NO_PARALLEL(hr.departments) */ count(*) FROM hr.departments;
SELECT /*+ FULL(hr.locations) NO_PARALLEL(hr.locations) */ count(*) FROM hr.locations;
SELECT /*+ FULL(hr.jobs) NO_PARALLEL(hr.jobs) */ count(*) FROM hr.jobs;
SELECT /*+ FULL(hr.regions) NO_PARALLEL(hr.regions) */ count(*) FROM hr.regions;
SELECT /*+ FULL(hr.emp) NO_PARALLEL(hr.emp) */ count(*) FROM hr.emp;

SELECT segment_name, inmemory_size, bytes_not_populated, inmemory_compression FROM v$im_segments;


SQL> r
  1* SELECT segment_name, inmemory_size, bytes_not_populated, inmemory_compression FROM v$im_segments

SEGMENT_NAME
--------------------------------------------------------------------------------
INMEMORY_SIZE BYTES_NOT_POPULATED INMEMORY_COMPRESS
------------- ------------------- -----------------
EMPLOYEES
      1310720			0 AUTO



-- Observe the HR.EMPLOYEES table is now populated with an INMEMORY_COMPRESS value set to AUTO. 
-- Compression used the automatic in-memory management based on internal statistics. 
-- After some time, the HR.EMP may be evicted according to the internal statistics. 
-- If you re-query the HR.EMP table, the statistics may decide to evict the HR.EMPLOYEES to let the HR.EMP populate 
-- back into the IM column store.


