-- Run as the queue owner when you are finished with the demo.

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

prompt Removed ORDER_EVENTS_Q and ORDER_EVENTS_QTAB.
