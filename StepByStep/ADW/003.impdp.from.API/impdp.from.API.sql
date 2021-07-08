set define off
BEGIN
DBMS_CLOUD.CREATE_CREDENTIAL(
credential_name => 'ADMIN_DEF_CRED',
username => 'api.user', 
password => 'jP<0ceXe<)nJSeqM1t7A'
);
END;
/


ALTER DATABASE PROPERTY SET default_credential = 'ADMIN.ADMIN_DEF_CRED';

declare
  h1 number;
  j_status varchar2(200);
begin

  h1 := dbms_datapump.open('IMPORT','FULL',NULL,'ADWC_IMPDP_RUN2','LATEST');

  dbms_datapump.add_file(
    handle => h1,
    filename => 'https://swiftobjectstorage.eu-frankfurt-1.oraclecloud.com/v1/telefonicacloud2/DATAPUMP/expdp.usrbi.dmp',
    directory => 'DATA_PUMP_DIR',
    filetype => dbms_datapump.KU$_FILE_TYPE_URIDUMP_FILE);

  dbms_datapump.add_file(
    handle => h1,
    filename => 'impdp.usrbi.log',
    directory => 'DATA_PUMP_DIR',
    filetype => dbms_datapump.KU$_FILE_TYPE_LOG_FILE);

--  dbms_datapump.metadata_remap( h1, 'REMAP_SCHEMA', 'UT_TD_D_1', 'STAR');
--  dbms_datapump.metadata_remap( h1, 'REMAP_TABLE', 'PERSON_SRC', 'C$_0PER');
  dbms_datapump.set_parameter(h1,'TABLE_EXISTS_ACTION','SKIP');
--  dbms_datapump.set_parameter(h1,'PARTITION_OPTIONS','MERGE');
  dbms_datapump.metadata_transform( h1, 'SEGMENT_ATTRIBUTES', 0);  

  dbms_datapump.start_job(h1);
  -- dbms_datapump.wait_for_job(h1, j_status);

  dbms_cloud.put_object(
    credential_name => 'ADMIN_DEF_CRED',
    object_uri => 'https://swiftobjectstorage.eu-frankfurt-1.oraclecloud.com/v1/telefonicacloud2/DATAPUMP/impdp.usrbi.log',
    directory_name  => 'DATA_PUMP_DIR',
    file_name => 'odi_de73e691-2ef5-4fff-8d98-697cf8e123cf_PER_AP_imp.log');
end;
/
