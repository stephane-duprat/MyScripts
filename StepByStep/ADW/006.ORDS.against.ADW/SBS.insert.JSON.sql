-- User USUAHM !!!

CREATE USER USUAHM IDENTIFIED BY "AaZZ0r_cle#1";

GRANT CONNECT, resource TO USUAHM;
 
ALTER USER USUAHM QUOTA UNLIMITED ON DATA;

BEGIN
    ords_admin.enable_schema (
        p_enabled               => TRUE,
        p_schema                => 'USUAHM',
        p_url_mapping_type      => 'BASE_PATH',
        p_url_mapping_pattern   => 'usuahm', -- this flag says, use 'tjs' in the URIs for JEFF
        p_auto_rest_auth        => TRUE   -- this flag says, don't expose my REST APIs
    );
    COMMIT;
END;
/




-- As user USUAHM !!!

create table ticket_ahm
(
file_name varchar2(200) not null,
load_timestamp timestamp,
po_document CLOB check (po_document IS JSON)
)
partition by hash (file_name) partitions 50;

create unique index idx1 on ticket_ahm (file_name) local;

alter table ticket_ahm add constraint PK_ticket_ahm primary key (file_name) using index idx1;



DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'USUAHM',
                       p_object => 'TICKET_AHM',
                       p_object_type => 'TABLE',
                       p_object_alias => 'tickets',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/


create or replace PROCEDURE upload (p_file_name IN ticket_ahm.file_name%TYPE, p_po_document IN  ticket_ahm.po_document%TYPE)
IS
BEGIN
INSERT INTO ticket_ahm
  VALUES (
    sys_guid() || '_' || p_file_name,
    systimestamp,
    p_po_document);
end;
/

 

 

BEGIN
  ORDS.delete_module(p_module_name => 'media_module');

  ORDS.define_module(
    p_module_name    => 'media_module',
    p_base_path      => 'media_module/',
    p_items_per_page => 0);

  COMMIT;
END;
/

 

BEGIN
  ORDS.define_template(
   p_module_name     => 'media_module',
   p_pattern         => 'media/');

  ORDS.define_handler(
    p_module_name    => 'media_module',
    p_pattern        => 'media/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => q'[BEGIN
                             upload(
			       p_file_name => :filename,
                               p_po_document => :body_text
                             );
                             :status := 201;
                             :message := 'Created ' || :filename;
			     commit;
                           EXCEPTION
                             WHEN OTHERS THEN
                               :status := 400;
                               :message := SQLERRM;
			       rollback;                       
                           END;]',
    p_items_per_page => 0);

 

  ORDS.define_parameter(
    p_module_name        => 'media_module',
    p_pattern            => 'media/',
    p_method             => 'POST',
    p_name               => 'filename',
    p_bind_variable_name => 'filename',
    p_source_type        => 'HEADER',
    p_param_type         => 'STRING',
    p_access_method      => 'IN'
  );

  ORDS.define_parameter(
    p_module_name        => 'media_module',
    p_pattern            => 'media/',
    p_method             => 'POST',
    p_name               => 'X-ORDS-STATUS-CODE',   -- Available in 18.3
   --p_name               => 'X-APEX-STATUS-CODE', -- Deprecated in 18.3
    p_bind_variable_name => 'status',
    p_source_type        => 'HEADER',
    p_access_method      => 'OUT'
  );

 

  ORDS.define_parameter(
    p_module_name        => 'media_module',
    p_pattern            => 'media/',
    p_method             => 'POST',
    p_name               => 'message',
    p_bind_variable_name => 'message',
    p_source_type        => 'RESPONSE',
    p_access_method      => 'OUT'
  );

  COMMIT;
END;
/

 

BEGIN
  ORDS.delete_module(p_module_name => 'consultaticket');

  ORDS.define_module(
    p_module_name    => 'consultaticket',
    p_base_path      => 'consultaticket/',
    p_items_per_page => 0);

  COMMIT;
END;
/

BEGIN
  ORDS.define_template(
   p_module_name     => 'consultaticket',
   p_pattern         => 'ticket/');

  ORDS.define_handler(
    p_module_name    => 'consultaticket',
    p_pattern        => 'ticket/',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'SELECT file_name, load_timestamp, po_document FROM usuahm.ticket_ahm where file_name = :filename',
    p_items_per_page => 0);

 

  ORDS.define_parameter(
    p_module_name        => 'consultaticket',
    p_pattern            => 'ticket/',
    p_method             => 'GET',
    p_name               => 'filename',
    p_bind_variable_name => 'filename',
    p_source_type        => 'HEADER',
    p_param_type         => 'STRING',
    p_access_method      => 'IN'
  );


  COMMIT;
END;
/
 
REST endpoint: https://ixcsyvrmtjm8ebr-benchatpdb.adb.eu-frankfurt-1.oraclecloudapps.com/ords/

https://ixcsyvrmtjm8ebr-benchatpdb.adb.eu-frankfurt-1.oraclecloudapps.com/ords/usuahm/tickets  => OK

curl -i -k -H "Content-Type: application/json" -H "filename: myfile" https://ixcsyvrmtjm8ebr-benchatpdb.adb.eu-frankfurt-1.oraclecloudapps.com/ords/usuahm/consultaticket/ticket/  => OK

curl -X POST --data-binary "@./ticket.line1.json" -H "Content-Type: application/json" -H "filename: ticket.line1.json" https://ixcsyvrmtjm8ebr-benchatpdb.adb.eu-frankfurt-1.oraclecloudapps.com/ords/usuahm/media_module/media/

 

