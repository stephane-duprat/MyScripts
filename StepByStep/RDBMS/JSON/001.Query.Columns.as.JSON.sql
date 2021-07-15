--- Transforma modo ROW en JSON !!!

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


select json_object (
	'PRODID' value PROD_ID,
	'CUSTID' value CUST_ID,
	'TIMEID' value TIME_ID,
	'CHANNELID' value CHANNEL_ID,
	'PROMOID' value PROMO_ID,
	'QUANTITY_SOLD' value QUANTITY_SOLD,
	'SELLER' value SELLER,
	'FULFILLMENT_CENTER' value FULFILLMENT_CENTER,
	'TAX_COUNTRY' value TAX_COUNTRY,
	'TAX_REGION' value TAX_REGION,
	'AMOUNT_SOLD' value AMOUNT_SOLD,
	'TOTAL_SOLD' value QUANTITY_SOLD*AMOUNT_SOLD
	) as mijson
from sales
where rownum < 6;

MIJSON
--------------------------------------------------------------------------------
{"PRODID":79,"CUSTID":3955613,"TIMEID":"2012-07-25T00:00:00","CHANNELID":3,"PROM
OID":287,"QUANTITY_SOLD":84,"SELLER":10464,"FULFILLMENT_CENTER":13849,"TAX_COUNT
RY":"VL","TAX_REGION":"SM","AMOUNT_SOLD":47,"TOTAL_SOLD":3948}

{"PRODID":118,"CUSTID":1402909,"TIMEID":"2012-08-28T00:00:00","CHANNELID":4,"PRO
MOID":408,"QUANTITY_SOLD":45,"SELLER":10883,"FULFILLMENT_CENTER":13855,"TAX_COUN
TRY":"XI","TAX_REGION":"GY","AMOUNT_SOLD":6,"TOTAL_SOLD":270}

{"PRODID":101,"CUSTID":4656387,"TIMEID":"2012-07-04T00:00:00","CHANNELID":3,"PRO
MOID":430,"QUANTITY_SOLD":23,"SELLER":10114,"FULFILLMENT_CENTER":14285,"TAX_COUN
TRY":"YY","TAX_REGION":"VK","AMOUNT_SOLD":32,"TOTAL_SOLD":736}

{"PRODID":94,"CUSTID":2362795,"TIMEID":"2012-09-29T00:00:00","CHANNELID":5,"PROM
OID":69,"QUANTITY_SOLD":47,"SELLER":10242,"FULFILLMENT_CENTER":14565,"TAX_COUNTR
Y":"XI","TAX_REGION":null,"AMOUNT_SOLD":23,"TOTAL_SOLD":1081}

{"PRODID":36,"CUSTID":958541,"TIMEID":"2012-09-23T00:00:00","CHANNELID":9,"PROMO
ID":215,"QUANTITY_SOLD":72,"SELLER":10454,"FULFILLMENT_CENTER":14716,"TAX_COUNTR
Y":"UR","TAX_REGION":"IK","AMOUNT_SOLD":38,"TOTAL_SOLD":2736}


--- Ejemplo de pivotación con JSON_OBJECTAGG !!!

SQL> desc CHANNELS
 Name					   Null?    Type
 ----------------------------------------- -------- ----------------------------
 CHANNEL_ID				   NOT NULL NUMBER
 CHANNEL_DESC				   NOT NULL VARCHAR2(20)
 CHANNEL_CLASS				   NOT NULL VARCHAR2(20)
 CHANNEL_CLASS_ID			   NOT NULL NUMBER
 CHANNEL_TOTAL				   NOT NULL VARCHAR2(13)
 CHANNEL_TOTAL_ID			   NOT NULL NUMBER


select JSON_OBJECTAGG (
	KEY to_char(c.CHANNEL_ID) value c.CHANNEL_CLASS || '-' || c.CHANNEL_DESC
	) as canales
from channels c
order by c.CHANNEL_DESC;


CANALES
--------------------------------------------------------------------------------
{"3":"Direct-Direct Sales","9":"Direct-Tele Sales","5":"Indirect-Catalog","4":"I
ndirect-Internet","2":"Others-Partners"}



--- Ejemplo de JSON_ARRAY !!!

select JSON_ARRAY (
	rownum,
	JSON_OBJECT (KEY 'Descripcion' value  CHANNEL_DESC),
	JSON_OBJECT (KEY 'ID canal' value  CHANNEL_ID)
	) as canales_array
from channels c;


CANALES_ARRAY
--------------------------------------------------------------------------------
[1,{"Descripcion":"Direct Sales"},{"ID canal":3}]
[2,{"Descripcion":"Tele Sales"},{"ID canal":9}]
[3,{"Descripcion":"Catalog"},{"ID canal":5}]
[4,{"Descripcion":"Internet"},{"ID canal":4}]
[5,{"Descripcion":"Partners"},{"ID canal":2}]


