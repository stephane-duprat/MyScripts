SQL> show pdbs

    CON_ID CON_NAME			  OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
	 2 PDB$SEED			  READ ONLY  NO
	 3 PDB20C			  READ WRITE NO
	 4 PDB2 			  READ WRITE NO


-- En la primera PDB, creo un usuario:

sqlplus sys/AaZZ0r_cle#1@dbcn20c:1521/pdb20c.sub05271030030.skynet.oraclevcn.com as sysdba

create user USUTEQ1 identified by "CcZZ0r_cle#3" default tablespace USERS temporary tablespace TEMP;

grant connect, resource to USUTEQ1;
grant execute on dbms_aqadm to USUTEQ1;
grant execute on dbms_aqin to USUTEQ1;
grant execute on dbms_aqjms to USUTEQ1;
grant execute on dbms_aq to usuteq1;
grant create type to usuteq1;
grant select_catalog_role to USUTEQ1;
alter user USUTEQ1 quota unlimited on USERS;

-- Ahora con este usuario creo una TEQ:

sqlplus USUTEQ1/"CcZZ0r_cle#3"@dbcn20c:1521/pdb20c.sub05271030030.skynet.oraclevcn.com

begin
sys.dbms_aqadm.create_sharded_queue(queue_name=>'TEQ1', multiple_consumers => TRUE); 
sys.dbms_aqadm.set_queue_parameter('TEQ1', 'SHARD_NUM', 1);
sys.dbms_aqadm.set_queue_parameter('TEQ1', 'STICKY_DEQUEUE', 1);
sys.dbms_aqadm.set_queue_parameter('TEQ1', 'KEY_BASED_ENQUEUE', 1);
sys.dbms_aqadm.start_queue('TEQ1');
end;
/

--- create_sharded_queue esta deprecado en 20c, hay que utilizar CREATE_TRANSACTIONAL_EVENT_QUEUE !!!

begin
	sys.dbms_aqadm.stop_queue('TEQ1');
	sys.dbms_aqadm.DROP_SHARDED_QUEUE ('TEQ1',true);
end;
/


PROCEDURE CREATE_TRANSACTIONAL_EVENT_QUEUE (
	queue_name             IN VARCHAR2,
	storage_clause         IN VARCHAR2       DEFAULT NULL,
	multiple_consumers     IN BOOLEAN        DEFAULT FALSE,
	max_retries            IN NUMBER         DEFAULT NULL,
	comment                IN VARCHAR2       DEFAULT NULL, 
	queue_payload_type     IN VARCHAR2       DEFAULT JMS_TYPE,
	queue_properties       IN QUEUE_PROPS_T  DEFAULT NULL,
	replication_mode       IN BINARY_INTEGER DEFAULT NONE); 


begin
	sys.dbms_aqadm.CREATE_TRANSACTIONAL_EVENT_QUEUE
	(
		queue_name => 'TEQ1',
		storage_clause => 'tablespace USERS',
		multiple_consumers => TRUE
	);
	sys.dbms_aqadm.set_queue_parameter('TEQ1', 'SHARD_NUM', 1);
	sys.dbms_aqadm.set_queue_parameter('TEQ1', 'STICKY_DEQUEUE', 1);
	sys.dbms_aqadm.set_queue_parameter('TEQ1', 'KEY_BASED_ENQUEUE', 1);
	sys.dbms_aqadm.start_queue('TEQ1');
end;
/

BEGIN
	DBMS_AQADM.CREATE_SHARDED_QUEUE(
		queue_name => 'USUTEQ1.TEQ1',
		multiple_consumers => FALSE, -- False: Queue True: Topic 
		queue_payload_type => DBMS_AQADM.JMS_TYPE);

	DBMS_AQADM.START_QUEUE(queue_name => 'USUTEQ1.TEQ1');
END;
/


SQL> select table_name from user_tables;

TABLE_NAME
--------------------------------------------------------------------------------
TEQ1
AQ$_TEQ1_L
AQ$_TEQ1_X
AQ$_TEQ1_T


SQL> select NAME,QUEUE_TABLE,QUEUE_TYPE,ENQUEUE_ENABLED,DEQUEUE_ENABLED,QUEUE_CATEGORY from user_queues;

NAME
--------------------------------------------------------------------------------
QUEUE_TABLE
--------------------------------------------------------------------------------
QUEUE_TYPE	     ENQUEUE DEQUEUE QUEUE_CATEGORY
-------------------- ------- ------- -------------------------
TEQ1
TEQ1
NORMAL_QUEUE	       YES     YES   Transactional Event Queue

SQL> select QUEUE_SCHEMA, QUEUE_NAME, ENQUEUED_MSGS,DEQUEUED_MSGS from GV$PERSISTENT_QUEUES;

QUEUE_SCHEMA
--------------------------------------------------------------------------------
QUEUE_NAME
--------------------------------------------------------------------------------
ENQUEUED_MSGS DEQUEUED_MSGS
------------- -------------
USUTEQ1
TEQ1
	    0		  0

DECLARE
po dbms_aqadm.aq$_purge_options_t;
BEGIN
   po.block := FALSE;
   DBMS_AQADM.PURGE_QUEUE_TABLE(
     queue_table     => 'USUTEQ1.TEQ1',
     purge_condition => NULL,
     purge_options   => po);
END;
/


--- Ahora en la PDB2:

sqlplus sys/AaZZ0r_cle#1@dbcn20c:1521/pdb2.sub05271030030.skynet.oraclevcn.com as sysdba

create user USUTEQ2 identified by "CcZZ0r_cle#3" default tablespace USERS temporary tablespace TEMP;

grant connect, resource to USUTEQ2;
grant execute on dbms_aqadm to USUTEQ2;
grant execute on dbms_aqin to USUTEQ2;
grant execute on dbms_aqjms to USUTEQ2;
grant execute on dbms_aq to usuteq2;
grant create type to usuteq2;
grant select_catalog_role to USUTEQ2;
alter user USUTEQ2 quota unlimited on USERS;

sqlplus USUTEQ2/"CcZZ0r_cle#3"@dbcn20c:1521/pdb2.sub05271030030.skynet.oraclevcn.com

begin
sys.dbms_aqadm.create_sharded_queue(queue_name=>'TEQ2', multiple_consumers => TRUE); 
sys.dbms_aqadm.set_queue_parameter('TEQ2', 'SHARD_NUM', 1);
sys.dbms_aqadm.set_queue_parameter('TEQ2', 'STICKY_DEQUEUE', 1);
sys.dbms_aqadm.set_queue_parameter('TEQ2', 'KEY_BASED_ENQUEUE', 1);
sys.dbms_aqadm.start_queue('TEQ2');
end;
/




--- Pruebas de uso !!!

-- BUENO !!!
--- Crear un subscriber !!!!

DECLARE 
   subscriber          sys.aq$_agent; 
BEGIN 
   subscriber := sys.aq$_agent('SDUSUBSCRIBER', null, null); 
   DBMS_AQADM.ADD_SUBSCRIBER(
      queue_name         => 'USUTEQ2.TEQ2', 
      subscriber         =>  subscriber); 
END;
/


--- Dequeue !!!

DBMS_AQ.DEQUEUE_ARRAY(
   queue_name                IN      VARCHAR2,
   dequeue_options           IN      dequeue_options_t,
   array_size                IN      PLS_INTEGER, 
   message_properties_array  OUT     message_properties_array_t,
   payload_array             OUT     VARRAY,
   msgid_array               OUT     msgid_array_t)
RETURN PLS_INTEGER;

FUNCTION DEQUEUE_ARRAY RETURNS BINARY_INTEGER
 Argument Name			Type			In/Out Default?
 ------------------------------ ----------------------- ------ --------
 QUEUE_NAME			VARCHAR2		IN
 DEQUEUE_OPTIONS		DEQUEUE_OPTIONS_T	IN
 ARRAY_SIZE			BINARY_INTEGER		IN
 MESSAGE_PROPERTIES_ARRAY	MESSAGE_PROPERTIES_ARRAY_T OUT
 PAYLOAD_ARRAY			<COLLECTION_1>		OUT
 MSGID_ARRAY			MSGID_ARRAY_T		OUT

FUNCTION DEQUEUE_ARRAY RETURNS BINARY_INTEGER
 Argument Name			Type			In/Out Default?
 ------------------------------ ----------------------- ------ --------
 QUEUE_NAME			VARCHAR2		IN
 DEQUEUE_OPTIONS		DEQUEUE_OPTIONS_T	IN
 ARRAY_SIZE			BINARY_INTEGER		IN
 MESSAGE_PROPERTIES_ARRAY	MESSAGE_PROPERTIES_ARRAY_T OUT
 PAYLOAD_ARRAY			<COLLECTION_1>		OUT
 MSGID_ARRAY			MSGID_ARRAY_T		OUT
 ERROR_ARRAY			ERROR_ARRAY_T		OUT



CREATE OR REPLACE TYPE t_1_v2 AS OBJECT
(
linea VARCHAR2(2000) );
/

CREATE OR REPLACE TYPE T_ARR_PAYLOD IS TABLE OF t_1_v2;
/


SET SERVEROUTPUT ON size 100000
DECLARE
  dequeue_options       DBMS_AQ.dequeue_options_t;
  msg_prop_array        DBMS_AQ.message_properties_array_t := DBMS_AQ.message_properties_array_t();
  payload_array         USUTEQ2.T_ARR_PAYLOD := USUTEQ2.T_ARR_PAYLOD();
  msgid_array           DBMS_AQ.msgid_array_t := DBMS_AQ.msgid_array_t();
  retval                PLS_INTEGER;
  error_array		DBMS_AQ.ERROR_ARRAY_T := DBMS_AQ.ERROR_ARRAY_T();
BEGIN
	dequeue_options.consumer_name := 'SDUSUBSCRIBER';
	dequeue_options.dequeue_mode := DBMS_AQ.BROWSE;
	dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE;
	dequeue_options.wait := DBMS_AQ.NO_WAIT;
	--
	 payload_array.extend(10);
	--
  retval := DBMS_AQ.DEQUEUE_ARRAY( 
              queue_name               => 'USUTEQ2.TEQ2',
              dequeue_options          => dequeue_options,
              array_size               => 10,
              message_properties_array => msg_prop_array,
              payload_array            => payload_array,
              msgid_array              => msgid_array,
	      error_array		=> error_array);
  DBMS_OUTPUT.PUT_LINE('Number of messages dequeued: ' || retval);
END;
/

--- Esto en la 20c echa un CORE DUMP !!!

--- Ahora probamos por DBLINK, desde una 19c a una 20c !!!

sqlplus USUTEQ2/"CcZZ0r_cle#3"@"dbcn19:1521/pdb19.sub05271030030.skynet.oraclevcn.com"

SQL> create database link MYDB20C connect to usuteq2 identified by "CcZZ0r_cle#3" using 'MYDB20C';

Database link created.

SQL> select table_name from user_tables@PDB2.SUB05271030030.SKYNET.ORACLEVCN.COM;

TABLE_NAME
--------------------------------------------------------------------------------
TEQ2
AQ$_TEQ2_L
AQ$_TEQ2_X
AQ$_TEQ2_T

-- Borro la queue local !!!

begin
	sys.dbms_aqadm.stop_queue('TEQ2');
	sys.dbms_aqadm.DROP_SHARDED_QUEUE ('TEQ2',true);
end;
/

begin
	sys.dbms_aqadm.stop_queue('LOCALQUEUE');
	sys.dbms_aqadm.DROP_SHARDED_QUEUE ('LOCALQUEUE',true);
end;
/

begin
sys.dbms_aqadm.create_sharded_queue(queue_name=>'LOCALQUEUE', multiple_consumers => TRUE); 
sys.dbms_aqadm.set_queue_parameter('LOCALQUEUE', 'SHARD_NUM', 1);
sys.dbms_aqadm.set_queue_parameter('LOCALQUEUE', 'STICKY_DEQUEUE', 1);
sys.dbms_aqadm.set_queue_parameter('LOCALQUEUE', 'KEY_BASED_ENQUEUE', 1);
sys.dbms_aqadm.start_queue('LOCALQUEUE');
end;
/

begin
sys.dbms_aqadm.create_queue(queue_name=>'LOCALQUEUE', queue_table => 'TAB_LOCAL_QUEUE'); 
--sys.dbms_aqadm.set_queue_parameter('LOCALQUEUE', 'SHARD_NUM', 1);
--sys.dbms_aqadm.set_queue_parameter('LOCALQUEUE', 'STICKY_DEQUEUE', 1);
--sys.dbms_aqadm.set_queue_parameter('LOCALQUEUE', 'KEY_BASED_ENQUEUE', 1);
sys.dbms_aqadm.start_queue('LOCALQUEUE');
end;
/

DECLARE 
   subscriber          sys.aq$_agent; 
BEGIN 
   subscriber := sys.aq$_agent('LOCALSDU', 'USUTEQ2.TEQ2@PDB2.SUB05271030030.SKYNET.ORACLEVCN.COM', null); 
   DBMS_AQADM.ADD_SUBSCRIBER(
      queue_name         => 'LOCALQUEUE', 
      subscriber         =>  subscriber); 
END;
/


--- Esto NO VA !!!

--- Desde la 20c me creo un dblink hacia la 19c:

SQL> select table_name from user_tables@pdb19.sub05271030030.skynet.oraclevcn.com;

no rows selected

--- En la 20c me creo una queue TEQ !!!

begin
	sys.dbms_aqadm.stop_queue('TEQ2');
	sys.dbms_aqadm.DROP_SHARDED_QUEUE ('TEQ2',true);
end;
/

begin
sys.dbms_aqadm.create_sharded_queue(queue_name=>'TEQ2', multiple_consumers => TRUE); 
sys.dbms_aqadm.set_queue_parameter('TEQ2', 'SHARD_NUM', 1);
sys.dbms_aqadm.set_queue_parameter('TEQ2', 'STICKY_DEQUEUE', 1);
sys.dbms_aqadm.set_queue_parameter('TEQ2', 'KEY_BASED_ENQUEUE', 1);
sys.dbms_aqadm.start_queue('TEQ2');
end;
/

BEGIN
   DBMS_AQADM.UNSCHEDULE_PROPAGATION(
      queue_name    =>   'USUTEQ2.TEQ2', 
      destination   =>   'pdb19.sub05271030030.skynet.oraclevcn.com');
END;
/

BEGIN
   DBMS_AQADM.SCHEDULE_PROPAGATION(
      queue_name         =>    'USUTEQ2.TEQ2', 
      destination        =>    'pdb19.sub05271030030.skynet.oraclevcn.com',
      destination_queue  =>    'target_queue',
      latency            => 0);
END;
/


--- Creo una queue en la 19c !!!

begin
sys.dbms_aqadm.create_sharded_queue(queue_name=>'TARGET_QUEUE', multiple_consumers => TRUE); 
sys.dbms_aqadm.set_queue_parameter('TARGET_QUEUE', 'SHARD_NUM', 1);
sys.dbms_aqadm.set_queue_parameter('TARGET_QUEUE', 'STICKY_DEQUEUE', 1);
sys.dbms_aqadm.set_queue_parameter('TARGET_QUEUE', 'KEY_BASED_ENQUEUE', 1);
sys.dbms_aqadm.start_queue('TARGET_QUEUE');
end;
/

DECLARE 
   subscriber          sys.aq$_agent; 
BEGIN 
   subscriber := sys.aq$_agent('SDU19', null, null); 
   DBMS_AQADM.ADD_SUBSCRIBER(
      queue_name         => 'USUTEQ2.TARGET_QUEUE', 
      subscriber         =>  subscriber); 
END;
/

--- Verify !!!

--- Desde la 20c !!!

SET SERVEROUTPUT ON
DECLARE 
rc      BINARY_INTEGER; 
BEGIN 
   DBMS_AQADM.VERIFY_QUEUE_TYPES(
      src_queue_name  => 'USUTEQ2.TEQ2', 
      dest_queue_name => 'USUTEQ2.TARGET_QUEUE',
      rc              =>  rc); 
   DBMS_OUTPUT.PUT_LINE('Compatible: '||rc);
END;
/

=> No va por dblink !!!!


SQL> select qname, DESTINATION,LATENCY,LAST_ERROR_MSG from USER_QUEUE_SCHEDULES;

QNAME
--------------------------------------------------------------------------------
DESTINATION
--------------------------------------------------------------------------------
   LATENCY
----------
LAST_ERROR_MSG
--------------------------------------------------------------------------------
TEQ2
"USUTEQ2"."TARGET_QUEUE"@PDB19.SUB05271030030.SKYNET.ORACLEVCN.COM
	 0
ORA-04054: database link PDB19.SUB05271030030.SKYNET.ORACLEVCN.COM does not exis
t

QNAME
--------------------------------------------------------------------------------
DESTINATION
--------------------------------------------------------------------------------
   LATENCY
----------
LAST_ERROR_MSG
--------------------------------------------------------------------------------
ORA-06512: at "SYS.DBMS_AQADM_SYS", line 1548
ORA-06512: at "SYS.DBMS_SYS_SQL", line 1457
ORA-06512: at "SYS.DBMS_AQADM_SYS", line 1523
ORA-06512: at "SYS.DBMS_AQADM_SYS", line 14608
ORA-06512: at "SYS.DBMS_AQADM", line 1557

QNAME
--------------------------------------------------------------------------------
DESTINATION
--------------------------------------------------------------------------------
   LATENCY
----------
LAST_ERROR_MSG
--------------------------------------------------------------------------------
ORA-06512: at line 1


SQL> drop database link PDB19.SUB05271030030.SKYNET.ORACLEVCN.COM;

Database link dropped.

SQL> exit
Disconnected from Oracle Database 20c EE Extreme Perf Release 20.0.0.0.0 - Production
Version 20.3.0.0.0
[oracle@dbcn20c admin]$ sqlplus sys/AaZZ0r_cle#1@dbcn20c:1521/pdb2.sub05271030030.skynet.oraclevcn.com as sysdba

SQL*Plus: Release 20.0.0.0.0 - Production on Tue Sep 29 19:05:09 2020
Version 20.3.0.0.0

Copyright (c) 1982, 2020, Oracle.  All rights reserved.


Connected to:
Oracle Database 20c EE Extreme Perf Release 20.0.0.0.0 - Production
Version 20.3.0.0.0

SQL> create public database link PDB19.SUB05271030030.SKYNET.ORACLEVCN.COM connect to usuteq2 identified by "CcZZ0r_cle#3" using 'MYDB19';

Database link created.

SQL> 
SQL> 
SQL> select * from dual@PDB19.SUB05271030030.SKYNET.ORACLEVCN.COM
  2  ;

D
-
X

SQL> 
SQL> 
SQL> exit
Disconnected from Oracle Database 20c EE Extreme Perf Release 20.0.0.0.0 - Production
Version 20.3.0.0.0
[oracle@dbcn20c admin]$ sqlplus usuteq2/"CcZZ0r_cle#3"@dbcn20c:1521/pdb2.sub05271030030.skynet.oraclevcn.com

SQL*Plus: Release 20.0.0.0.0 - Production on Tue Sep 29 19:06:39 2020
Version 20.3.0.0.0

Copyright (c) 1982, 2020, Oracle.  All rights reserved.

Last Successful login time: Tue Sep 29 2020 18:57:50 +02:00

Connected to:
Oracle Database 20c EE Extreme Perf Release 20.0.0.0.0 - Production
Version 20.3.0.0.0

SQL> select * from dual@PDB19.SUB05271030030.SKYNET.ORACLEVCN.COM;

D
-
X

SQL> 
SQL> 

SQL> select qname, DESTINATION,LATENCY,LAST_ERROR_MSG from USER_QUEUE_SCHEDULES;

QNAME
--------------------------------------------------------------------------------
DESTINATION
--------------------------------------------------------------------------------
   LATENCY
----------
LAST_ERROR_MSG
--------------------------------------------------------------------------------
TEQ2
"USUTEQ2"."TARGET_QUEUE"@PDB19.SUB05271030030.SKYNET.ORACLEVCN.COM
	 0
ORA-02019: connection description for remote database not found


SQL> 


--- Esto es porque no pilla el tnsnames !!!
--- Voy a recrear el dblink !!!

create public database link PDB19.SUB05271030030.SKYNET.ORACLEVCN.COM connect to usuteq2 identified by "CcZZ0r_cle#3" 
using '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=130.61.75.76)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=pdb19.sub05271030030.skynet.oraclevcn.com)))';



--- Ahora podemos desencolar de la 19c:

CREATE TYPE message_typ AS object(
   sender_id              NUMBER,
   subject                VARCHAR2(30),
   text                   VARCHAR2(1000));
/

CREATE TYPE msg_table AS TABLE OF message_typ;
/

SET SERVEROUTPUT ON size 100000
DECLARE
  dequeue_options       DBMS_AQ.dequeue_options_t;
  msg_prop_array        DBMS_AQ.message_properties_array_t := DBMS_AQ.message_properties_array_t();
  payload_array         USUTEQ2.msg_table := USUTEQ2.msg_table();
  msgid_array           DBMS_AQ.msgid_array_t := DBMS_AQ.msgid_array_t();
  retval                PLS_INTEGER;
  error_array		DBMS_AQ.ERROR_ARRAY_T := DBMS_AQ.ERROR_ARRAY_T();
BEGIN
	dequeue_options.consumer_name := 'SDU19';
	dequeue_options.dequeue_mode := DBMS_AQ.BROWSE;
	dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE;
	dequeue_options.wait := DBMS_AQ.NO_WAIT;
	--
	 payload_array.extend(10);
	--
  retval := DBMS_AQ.DEQUEUE_ARRAY( 
              queue_name               => 'USUTEQ2.TARGET_QUEUE',
              dequeue_options          => dequeue_options,
              array_size               => 10,
              message_properties_array => msg_prop_array,
              payload_array            => payload_array,
              msgid_array              => msgid_array,
	      error_array		=> error_array);
  DBMS_OUTPUT.PUT_LINE('Number of messages dequeued: ' || retval);
END;
/


CREATE TYPE message_typ AS object(
   sender_id              NUMBER,
   subject                VARCHAR2(30),
   text                   VARCHAR2(1000));
/

CREATE TYPE test.msg_table AS TABLE OF test.message_typ;
/

SET SERVEROUTPUT ON
DECLARE
dequeue_options     DBMS_AQ.dequeue_options_t;
message_properties  DBMS_AQ.message_properties_t;
message_handle      RAW(16);
message             message_typ;
BEGIN

   dequeue_options.consumer_name := 'SDU19';
	dequeue_options.dequeue_mode := DBMS_AQ.BROWSE;
	dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE;
	dequeue_options.wait := DBMS_AQ.NO_WAIT;

   DBMS_AQ.DEQUEUE(
      queue_name          =>     'USUTEQ2.TARGET_QUEUE',
      dequeue_options     =>     dequeue_options,
      message_properties  =>     message_properties,
      payload             =>     message,
      msgid               =>     message_handle);
   DBMS_OUTPUT.PUT_LINE('From Sender No.'|| message.sender_id);
   DBMS_OUTPUT.PUT_LINE('Subject: '||message.subject);
   DBMS_OUTPUT.PUT_LINE('Text: '||message.text);
   COMMIT;
END;
/


--- Puedo ecolar un mensaje en la TEQ2 (20c), y ver que se propaga a la queue TARGET_QUEUE de 19c !!!

CREATE TYPE message_typ AS object(
   sender_id              NUMBER,
   subject                VARCHAR2(30),
   text                   VARCHAR2(1000));
/

DECLARE
 po_t dbms_aqadm.aq$_purge_options_t;
BEGIN
  dbms_aqadm.purge_queue_table('TEQ2', NULL, po_t);
END;
/

DECLARE
   enqueue_options     DBMS_AQ.enqueue_options_t;
   message_properties  DBMS_AQ.message_properties_t;
   message_handle      RAW(16);
   message             message_typ;
BEGIN
   message := message_typ('DML done against table TT: A new row with key xxxx has been created.' );
   DBMS_AQ.ENQUEUE(
      queue_name              => 'USUTEQ2.TEQ2', 
      enqueue_options         => enqueue_options,
      message_properties      => message_properties,
      payload                 => message,
      msgid                   => message_handle);
   COMMIT;
END;
/



--- En la 19c:

DECLARE
 po_t dbms_aqadm.aq$_purge_options_t;
BEGIN
  dbms_aqadm.purge_queue_table('TARGET_QUEUE', NULL, po_t);
END;
/

select QUEUE_SCHEMA, QUEUE_NAME, ENQUEUED_MSGS,DEQUEUED_MSGS from GV$PERSISTENT_QUEUES;

*************************************************
---- Caso de transaccionalidad con TEQ3:
*************************************************
--- Todo esto lo hago en el esquema USUTEQ2, tanto en la 20c como en la 19c

--- En la 20c creo una TEQ3, con payload de tipo JMS_TYPE

sqlplus usuteq2/"CcZZ0r_cle#3"@dbcn20c:1521/pdb2.sub05271030030.skynet.oraclevcn.com

begin
	sys.dbms_aqadm.stop_queue('TEQ3');
	sys.dbms_aqadm.DROP_SHARDED_QUEUE ('TEQ3',true);
end;
/

begin
sys.dbms_aqadm.create_sharded_queue(queue_name=>'TEQ3', multiple_consumers => TRUE); 
sys.dbms_aqadm.set_queue_parameter('TEQ3', 'SHARD_NUM', 1);
sys.dbms_aqadm.set_queue_parameter('TEQ3', 'STICKY_DEQUEUE', 1);
sys.dbms_aqadm.set_queue_parameter('TEQ3', 'KEY_BASED_ENQUEUE', 1);
sys.dbms_aqadm.start_queue('TEQ3');
end;
/


--- En la 19c creo una DESTTEQ3, con payload de tipo message_typ (object):

sqlplus USUTEQ2/"CcZZ0r_cle#3"@"dbcn19:1521/pdb19.sub05271030030.skynet.oraclevcn.com"

begin
	sys.dbms_aqadm.stop_queue('DESTTEQ3');
	sys.dbms_aqadm.DROP_SHARDED_QUEUE ('DESTTEQ3',true);
end;
/

begin
sys.dbms_aqadm.create_sharded_queue(queue_name=>'DESTTEQ3', multiple_consumers => TRUE); 
sys.dbms_aqadm.set_queue_parameter('DESTTEQ3', 'SHARD_NUM', 1);
sys.dbms_aqadm.set_queue_parameter('DESTTEQ3', 'STICKY_DEQUEUE', 1);
sys.dbms_aqadm.set_queue_parameter('DESTTEQ3', 'KEY_BASED_ENQUEUE', 1);
sys.dbms_aqadm.start_queue('DESTTEQ3');
end;
/

--- Y un subscriber de la queue !!!

DECLARE 
   subscriber          sys.aq$_agent; 
BEGIN 
   subscriber := sys.aq$_agent('MYSUBSCR19', null, null); 
   DBMS_AQADM.ADD_SUBSCRIBER(
      queue_name         => 'USUTEQ2.DESTTEQ3', 
      subscriber         =>  subscriber); 
END;
/


--- en la 20c defino una propagación de TEQ3 a DESTEQ3

BEGIN
   DBMS_AQADM.SCHEDULE_PROPAGATION(
      queue_name         =>    'USUTEQ2.TEQ3', 
      destination        =>    'pdb19.sub05271030030.skynet.oraclevcn.com',
      destination_queue  =>    'DESTTEQ3',
      latency            => 0);
END;
/

--- Ahora encolo un mensaje en la 20c, queue TEQ3, y verifico que se propaga a la 19c:

drop table t purge;
create table t (c1 number, c2 varchar2(100));
alter table t add constraint PK_T primary key (c1);

DECLARE
 po_t dbms_aqadm.aq$_purge_options_t;
BEGIN
  dbms_aqadm.purge_queue_table('TEQ3', NULL, po_t);
END;
/

col queue_schema format a20
col QUEUE_NAME format a10
select QUEUE_SCHEMA, QUEUE_NAME, ENQUEUED_MSGS,DEQUEUED_MSGS from GV$PERSISTENT_QUEUES where QUEUE_NAME = 'TEQ3';


DECLARE

    id                 pls_integer;
    agent              sys.aq$_agent := sys.aq$_agent(' ', null, 0);
    message            sys.aq$_jms_bytes_message;
    enqueue_options    dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    msgid raw(16);

    java_exp           exception;
    pragma EXCEPTION_INIT(java_exp, -24197);
BEGIN

    -- Consturct a empty BytesMessage object
    message := sys.aq$_jms_bytes_message.construct;

    -- Shows how to set the JMS header 
    message.set_replyto(agent);
    message.set_type('tkaqpet1');
    message.set_userid('jmsuser');
    message.set_appid('plsql_enq');
    message.set_groupid('st');
    message.set_groupseq(1);

  -- Shows how to populate the message payload of aq$_jms_bytes_message 

    -- Passing -1 reserve a new slot within the message store of sys.aq$_jms_bytes_message.
    -- The maximum number of sys.aq$_jms_bytes_message type of messges to be operated at
    -- the same time within a session is 20. Calling clean_body function with parameter -1 
    -- might result a ORA-24199 error if the messages currently operated is already 20. 
    -- The user is responsible to call clean or clean_all function to clean up message store.
    id := message.clear_body(-1);

    -- Write a String to the BytesMessage payload, 
    -- the String is encoded in UTF8 in the message payload
    message.write_utf(id, 'Hello World!');

    -- Flush the data from JAVA stored procedure (JServ) to PL/SQL side 
    -- Without doing this, the PL/SQL message is still empty. 
    message.flush(id);

    -- Use either clean_all or clean to clean up the message store when the user 
    -- do not plan to do paylaod population on this message anymore
    sys.aq$_jms_bytes_message.clean_all();
    --message.clean(id);

    -- Enqueue this message into AQ queue using DBMS_AQ package
    dbms_aq.enqueue(queue_name => 'USUTEQ2.TEQ3',
                    enqueue_options => enqueue_options,
                    message_properties => message_properties,
                    payload => message,
                    msgid => msgid);
    --- Hago un DML en la misma transacción !!!
    insert into t values (1,'CCCP');
    COMMIT;
    EXCEPTION 
    WHEN java_exp THEN
      dbms_output.put_line('exception information:');
      RAISE;
    WHEN OTHERS THEN
	rollback;
	raise;

END;
/



SQL> select QUEUE_SCHEMA, QUEUE_NAME, ENQUEUED_MSGS,DEQUEUED_MSGS from GV$PERSISTENT_QUEUES where QUEUE_NAME = 'TEQ3';

QUEUE_SCHEMA	     QUEUE_NAME ENQUEUED_MSGS DEQUEUED_MSGS
-------------------- ---------- ------------- -------------
USUTEQ2 	     TEQ3		    1		  0


--- En la 19c, verifico que se ha propagado !!!

col queue_schema format a20
col QUEUE_NAME format a10
select QUEUE_SCHEMA, QUEUE_NAME, ENQUEUED_MSGS,DEQUEUED_MSGS from GV$PERSISTENT_QUEUES where QUEUE_NAME = 'DESTTEQ3';





 
