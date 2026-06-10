-- Adds a few messages so the consumer can show continuous dequeue behavior.

declare
  enqueue_options    dbms_aq.enqueue_options_t;
  message_properties dbms_aq.message_properties_t;
  message_id         raw(16);
begin
  for i in 1..5 loop
    dbms_aq.enqueue(
      queue_name         => 'ORDER_EVENTS_Q',
      enqueue_options    => enqueue_options,
      message_properties => message_properties,
      payload            => utl_raw.cast_to_raw(
        '{"eventType":"ORDER_UPDATED","orderId":' || to_char(2000 + i) ||
        ',"status":"READY_TO_SHIP"}'),
      msgid              => message_id);

    dbms_output.put_line('Enqueued message id ' || rawtohex(message_id));
  end loop;

  commit;
end;
/
