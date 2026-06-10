-- Run as the queue owner while the Java consumer is listening.

declare
  enqueue_options    dbms_aq.enqueue_options_t;
  message_properties dbms_aq.message_properties_t;
  message_id         raw(16);
  payload            raw(32767);
begin
  payload := utl_raw.cast_to_raw(
    '{"eventType":"ORDER_CREATED","orderId":1001,"customer":"stef","amount":42.50}');

  dbms_aq.enqueue(
    queue_name         => 'ORDER_EVENTS_Q',
    enqueue_options    => enqueue_options,
    message_properties => message_properties,
    payload            => payload,
    msgid              => message_id);

  commit;
  dbms_output.put_line('Enqueued message id ' || rawtohex(message_id));
end;
/
