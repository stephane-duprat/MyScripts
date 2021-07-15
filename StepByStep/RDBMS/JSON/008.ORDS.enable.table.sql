sqlplus sh/sh@jsonpdb

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_SCHEMA(p_enabled => TRUE,
                       p_schema => 'SH',
                       p_url_mapping_type => 'BASE_PATH',
                       p_url_mapping_pattern => 'sh',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'SH',
                       p_object => 'SALES',
                       p_object_type => 'TABLE',
                       p_object_alias => 'sales',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'SH',
                       p_object => 'CHANNELS',
                       p_object_type => 'TABLE',
                       p_object_alias => 'channels',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'SH',
                       p_object => 'SALES_JSON_CHECK',
                       p_object_type => 'TABLE',
                       p_object_alias => 'sales_json_check',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'SH',
                       p_object => 'SALES_JSON_INDEX',
                       p_object_type => 'TABLE',
                       p_object_alias => 'sales_json_index',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'SH',
                       p_object => 'SALES_JSON_INDEX2',
                       p_object_type => 'TABLE',
                       p_object_alias => 'sales_json_index2',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/


--- Desde el nodo jsondbcn01:

java -jar ords.war map-url --type base-url http://130.61.52.57:8080/ords/jsonpdb jsonpdb

java -jar ords.war map-url --type base-url http://172.16.1.4:8080/ords/jsonpdb jsonpdb


INFO: Creating new mapping from: [base-url,http://130.61.52.57:8080/ords/jsonpdb] to map to: [jsonpdb, null, null]

-- Añadir regla de acceso al 8080 en el iptables del nodo jsondbcn01

[root@clu1cn1 tmp]# iptables -I INPUT 10 -p tcp -m tcp --dport 8080 -j ACCEPT
iptables-save > /etc/sysconfig/iptables


--- Crear una conexión:

java -jar ords.war setup --database jsonpdb

[oracle@clu1cn1 ~]$ java -jar ords.war setup --database jsonpdb
Enter the name of the database server [clu1cn-scan.dnslabel1.skynet.oraclevcn.com]:
Enter the database listen port [1521]:
Enter 1 to specify the database service name, or 2 to specify the database SID [1]:1
Enter the database service name [jsondb_fra19r.dnslabel1.skynet.oraclevcn.com]:jsonpdb.dnslabel1.skynet.oraclevcn.com
Enter 1 if you want to verify/install Oracle REST Data Services schema or 2 to skip this step [1]:1
Enter the database password for ORDS_PUBLIC_USER:
Confirm password:

Retrieving information.
Enter 1 if you want to use PL/SQL Gateway or 2 to skip this step.
If using Oracle Application Express or migrating from mod_plsql then you must enter 1 [1]:2
Oct 10, 2018 10:58:52 AM  
INFO: Creating Pool:|apex|pu|
Oct 10, 2018 10:58:52 AM  
INFO: Configuration properties for: |apex|pu|
cache.caching=false
cache.directory=/tmp/apex/cache
cache.duration=days
cache.expiration=7
cache.maxEntries=500
cache.monitorInterval=60
cache.procedureNameList=
cache.type=lru
db.hostname=clu1cn-scan.dnslabel1.skynet.oraclevcn.com
db.password=******
db.port=1521
db.servicename=jsondb_fra19r.dnslabel1.skynet.oraclevcn.com
db.username=ORDS_PUBLIC_USER
debug.debugger=false
debug.printDebugToScreen=false
error.keepErrorMessages=true
error.maxEntries=50
jdbc.DriverType=thin
jdbc.InactivityTimeout=1800
jdbc.InitialLimit=3
jdbc.MaxConnectionReuseCount=1000
jdbc.MaxLimit=10
jdbc.MaxStatementsLimit=10
jdbc.MinLimit=1
jdbc.statementTimeout=900
log.logging=false
log.maxEntries=50
misc.compress=
misc.defaultPage=apex
security.disableDefaultExclusionList=false
security.maxEntries=2000

Oct 10, 2018 10:58:52 AM  
WARNING: *** jdbc.MaxLimit in configuration |apex|pu| is using a value of 10, this setting may not be sized adequately for a production environment ***
Oct 10, 2018 10:58:52 AM  
WARNING: *** jdbc.InitialLimit in configuration |apex|pu| is using a value of 3, this setting may not be sized adequately for a production environment ***
Oct 10, 2018 10:58:52 AM  
INFO: Creating Pool:|jsonpdb|pu|
Oct 10, 2018 10:58:52 AM  
INFO: Configuration properties for: |jsonpdb|pu|
cache.caching=false
cache.directory=/tmp/apex/cache
cache.duration=days
cache.expiration=7
cache.maxEntries=500
cache.monitorInterval=60
cache.procedureNameList=
cache.type=lru
db.hostname=clu1cn-scan.dnslabel1.skynet.oraclevcn.com
db.password=******
db.port=1521
db.servicename=jsonpdb.dnslabel1.skynet.oraclevcn.com
db.username=ORDS_PUBLIC_USER
debug.debugger=false
debug.printDebugToScreen=false
error.keepErrorMessages=true
error.maxEntries=50
jdbc.DriverType=thin
jdbc.InactivityTimeout=1800
jdbc.InitialLimit=3
jdbc.MaxConnectionReuseCount=1000
jdbc.MaxLimit=10
jdbc.MaxStatementsLimit=10
jdbc.MinLimit=1
jdbc.statementTimeout=900
log.logging=false
log.maxEntries=50
misc.compress=
misc.defaultPage=apex
security.disableDefaultExclusionList=false
security.maxEntries=2000

Oct 10, 2018 10:58:52 AM  
WARNING: *** jdbc.MaxLimit in configuration |jsonpdb|pu| is using a value of 10, this setting may not be sized adequately for a production environment ***
Oct 10, 2018 10:58:52 AM  
WARNING: *** jdbc.InitialLimit in configuration |jsonpdb|pu| is using a value of 3, this setting may not be sized adequately for a production environment ***
Oct 10, 2018 10:58:52 AM  
INFO: reloaded pools: [|apex|pu|, |jsonpdb|pu|]
Oct 10, 2018 10:58:52 AM oracle.dbtools.rt.config.setup.SchemaSetup install
INFO: Oracle REST Data Services schema version 18.3.0.r2701456 is installed.
[oracle@clu1cn1 ~]$ 


http://130.61.52.57:8080/ords/jsonpdb/sh/channels/ => OK
http://130.61.52.57:8080/ords/jsonpdb/sh/sales_json_check/ => OK

stef@stef-TECRA-Z40t-C:/media/Data/oracle/Distribs/ORDS$ curl -i -k http://130.61.52.57:8080/ords/jsonpdb/sh/channels/9
HTTP/1.1 200 OK
Date: Wed, 10 Oct 2018 11:23:25 GMT
Content-Type: application/json
ETag: "9PVQ0iUSOpaSOwJ44FgWY3pphaZW0wIz+bWHDvFZhgV1515F3l4TkRoePtqeEhAQDvI2ZxacENxUDSXfg062tA=="
Transfer-Encoding: chunked

{"channel_id":9,"channel_desc":"Tele Sales","channel_class":"Direct","channel_class_id":12,"channel_total":"Channel total","channel_total_id":1,"links":[{"rel":"self","href":"http://130.61.52.57:8080/ords/jsonpdb/sh/channels/9"},{"rel":"edit","href":"http://130.61.52.57:8080/ords/jsonpdb/sh/channels/9"},{"rel":"describedby","href":"http://130.61.52.57:8080/ords/jsonpdb/sh/metadata-catalog/channels/item"},{"rel":"collection","href":"http://130.61.52.57:8080/ords/jsonpdb/sh/channels/"}]}





[opc@clicn01 ~]$ curl -i -k http://172.16.1.4:8080/ords/jsonpdb/sh/channels/9
HTTP/1.1 200 OK
Date: Wed, 10 Oct 2018 11:22:07 GMT
Content-Type: application/json
ETag: "ZDW9YwdEA7yoqHaA1wyq80jKpINVhJirPSyKpqM0vUzP1XPC5t0XQ/B7sh+bG8X4DyfEXHp9mh1gHi/n0o297A=="
Transfer-Encoding: chunked

{"channel_id":9,"channel_desc":"Tele Sales","channel_class":"Direct","channel_class_id":12,"channel_total":"Channel total","channel_total_id":1,"links":[{"rel":"self","href":"http://172.16.1.4:8080/ords/jsonpdb/sh/channels/9"},{"rel":"edit","href":"http://172.16.1.4:8080/ords/jsonpdb/sh/channels/9"},{"rel":"describedby","href":"http://172.16.1.4:8080/ords/jsonpdb/sh/metadata-catalog/channels/item"},{"rel":"collection","href":"http://172.16.1.4:8080/ords/jsonpdb/sh/channels/"}]}[opc@clicn01 ~]$ 


--- Una query mas complicada:

sqlplus sh/sh@JSONPDB


BEGIN
  ORDS.define_service(
    p_module_name    => 'module1',
    p_base_path      => 'mod1/',
    p_pattern        => 'channels/',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'SELECT count(*) FROM sh.channels',
    p_items_per_page => 0);
    
  COMMIT;
END;
/

curl -i -k http://172.16.1.4:8080/ords/jsonpdb/sh/mod1/channels/
curl -i -k http://130.61.52.57:8080/ords/jsonpdb/sh/mod1/channels/


BEGIN
  ORDS.define_service(
    p_module_name    => 'aggjson',
    p_base_path      => 'aggjson/',
    p_pattern        => 'salesjson/',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'select ch.channel_desc, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
group by ch.channel_desc',
    p_items_per_page => 0);

  COMMIT;
END;
/

curl -i -k http://172.16.1.4:8080/ords/jsonpdb/sh/aggjson/salesjson
curl -i -k http://130.61.52.57:8080/ords/jsonpdb/sh/aggjson/salesjson


BEGIN
  ORDS.define_service(
    p_module_name    => 'aggjson2',
    p_base_path      => 'aggjsoncomplex/',
    p_pattern        => 'crucejson/',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'select ch.channel_desc, c.sales_json.TOTAL_SOLD+c1.sales_json.TOTAL_SOLD
from SALES_JSON_INDEX c,
     SALES_JSON_INDEX2 c1,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
and   c1.sales_json.CHANNELID = ch.channel_id
and   c.sales_json.CUSTID = c1.sales_json.CUSTID
and   c.sales_json.CUSTID = 397071',
    p_items_per_page => 0);

  COMMIT;
END;
/

curl -i -k http://172.16.1.4:8080/ords/jsonpdb/sh/aggjsoncomplex/crucejson
curl -i -k http://130.61.52.57:8080/ords/jsonpdb/sh/aggjsoncomplex/crucejson


-- Ejemplo con PL/SQL: insert en la tabla sales !!!
SQL> desc sales
 Name					   Null?    Type
 ----------------------------------------- -------- ----------------------------
 PROD_ID				   NOT NULL NUMBER
 CUST_ID				   NOT NULL NUMBER
 TIME_ID				   NOT NULL DATE
 CHANNEL_ID				   NOT NULL NUMBER
 PROMO_ID				   NOT NULL NUMBER
 QUANTITY_SOLD				   NOT NULL NUMBER(10,2)
 SELLER 				   NOT NULL NUMBER(6)
 FULFILLMENT_CENTER			   NOT NULL NUMBER(6)
 COURIER_ORG				   NOT NULL NUMBER(6)
 TAX_COUNTRY				   NOT NULL VARCHAR2(3)
 TAX_REGION					    VARCHAR2(3)
 AMOUNT_SOLD				   NOT NULL NUMBER(10,2)


CREATE OR REPLACE PROCEDURE create_sales (
 P_PROD_ID	sales.prod_id%TYPE,
 P_CUST_ID	sales.cust_id%TYPE,
 P_TIME_ID	VARCHAR2,
 P_CHANNEL_ID	sales.CHANNEL_ID%TYPE,
 P_PROMO_ID	sales.PROMO_ID%TYPE,
 P_QUANTITY_SOLD	sales.QUANTITY_SOLD%TYPE,
 P_SELLER 	sales.SELLER%TYPE,
 P_FULFILLMENT_CENTER 	sales.FULFILLMENT_CENTER%TYPE,
 P_COURIER_ORG sales.COURIER_ORG%TYPE,
 P_TAX_COUNTRY	sales.TAX_COUNTRY%TYPE,
 P_TAX_REGION	sales.TAX_REGION%TYPE,
 P_AMOUNT_SOLD  sales.AMOUNT_SOLD%TYPE
)
AS
BEGIN
  INSERT INTO sales (PROD_ID, CUST_ID, TIME_ID, CHANNEL_ID, PROMO_ID, QUANTITY_SOLD, SELLER, FULFILLMENT_CENTER, COURIER_ORG, TAX_COUNTRY, TAX_REGION,AMOUNT_SOLD )
  VALUES (
 P_PROD_ID,
 P_CUST_ID,
 to_date(P_TIME_ID,'YYYY-MM-DD HH24:MI:SS'),
 P_CHANNEL_ID,
 P_PROMO_ID,
 P_QUANTITY_SOLD,
 P_SELLER,
 P_FULFILLMENT_CENTER,
 P_COURIER_ORG,
 P_TAX_COUNTRY,
 P_TAX_REGION,
 P_AMOUNT_SOLD);
EXCEPTION
  --- Si hubiera PK, podriamos hacer un UPDATE en el caso de un POST de una clave ya existente !!!
  WHEN OTHERS THEN
    HTP.print(SQLERRM);
END create_sales;
/

BEGIN
  ORDS.define_module(
    p_module_name    => 'postsales',
    p_base_path      => 'cresale/',
    p_items_per_page => 0);

  ORDS.define_template(
   p_module_name    => 'postsales',
   p_pattern        => 'sales/');

  ORDS.define_handler(
    p_module_name    => 'postsales',
    p_pattern        => 'sales/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => '
BEGIN
create_sales (
 P_PROD_ID => :prodid,
 P_CUST_ID => :custid,
 P_TIME_ID => :timeid,
 P_CHANNEL_ID => :channelid,
 P_PROMO_ID => :promoid,
 P_QUANTITY_SOLD => :qtysold,
 P_SELLER => :seller,
 P_FULFILLMENT_CENTER => :fullcenter,
 P_COURIER_ORG => :courierorg,
 P_TAX_COUNTRY => :taxcountry,
 P_TAX_REGION => :taxregion,
 P_AMOUNT_SOLD => :amountsold);
 END;',
    p_items_per_page => 0);
commit;
  END;
/

http://172.16.1.4:8080/ords/jsonpdb/sh/cresale/sales/
http://130.61.52.57:8080/ords/jsonpdb/sh/cresale/sales/

### Hay que utilizar un JSON para el paso de parametros:


[opc@clicn01 ~]$ cat cre.sales.json
{
  "prodid": "132",
  "custid": "1684090",
  "timeid": "2018-03-28 00:00:00",
  "channelid": "9",
  "promoid": "419",
  "qtysold": "34",
  "seller": "10180",
  "fullcenter": "13681",
  "courierorg": "1105",
  "taxcountry": "NT",
  "taxregion": "KM",
  "amountsold": "1000"
}

curl -i -X POST --data-binary @/home/opc/cre.sales.json -H "Content-Type: application/json" http://172.16.1.4:8080/ords/jsonpdb/sh/cresale/sales/

HTTP/1.1 200 OK
Date: Thu, 11 Oct 2018 10:15:08 GMT
Transfer-Encoding: chunked



select * from sales where time_id = to_date('2018-03-28 00:00:00','YYYY-MM-DD HH24:MI:SS');

   PROD_ID    CUST_ID TIME_ID	CHANNEL_ID   PROMO_ID QUANTITY_SOLD	SELLER
---------- ---------- --------- ---------- ---------- ------------- ----------
FULFILLMENT_CENTER COURIER_ORG TAX TAX AMOUNT_SOLD
------------------ ----------- --- --- -----------
       132    1684090 28-MAR-18 	 9	  419		 34	 10180
	     13681	  1105 NT  KM	      1000


BEGIN
  ORDS.define_service(
    p_module_name    => 'consultasales',
    p_base_path      => 'conssales/',
    p_pattern        => 'sales/:fecha',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'SELECT * FROM sh.sales where time_id = to_date(:fecha,''YYYY-MM-DD'')',
    p_items_per_page => 0);
    
  COMMIT;
END;
/

curl -i -k http://172.16.1.4:8080/ords/jsonpdb/sh/conssales/sales/2018-03-28
curl -i -k http://130.61.52.57:8080/ords/jsonpdb/sh/conssales/sales/2018-03-28


SQL> desc channels
 Name					   Null?    Type
 ----------------------------------------- -------- ----------------------------
 CHANNEL_ID				   NOT NULL NUMBER
 CHANNEL_DESC				   NOT NULL VARCHAR2(20)
 CHANNEL_CLASS				   NOT NULL VARCHAR2(20)
 CHANNEL_CLASS_ID			   NOT NULL NUMBER
 CHANNEL_TOTAL				   NOT NULL VARCHAR2(13)
 CHANNEL_TOTAL_ID			   NOT NULL NUMBER



CREATE OR REPLACE PROCEDURE p_update_channel (
 P_CHANNEL_ID	channels.channel_id%TYPE,
 P_CHANNEL_DESC	channels.channel_desc%TYPE,
 P_CHANNEL_CLASS channels.channel_class%TYPE,
P_CHANNEL_CLASS_ID channels.channel_class_id%TYPE,
P_CHANNEL_TOTAL channels.channel_total%TYPE,
P_CHANNEL_TOTAL_ID channels.channel_total_id%TYPE
)
AS
BEGIN
  UPDATE channels 
  set CHANNEL_DESC = P_CHANNEL_DESC, CHANNEL_CLASS = P_CHANNEL_CLASS , 
      CHANNEL_CLASS_ID = P_CHANNEL_CLASS_ID, CHANNEL_TOTAL = P_CHANNEL_TOTAL, CHANNEL_TOTAL_ID = P_CHANNEL_TOTAL_ID
  WHERE CHANNEL_ID = P_CHANNEL_ID;
EXCEPTION
  WHEN OTHERS THEN
    HTP.print(SQLERRM);
END p_update_channel;
/


BEGIN
  ORDS.define_module(
    p_module_name    => 'putchannel',
    p_base_path      => 'updchannel/',
    p_items_per_page => 0);

  ORDS.define_template(
   p_module_name    => 'putchannel',
   p_pattern        => 'channel/');

  ORDS.define_handler(
    p_module_name    => 'putchannel',
    p_pattern        => 'channel/',
    p_method         => 'PUT',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => '
BEGIN
p_update_channel (
 P_CHANNEL_ID => :channelid,
 P_CHANNEL_DESC => :channeldesc,
 P_CHANNEL_CLASS => :channelclass,
 P_CHANNEL_CLASS_ID => :channelclassid,
 P_CHANNEL_TOTAL => :channeltotal,
 P_CHANNEL_TOTAL_ID => :channeltotalid);
 END;',
    p_items_per_page => 0);
commit;
  END;
/


http://172.16.1.4:8080/ords/jsonpdb/sh/updchannel/channel/
http://130.61.52.57:8080/ords/jsonpdb/sh/updchannel/channel/

### Hay que utilizar un JSON para el paso de parametros:


[opc@clicn01 ~]$ cat upd_channel.json
{
  "channelid": "2",
  "channeldesc": "Channel 2 modificado",
  "channelclass": "Direct",
  "channelclassid": "12",
  "channeltotal": "Channel total",
  "channeltotalid": "1"
}

