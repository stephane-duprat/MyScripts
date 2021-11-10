--- Performance tests on DML redirect !!!
--- Primary DB: VM.Standard2.1 in BJsY:EU-FRANKFURT-1-AD-2
--- Standby DB: VM.Standard2.1 in BJsY:EU-FRANKFURT-1-AD-1
--- RDBMS 21.1

[oracle@dbcnsby ~]$ sqlplus / as sysdba

SQL*Plus: Release 21.0.0.0.0 - Production on Mon Oct 25 16:04:14 2021
Version 21.1.0.0.0

Copyright (c) 1982, 2020, Oracle.  All rights reserved.


Connected to:
Oracle Database 21c EE Extreme Perf Release 21.0.0.0.0 - Production
Version 21.1.0.0.0

SQL> select open_mode, database_role from v$database;

OPEN_MODE	     DATABASE_ROLE
-------------------- ----------------
READ WRITE	     PRIMARY

SQL> show pdbs

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 PDBSDU			  READ WRITE NO

SQL> show parameter adg_redirect_dml

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
adg_redirect_dml		     boolean	 FALSE

--- Need to change to TRUE on both sides !!!

alter system set adg_redirect_dml = TRUE scope=both;

alter session set container=PDBSDU;
create user TESTDML identified by "AaZZ0r_cle#1" default tablespace USERS temporary tablespace TEMP;

User created.

SQL> grant connect, resource to TESTDML;

Grant succeeded.

SQL> alter user TESTDML quota unlimited on USERS;

User altered.

SQL> create table TESTDML.TT (c1 varchar2(100));

Table created.

set timing on
BEGIN
    FOR i in 1..10000
    LOOP
        insert into TESTDML.TT (c1) values ('This is line number ' || to_char(i));
        commit;
    END LOOP;
END;
/

PL/SQL procedure successfully completed.

Elapsed: 00:00:02.98

-- => 2.98/10000 s/trx

--- Now we will perform the same test on the standby !!!

[oracle@dbcn ~]$ sqlplus / as sysdba

SQL*Plus: Release 21.0.0.0.0 - Production on Mon Oct 25 16:14:12 2021
Version 21.1.0.0.0

Copyright (c) 1982, 2020, Oracle.  All rights reserved.


Connected to:
Oracle Database 21c EE Extreme Perf Release 21.0.0.0.0 - Production
Version 21.1.0.0.0

SQL> show parameter adg_redirect_dml

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
adg_redirect_dml		     boolean	 FALSE
SQL> alter system set adg_redirect_dml=TRUE scope=both;

System altered.

SQL> show parameter adg_redirect_dml

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
adg_redirect_dml		     boolean	 TRUE
SQL> select open_mode, database_role from v$database;

OPEN_MODE	     DATABASE_ROLE
-------------------- ----------------
READ ONLY WITH APPLY PHYSICAL STANDBY

alter session set container = PDBSDU;

SQL> select count(*) from TESTDML.TT;

  COUNT(*)
----------
     10000     <==== These are the rows inserted from the primary !!!


set timing on
BEGIN
    FOR i in 1..10000
    LOOP
        insert into TESTDML.TT (c1) values ('This is line number ' || to_char(i));
        commit;
    END LOOP;
END;
/

BEGIN
*
ERROR at line 1:
ORA-16397: statement redirection from Oracle Active Data Guard standby database
to primary database failed
ORA-06512: at line 4


Elapsed: 00:00:00.80

=> This is because we need to connect through TNS to the standby !!!

sqlplus TESTDML/"AaZZ0r_cle#1"@dbcn:1521/pdbsdu.sub06221433571.skynet.oraclevcn.com

set timing on
BEGIN
    FOR i in 1..10000
    LOOP
        insert into TESTDML.TT (c1) values ('This is line number ' || to_char(i));
        commit;
    END LOOP;
END;
/

-- We kill it after 15mn => 65 rows created !!!

-- => 13.8 s/trx


SQL> set timing on
SQL> set time on
16:36:55 SQL> begin
16:37:02   2  insert into TESTDML.TT (c1) values ('This is line number 9999');
16:37:16   3  commit;
16:37:18   4  END;
16:37:22   5  /

PL/SQL procedure successfully completed.

Elapsed: 00:00:21.68
16:37:44 SQL>

--- This is very slow !!!

3s => 10.000 trx on primary
15mn => 65 trx on standby

-- For this testing, ADG was configured in Max Performance !!!

[oracle@dbcn ~]$ dgmgrl
DGMGRL for Linux: Release 21.0.0.0.0 - Production on Tue Oct 26 07:41:16 2021
Version 21.1.0.0.0

Copyright (c) 1982, 2020, Oracle and/or its affiliates.  All rights reserved.

Welcome to DGMGRL, type "help" for information.
DGMGRL> connect / as sysdba
Connected to "DBSDU_TSE"
Connected as SYSDBA.

DGMGRL> show configuration

Configuration - DBSDU_TSE_DBSDU_fra2bw

  Protection Mode: MaxPerformance
  Members:
  DBSDU_fra2bw - Primary database
    DBSDU_TSE    - (*) Physical standby database

Fast-Start Failover: Enabled in Potential Data Loss Mode

Configuration Status:
SUCCESS   (status updated 58 seconds ago)

DGMGRL>

--- We will switch to MAX PROTECTION (SYNC) and repeat the tests !!!
--- First we disable FSFO !!!

DGMGRL> disable FAST_START FAILOVER
Disabled.

DGMGRL> EDIT DATABASE 'DBSDU_fra2bw' SET PROPERTY LogXptMode='SYNC';
Property "logxptmode" updated
DGMGRL> show database 'DBSDU_fra2bw' 'LogXptMode';
  LogXptMode = 'SYNC'
DGMGRL> show database 'DBSDU_TSE' 'LogXptMode';
  LogXptMode = 'ASYNC'
DGMGRL> EDIT DATABASE 'DBSDU_TSE' SET PROPERTY LogXptMode='SYNC';
Property "logxptmode" updated
DGMGRL> show database 'DBSDU_TSE' 'LogXptMode';
  LogXptMode = 'SYNC'

EDIT CONFIGURATION SET PROTECTION MODE AS MAXAVAILABILITY;

DGMGRL> EDIT CONFIGURATION SET PROTECTION MODE AS MAXAVAILABILITY;
Succeeded.


--- Repeat the same tests !!!

--- On the primary !!!

[oracle@dbcnsby ~]$ sqlplus SYS/"AaZZ0r_cle#1"@dbcnsby:1521/pdbsdu.sub06221433571.skynet.oraclevcn.com as sysdba

SQL*Plus: Release 21.0.0.0.0 - Production on Tue Oct 26 07:55:04 2021
Version 21.1.0.0.0

Copyright (c) 1982, 2020, Oracle.  All rights reserved.


Connected to:
Oracle Database 21c EE Extreme Perf Release 21.0.0.0.0 - Production
Version 21.1.0.0.0

SQL> select open_mode, database_role from v$database;

OPEN_MODE	     DATABASE_ROLE
-------------------- ----------------
READ WRITE	     PRIMARY

SQL> truncate table TESTDML.TT;

Table truncated.

SQL>

set timing on
BEGIN
    FOR i in 1..10000
    LOOP
        insert into TESTDML.TT (c1) values ('This is line number ' || to_char(i));
        commit;
    END LOOP;
END;
/

PL/SQL procedure successfully completed.

Elapsed: 00:00:01.78

--- From the standby !!!

[oracle@dbcn ~]$ sqlplus SYS/"AaZZ0r_cle#1"@dbcn:1521/pdbsdu.sub06221433571.skynet.oraclevcn.com as sysdba

SQL*Plus: Release 21.0.0.0.0 - Production on Tue Oct 26 07:57:19 2021
Version 21.1.0.0.0

Copyright (c) 1982, 2020, Oracle.  All rights reserved.


Connected to:
Oracle Database 21c EE Extreme Perf Release 21.0.0.0.0 - Production
Version 21.1.0.0.0

SQL> select open_mode, database_role from v$database;

OPEN_MODE	     DATABASE_ROLE
-------------------- ----------------
READ ONLY WITH APPLY PHYSICAL STANDBY

SQL> set timing on
BEGIN
insert into TESTDML.TT (c1) values ('This is line number ');
commit;
END;
/SQL>   2    3    4    5

PL/SQL procedure successfully completed.

Elapsed: 00:00:00.92
SQL>

-- Much better than in ASYNC !!!

set timing on
BEGIN
    FOR i in 1..1000
    LOOP
        insert into TESTDML.TT (c1) values ('This is line number ' || to_char(i));
        commit;
    END LOOP;
END;
/

PL/SQL procedure successfully completed.

Elapsed: 00:02:11.77

From primary: 10.000 trx in 1.78s => .000178 s/trx => 0.178 ms/trx
From standby: 1000 trx in 2mn11s  => 0.131 s/trx    => 131 ms/trx  (736 X slower)
