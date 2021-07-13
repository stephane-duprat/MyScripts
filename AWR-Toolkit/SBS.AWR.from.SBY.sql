Bug reported for versions 19.9 and backward

SQL>  exec DBMS_UMF.register_node ('Topology_1', 'TSTN01_STANDBY', 'AWR_PRI2STB','AWR_STB2PRI','FALSE','FALSE')
BEGIN DBMS_UMF.register_node ('Topology_1', 'TSTN01_STANDBY', 'AWR_PRI2STB','AWR_STB2PRI','FALSE','FALSE'); END;

*
ERROR at line 1:
ORA-15769: node [TSTN01_STANDBY] is not registered in RMF topology [Topology_1]
ORA-06512: at "SYS.DBMS_UMF_INTERNAL", line 168
ORA-06512: at "SYS.DBMS_UMF_INTERNAL", line 206
ORA-06512: at "SYS.DBMS_UMF", line 671
ORA-06512: at line 1
ORA-06512: at "SYS.DBMS_UMF", line 643
ORA-06512: at "SYS.DBMS_UMF", line 561
ORA-06512: at line 1

SQL> select * from dba_umf_registration;

TOPOLOGY_NAME
--------------------------------------------------------------------------------
NODE_NAME
--------------------------------------------------------------------------------
   NODE_ID  NODE_TYPE AS_SOURCE            AS_CANDIDATE_TARGET
---------- ---------- -------------------- --------------------
STATE
--------------------------------------------------------------------------------
Topology_1
TSTN01_PRIMARY
2497751589          0 FALSE                FALSE
OK

Topology_1
TSTN01_STANDBY
 379644051          0 FALSE                FALSE
REGISTRATION PENDING


Fixed in 19.10+
Fixed on 19.9 with one-off patch 

Oracle Database 19 Release 19.9.0.0.201020DBRU

ORACLE DATABASE Patch for Bug# 29961360 for Linux-x86-64 Platforms

This patch is RAC Rolling Installable  - Please read My Oracle Support Document 244241.1 https://support.us.oracle.com/oip/faces/secure/km/DocumentDisplay.jspx?id=244241.1
Rolling Patch - OPatch Support for RAC.

This patch is Data Guard Standby-First Installable - Please read My Oracle Support Note 1265700.1 https://support.us.oracle.com/oip/faces/secure/km/DocumentDisplay.jspx?id=1265700.1
Oracle Patch Assurance - Data Guard Standby-First Patch Apply for details on how to remove risk and reduce downtime when applying this patch.

Released: Thu Nov 19 00:45:40 2020
 
This document describes how you can install the ORACLE DATABASE overlay patch for bug#  29961360 on your Oracle Database 19 Release 19.9.0.0.201020DBRU

a. On the primary DB, unlock the SYS$UMF user !!!

sqlplus / as sysdba
alter user sys$umf identified by "AZZSSSSS0r_cle#1" account unlock;

User altered.

SQL>

b. Create db links from primary to standby and from standby to primary !!!

--- On the primary !!!

--- TNS entry to primary and standby !!!

DBSDU_TSE=(DESCRIPTION=(SDU=65535)(SEND_BUF_SIZE=10485760)(RECV_BUF_SIZE=10485760)(ADDRESS=(PROTOCOL=TCP)(HOST=10.0.1.107)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=DBSDU_TSE.sub06221433571.skynet.oraclevcn.com)))
DBSDU_FRA2BW=(DESCRIPTION=(SDU=65535)(SEND_BUF_SIZE=10485760)(RECV_BUF_SIZE=10485760)(ADDRESS=(PROTOCOL=TCP)(HOST=10.0.1.153)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=DBSDU_fra2bw.sub06221433571.skynet.oraclevcn.com)(UR=A)))


sqlplus / as sysdba

create database link dbl_pri2sby connect to sys$umf identified by "AZZSSSSS0r_cle#1"
using 'DBSDU_FRA2BW';

SQL> alter system set global_names=FALSE scope=both;

System altered.

SQL> select * from dual@dbl_pri2sby;

D
-
X

select * from dual@dbl_pri2sby;

create database link dbl_sby2pri connect to sys$umf identified by "AZZSSSSS0r_cle#1"
using 'DBSDU_TSE';

-- Test the second dblink from the standby !!!

sqlplus / as sysdba
SQL> alter system set global_names=FALSE scope=both;

System altered.

SQL> select * from dual@dbl_sby2pri;

D
-
X


c. Step 4: Now we need to configure database to add topology. Each database name must be assigned a unique name. 
Default name is db_unique_name. In my case DBSDU_TSE and DBSDU_FRA2BW.

-- On the primary !!!
sqlplus / as sysdba
exec dbms_umf.configure_node('DBSDU_TSE')

PL/SQL procedure successfully completed.

-- On the standby !!!
sqlplus / as sysdba
exec dbms_umf.configure_node('DBSDU_FRA2BW')

PL/SQL procedure successfully completed.

d. Create RMF topology
DBMS_UMF.CREATE_TOPOLOGY procedure creates the RMF topology and designates the node on which it is executed as the destination node for that topology.

--- On the primary !!!

sqlplus / as sysdba
exec DBMS_UMF.create_topology ('Topology_1')

PL/SQL procedure successfully completed.

e. Check DBA_UMF_REGISTRATION and dba_umf_topology view

--- On the primary !!!

select * from dba_umf_topology;

TOPOLOGY_NAME			TARGET_ID TOPOLOGY_VERSION TOPOLOGY
------------------------------ ---------- ---------------- --------
Topology_1		       2900169349		 1 ACTIVE


select * from DBA_UMF_REGISTRATION

TOPOLOGY_NAME		       NODE_NAME	       NODE_ID	NODE_TYPE AS_SO AS_CA STATE
------------------------------ -------------------- ---------- ---------- ----- ----- --------------------
Topology_1		       DBSDU_TSE	    2900169349		0 FALSE FALSE OK

SQL>

f. Register the standby database with topology

--- On the primary !!!

sqlplus / as sysdba
exec DBMS_UMF.register_node ('Topology_1', 'DBSDU_FRA2BW', 'dbl_pri2sby', 'dbl_sby2pri', 'FALSE','FALSE')

PL/SQL procedure successfully completed.

g. Enable AWR service on the remote node

--- On the primary !!!

sqlplus / as sysdba
exec DBMS_WORKLOAD_REPOSITORY.register_remote_database(node_name=>'DBSDU_FRA2BW')

PL/SQL procedure successfully completed.

h. Now again verify in dba_umf_registration view


select * from DBA_UMF_REGISTRATION

TOPOLOGY_NAME		       NODE_NAME	       NODE_ID	NODE_TYPE AS_SO AS_CA STATE
------------------------------ -------------------- ---------- ---------- ----- ----- --------------------
Topology_1		       DBSDU_TSE	    2900169349		0 FALSE FALSE OK
Topology_1		       DBSDU_FRA2BW	    3442244332		0 FALSE FALSE OK


i. Create snapshot using RMF in the primary database for the remote database.

--- On the primary !!!

sqlplus / as sysdba
exec dbms_workload_repository.create_remote_snapshot('DBSDU_FRA2BW')

PL/SQL procedure successfully completed.

j. Generate read only workload on the standby !!!!

sqlplus system/AZZSSSSS0r_cle#1@"dbcnsby.sub06221433571.skynet.oraclevcn.com:1521/pdbsdu.sub06221433571.skynet.oraclevcn.com"

select /* CCCP */ owner, sum(bytes)/1024/1024/1024 as GB from dba_segments group by owner;

k. Create snapshot using RMF in the primary database for the remote database.

sqlplus / as sysdba
exec dbms_workload_repository.create_remote_snapshot('DBSDU_FRA2BW')

l. Create AWR report from a standby database

Note: NODE ID generated above consider as DBID for a standby database.

--- On the primary !!!

sqlplus / as sysdba
@?/rdbms/admin/awrrpti

Specify the Report Type
~~~~~~~~~~~~~~~~~~~~~~~
AWR reports can be generated in the following formats.	Please enter the
name of the format at the prompt. Default value is 'html'.

   'html'	   HTML format (default)
   'text'	   Text format
   'active-html'   Includes Performance Hub active report

Enter value for report_type: text



Type Specified: text


Instances in this Workload Repository schema
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  DB Id      Inst Num	DB Name      Instance	  Host
------------ ---------- ---------    ----------   ------
  3442244332	 1	DBSDU	     DBSDU	  dbcnsby
  549332648	 1	DBSDU	     DBSDU	  dbcnsby
* 549332648	 1	DBSDU	     DBSDU	  dbcn

Enter value for dbid: 3442244332
Using 3442244332 for database Id
Enter value for inst_num: 1
Using 1 for instance number


Specify the number of days of snapshots to choose from
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Entering the number of days (n) will result in the most recent
(n) days of snapshots being listed.  Pressing <return> without
specifying a number lists all completed snapshots.


Enter value for num_days: 1

Listing the last day's Completed Snapshots
Instance     DB Name	  Snap Id	Snap Started	Snap Level
------------ ------------ ---------- ------------------ ----------

DBSDU	     DBSDU		  1  29 Jun 2021 13:50	  1
				  2  29 Jun 2021 14:00	  1


[...]

End of Report
Report written to SBY_awrrpt_1_1_2.txt


[oracle@dbcn admin]$ head -20 SBY_awrrpt_1_1_2.txt

WORKLOAD REPOSITORY report for

DB Name         DB Id    Unique Name DB Role          Edition Release    RAC CDB
------------ ----------- ----------- ---------------- ------- ---------- --- ---
DBSDU         3442244332 DBSDU_fra2b PHYSICAL STANDBY XP      21.0.0.0.0 NO  YES

Instance     Inst Num Startup Time    User Name    System Data Visible
------------ -------- --------------- ------------ --------------------
DBSDU               1 23-Jun-21 09:29 SYS          YES

Container DB Id  Container Name       Open Time
--------------- --------------- ---------------
      549332648 CDB$ROOT        29-Jun-21 13:19
     3068248347 PDB$SEED        29-Jun-21 13:19
     3978915883 PDBSDU          29-Jun-21 13:20

Host Name        Platform                         CPUs Cores Sockets Memory(GB)
---------------- -------------------------------- ---- ----- ------- ----------
dbcnsby          Linux x86 64-bit                    2     1       1      14.43

=> IT WORKS !!!








