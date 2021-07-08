BEGIN
    ords_admin.enable_schema (
        p_enabled               => TRUE,
        p_schema                => 'USER1',
        p_url_mapping_type      => 'BASE_PATH',
        p_url_mapping_pattern   => 'user1', -- this flag says, use 'myownsh' in the URIs for MYOWNSH
        p_auto_rest_auth        => TRUE   -- this flag says, don't expose my REST APIs
    );
    COMMIT;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'USER1',
                       p_object => 'CUSTOMERS',
                       p_object_type => 'TABLE',
                       p_object_alias => 'cust',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/


BEGIN
  ORDS.define_service(
    p_module_name    => 'callcenter',
    p_base_path      => 'callcenter/',
    p_pattern        => 'customer/',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'select /*+ SOY_ORDS */ cust_id, CUST_FIRST_NAME, CUST_LAST_NAME, CUST_GENDER,CUST_MAIN_PHONE_NUMBER from user1.customers where cust_id=49671',
    p_items_per_page => 0);
    
  COMMIT;
END;
/

https://bwkiqdkv65bzrwd-sduadwdb.adb.eu-frankfurt-1.oraclecloudapps.com/ords/user1/callcenter/customer

SQL_TEXT
--------------------------------------------------------------------------------
PARSING_SCHEMA_NAME
--------------------------------------------------------------------------------
ADMIN

select /*+ SOY_ORDS */ cust_id, CUST_FIRST_NAME, CUST_LAST_NAME, CUST_GENDER,CUS
T_MAIN_PHONE_NUMBER from user1.customers where cust_id=49671
USER1


BEGIN
    ords_admin.enable_schema (
        p_enabled               => TRUE,
        p_schema                => 'USER2',
        p_url_mapping_type      => 'BASE_PATH',
        p_url_mapping_pattern   => 'user2', -- this flag says, use 'myownsh' in the URIs for MYOWNSH
        p_auto_rest_auth        => TRUE   -- this flag says, don't expose my REST APIs
    );
    COMMIT;
END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'USER2',
                       p_object => 'V_CUSTOMER',
                       p_object_type => 'VIEW',
                       p_object_alias => 'vcust',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

BEGIN
  ORDS.define_service(
    p_module_name    => 'callcenter2',
    p_base_path      => 'callcenter2/',
    p_pattern        => 'customer2/',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'select /*+ SOY_ORDS */ cust_id, CUST_FIRST_NAME, CUST_LAST_NAME, CUST_GENDER,CUST_MAIN_PHONE_NUMBER from user2.v_customer where cust_id=49671',
    p_items_per_page => 0);
    
  COMMIT;
END;
/

https://bwkiqdkv65bzrwd-sduadwdb.adb.eu-frankfurt-1.oraclecloudapps.com/ords/user2/callcenter2/customer2



-- Con sinonimo:
****************

--- Como user2:

create synonym syn_customer for user1.customers;

SQL> select cust_id, CUST_FIRST_NAME, CUST_LAST_NAME, CUST_GENDER,CUST_MAIN_PHONE_NUMBER from syn_customer where cust_id=49671;

   CUST_ID CUST_FIRST_NAME	CUST_LAST_NAME				 C
---------- -------------------- ---------------------------------------- -
CUST_MAIN_PHONE_NUMBER
-------------------------
     49671 Abigail		Ruddy					 M
****-****-**

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'USER2',
                       p_object => 'SYN_CUSTOMER',
                       p_object_type => 'SYNONYM',
                       p_object_alias => 'scust',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

ERROR at line 1:
ORA-20001: UNSUPPORTED_OBJECT_TYPE_ERROR
ORA-06512: at "ORDS_METADATA.ORDS", line 285
ORA-06512: at "ORDS_METADATA.ORDS_INTERNAL", line 1539
ORA-06512: at "ORDS_METADATA.ORDS_INTERNAL", line 1567
ORA-06512: at "ORDS_METADATA.ORDS_INTERNAL", line 619
ORA-06512: at "ORDS_METADATA.ORDS", line 270
ORA-06512: at line 5

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'USER2',
                       p_object => 'SYN_CUSTOMER',
                       p_object_type => 'TABLE',
                       p_object_alias => 'scust',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

DECLARE
*
ERROR at line 1:
ORA-01403: no data found
ORA-06512: at "ORDS_METADATA.ORDS", line 285
ORA-06512: at "ORDS_METADATA.ORDS_INTERNAL", line 1560
ORA-06512: at "ORDS_METADATA.ORDS_INTERNAL", line 619
ORA-06512: at "ORDS_METADATA.ORDS", line 270
ORA-06512: at line 5









