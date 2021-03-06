Ref. How To Setup And Use DBMS_CLOUD Package (Doc ID 2748362.1)

--- Generate a SQL script (dbms_cloud_install.sql) with the following:

@$ORACLE_HOME/rdbms/admin/sqlsessstart.sql

set verify off
-- you must not change the owner of the functionality to avoid future issues
define username='C##CLOUD$SERVICE'

create user &username no authentication account lock;

REM Grant Common User Privileges
grant INHERIT PRIVILEGES on user &username to sys;
grant INHERIT PRIVILEGES on user sys to &username;
grant RESOURCE, UNLIMITED TABLESPACE, SELECT_CATALOG_ROLE to &username;
grant CREATE ANY TABLE, DROP ANY TABLE, INSERT ANY TABLE, SELECT ANY TABLE,
CREATE ANY CREDENTIAL, CREATE PUBLIC SYNONYM, CREATE PROCEDURE, ALTER SESSION, CREATE JOB to &username;
grant CREATE SESSION, SET CONTAINER to &username;
grant SELECT on SYS.V_$MYSTAT to &username;
grant SELECT on SYS.SERVICE$ to &username;
grant SELECT on SYS.V_$ENCRYPTION_WALLET to &username;
grant read, write on directory DATA_PUMP_DIR to &username;
grant EXECUTE on SYS.DBMS_PRIV_CAPTURE to &username;
grant EXECUTE on SYS.DBMS_PDB_LIB to &username;
grant EXECUTE on SYS.DBMS_CRYPTO to &username;
grant EXECUTE on SYS.DBMS_SYS_ERROR to &username;
grant EXECUTE ON SYS.DBMS_ISCHED to &username;
grant EXECUTE ON SYS.DBMS_PDB_LIB to &username;
grant EXECUTE on SYS.DBMS_PDB to &username;
grant EXECUTE on SYS.DBMS_SERVICE to &username;
grant EXECUTE on SYS.DBMS_PDB to &username;
grant EXECUTE on SYS.CONFIGURE_DV to &username;
grant EXECUTE on SYS.DBMS_SYS_ERROR to &username;
grant EXECUTE on SYS.DBMS_CREDENTIAL to &username;
grant EXECUTE on SYS.DBMS_RANDOM to &username;
grant EXECUTE on SYS.DBMS_SYS_SQL to &username;
grant EXECUTE on SYS.DBMS_LOCK to &username;
grant EXECUTE on SYS.DBMS_AQADM to &username;
grant EXECUTE on SYS.DBMS_AQ to &username;
grant EXECUTE on SYS.DBMS_SYSTEM to &username;
grant EXECUTE on SYS.SCHED$_LOG_ON_ERRORS_CLASS to &username;
grant SELECT on SYS.DBA_DATA_FILES to &username;
grant SELECT on SYS.DBA_EXTENTS to &username;
grant SELECT on SYS.DBA_CREDENTIALS to &username;
grant SELECT on SYS.AUDIT_UNIFIED_ENABLED_POLICIES to &username;
grant SELECT on SYS.DBA_ROLES to &username;
grant SELECT on SYS.V_$ENCRYPTION_KEYS to &username;
grant SELECT on SYS.DBA_DIRECTORIES to &username;
grant SELECT on SYS.DBA_USERS to &username;
grant SELECT on SYS.DBA_OBJECTS to &username;
grant SELECT on SYS.V_$PDBS to &username;
grant SELECT on SYS.V_$SESSION to &username;
grant SELECT on SYS.GV_$SESSION to &username;
grant SELECT on SYS.DBA_REGISTRY to &username;
grant SELECT on SYS.DBA_DV_STATUS to &username;

alter session set current_schema=&username;
REM Create the Catalog objects
@$ORACLE_HOME/rdbms/admin/dbms_cloud_task_catalog.sql
@$ORACLE_HOME/rdbms/admin/dbms_cloud_task_views.sql
@$ORACLE_HOME/rdbms/admin/dbms_cloud_catalog.sql
@$ORACLE_HOME/rdbms/admin/dbms_cloud_types.sql

REM Create the Package Spec
@$ORACLE_HOME/rdbms/admin/prvt_cloud_core.plb
@$ORACLE_HOME/rdbms/admin/prvt_cloud_task.plb
@$ORACLE_HOME/rdbms/admin/dbms_cloud_capability.sql
@$ORACLE_HOME/rdbms/admin/prvt_cloud_request.plb
@$ORACLE_HOME/rdbms/admin/prvt_cloud_internal.plb
@$ORACLE_HOME/rdbms/admin/dbms_cloud.sql
@$ORACLE_HOME/rdbms/admin/prvt_cloud_admin_int.plb

REM Create the Package Body
@$ORACLE_HOME/rdbms/admin/prvt_cloud_core_body.plb
@$ORACLE_HOME/rdbms/admin/prvt_cloud_task_body.plb
@$ORACLE_HOME/rdbms/admin/prvt_cloud_capability_body.plb
@$ORACLE_HOME/rdbms/admin/prvt_cloud_request_body.plb
@$ORACLE_HOME/rdbms/admin/prvt_cloud_internal_body.plb
@$ORACLE_HOME/rdbms/admin/prvt_cloud_body.plb
@$ORACLE_HOME/rdbms/admin/prvt_cloud_admin_int_body.plb

-- Create the metadata
@$ORACLE_HOME/rdbms/admin/dbms_cloud_metadata.sql

alter session set current_schema=sys;

@$ORACLE_HOME/rdbms/admin/sqlsessend.sql

--- Then run the script with the catcon.pl utility:

$ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -u sys/Oracle_4U --force_pdb_mode 'READ WRITE' -b dbms_cloud_install -d /home/oracle -l /home/oracle dbms_cloud_install.sql

[oracle@rdbms21coniaas ~]$ $ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -u sys/Oracle_4U --force_pdb_mode 'READ WRITE' -b dbms_cloud_install -d /home/oracle -l /home/oracle dbms_cloud_install.sql
catcon::set_log_file_base_path: ALL catcon-related output will be written to [/home/oracle/dbms_cloud_install_catcon_1715110.lst]

catcon::set_log_file_base_path: catcon: See [/home/oracle/dbms_cloud_install*.log] files for output generated by scripts

catcon::set_log_file_base_path: catcon: See [/home/oracle/dbms_cloud_install_*.lst] files for spool files, if any

catcon.pl: completed successfully
[oracle@rdbms21coniaas ~]$

[oracle@rdbms21coniaas ~]$ ls -ltr
total 33772
-rw-r--r--. 1 oracle oinstall  1786522 Feb 10  2021 tpc-h_v3.0.0.pdf
-rw-r--r--. 1 oracle oinstall   383884 Feb 10  2021 tpc-h_v3.0.0.docx
drwxr-xr-x. 5 oracle oinstall      117 Mar 10 16:23 TPC-H_Tools_v3.0.0
-rw-r--r--. 1 oracle oinstall 32364686 Jul  2 19:25 Cloud_21c_Labs.zip
-rw-r--r--. 1 oracle oinstall      177 Aug 19 09:35 ORCLCDB.env
drwxrwxrwx. 9 oracle oinstall      161 Aug 20 12:02 labs
lrwxrwxrwx. 1 oracle oinstall       29 Aug 23 12:20 tpch -> /u02/TPC-H_Tools_v3.0.0/DATA/
-rw-r--r--. 1 oracle oinstall     3652 Sep  7 11:29 dbms_cloud_install.sql
-rw-------. 1 oracle oinstall      435 Sep  7 11:31 dbms_cloud_install_catcon_1715110.lst
-rw-------. 1 oracle oinstall    12268 Sep  7 11:32 dbms_cloud_install0.log
-rw-------. 1 oracle oinstall     6467 Sep  7 11:32 dbms_cloud_install1.log
-rw-------. 1 oracle oinstall     6439 Sep  7 11:32 dbms_cloud_install2.log
[oracle@rdbms21coniaas ~]$

[oracle@rdbms21coniaas ~]$ cat dbms_cloud_install_catcon_1715110.lst
catcon: See [/home/oracle/dbms_cloud_install*.log] files for output generated by scripts

catcon: See [/home/oracle/dbms_cloud_install_*.lst] files for spool files, if any


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

catcon version: /st_rdbms_21/3
	catconInit2: start logging catcon output at 2021-09-07 11:31:35

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



[oracle@rdbms21coniaas ~]$

--- Check that DBMS_CLOUD has been installed in CDB$ROOT and all the PDBs

desc DBMS_CLOUD

=> OK


