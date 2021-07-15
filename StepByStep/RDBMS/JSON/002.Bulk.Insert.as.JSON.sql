-- Tabla con CHECK JSON !!!


create table SALES_JSON_CHECK_INSERT
(
ID VARCHAR2(50),
sales_json CLOB,
CONSTRAINT sales_json_insert_pk primary Key (id),
CONSTRAINT sales_json_insert_check CHECK (sales_json IS JSON)
) tablespace SH;

create table SALES_JSON_CHECK
(
ID VARCHAR2(50),
sales_json CLOB,
CONSTRAINT sales_json_pk primary Key (id),
CONSTRAINT sales_json_check CHECK (sales_json IS JSON)
) tablespace SH;

create table SALES_JSON_CHECK_10M
(
ID VARCHAR2(50),
sales_json CLOB,
CONSTRAINT sales_json_10m_pk primary Key (id),
CONSTRAINT sales_json_10m_check CHECK (sales_json IS JSON)
) tablespace SH;

-- Tabla sin CHECK JSON !!!

create table SALES_JSON_NOCHECK
(
ID VARCHAR2(50),
sales_json CLOB,
CONSTRAINT sales_json_nocheck_pk primary Key (id)
) tablespace SH;

-- Bulk INSERT !!!

alter session enable parallel DML;
alter session force parallel query parallel 4;

insert /*+ APPEND NOLOGGING */ into SALES_JSON_CHECK (id,sales_json)
select sys_guid(),
	json_object (
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
from sales where rownum < 1000001;

1000000 rows created.

Elapsed: 00:01:44.95
SQL> 

=> 1.000.000 filas en 100s => 10.000 registros/s !!!

insert /*+ APPEND NOLOGGING */ into SALES_JSON_NOCHECK (id,sales_json)
select sys_guid(),
	json_object (
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
from sales where rownum < 1000001;

1000000 rows created.

Elapsed: 00:02:16.30
SQL> SQL> commit;

Commit complete.

Elapsed: 00:00:00.29

-- Bulk INSERT !!!

alter session enable parallel DML;
alter session force parallel query parallel 4;

insert /*+ APPEND NOLOGGING */ into SALES_JSON_CHECK_10M (id,sales_json)
select sys_guid(),
	json_object (
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
from sales where rownum < 10000001;


