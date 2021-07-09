*************************************************
---- Caso de transaccionalidad con TEQ3:
*************************************************

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

DECLARE 
   subscriber          sys.aq$_agent; 
BEGIN 
   subscriber := sys.aq$_agent('MYSUBSCR20', null, null); 
   DBMS_AQADM.ADD_SUBSCRIBER(
      queue_name         => 'USUTEQ2.TEQ3', 
      subscriber         =>  subscriber); 
END;
/


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

col queue_schema format a20
col QUEUE_NAME format a10
select QUEUE_SCHEMA, QUEUE_NAME, ENQUEUED_MSGS,DEQUEUED_MSGS from GV$PERSISTENT_QUEUES where QUEUE_NAME = 'TEQ3';





