-- Run as the schema that owns the queue, for example AQDEMO.
-- This creates a single-consumer RAW payload queue for JSON messages.

begin
  dbms_aqadm.stop_queue(queue_name => 'ORDER_EVENTS_Q');
exception
  when others then
    if sqlcode not in (-24010, -24033) then
      raise;
    end if;
end;
/

begin
  dbms_aqadm.drop_queue(queue_name => 'ORDER_EVENTS_Q');
exception
  when others then
    if sqlcode != -24010 then
      raise;
    end if;
end;
/

begin
  dbms_aqadm.drop_queue_table(queue_table => 'ORDER_EVENTS_QTAB', force => true);
exception
  when others then
    if sqlcode != -24002 then
      raise;
    end if;
end;
/

begin
  dbms_aqadm.create_queue_table(
    queue_table        => 'ORDER_EVENTS_QTAB',
    queue_payload_type => 'RAW',
    multiple_consumers => false);

  dbms_aqadm.create_queue(
    queue_name  => 'ORDER_EVENTS_Q',
    queue_table => 'ORDER_EVENTS_QTAB');

  dbms_aqadm.start_queue(queue_name => 'ORDER_EVENTS_Q');
end;
/

select queue_table, name as queue_name, enqueue_enabled, dequeue_enabled
from user_queues
where name = 'ORDER_EVENTS_Q';
