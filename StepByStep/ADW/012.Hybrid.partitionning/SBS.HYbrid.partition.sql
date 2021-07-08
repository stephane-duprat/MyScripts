--- Necesario 19c +

-- Primero creo una tabla particionada !!!

sqlplus sdu/AaZZ0r_cle#1@benchadw19_low

create table sales_part
(
CALENDARYEAR NUMBER(4) not null,
PROD_ID	NUMBER NOT NULL,
CUST_ID	NUMBER not null,
TIME_ID	DATE not null,
CHANNEL_ID NUMBER not null,
PROMO_ID NUMBER not null,
QUANTITY_SOLD NUMBER(10,2),
AMOUNT_SOLD NUMBER(10,2)
)
PARTITION BY LIST (CALENDARYEAR)
(
partition P_1998 values (1998),
partition P_1999 values (1999),
partition P_2000 values (2000),
partition P_2001 values (2001),
partition P_ANYOTHER values (DEFAULT)
);


--- Inserto datos !!!

insert into sales_part
select 
	B.CALENDAR_YEAR,
	A.PROD_ID,
	A.CUST_ID,
	A.TIME_ID,
	A.CHANNEL_ID,
	A.PROMO_ID,
	A.QUANTITY_SOLD,
	A.AMOUNT_SOLD
from	sh.sales A,
	sh.times B
where	A.time_id = B.time_id;

918843 rows created.

commit;

Commit complete

select count(*) from sales_part partition (P_1998);

  COUNT(*)
----------
    178834

select count(*) from sales_part partition (P_1999);

  COUNT(*)
----------
    247945

select count(*) from sales_part partition (P_2000);

  COUNT(*)
----------
    232646

select count(*) from sales_part partition (P_2001);

  COUNT(*)
----------
    259418

select count(*) from sales_part partition (P_ANYOTHER);

  COUNT(*)
----------
	 0

SQL> select CALENDARYEAR, sum(QUANTITY_SOLD), sum(AMOUNT_SOLD) from sales_part group by CALENDARYEAR;

CALENDARYEAR SUM(QUANTITY_SOLD) SUM(AMOUNT_SOLD)
------------ ------------------ ----------------
	1998		 178834 	24083915
	1999		 247945       22219947.7
	2000		 232646       23765506.6
	2001		 259418 	28136462

Elapsed: 00:00:00.08

select CALENDARYEAR, sum(QUANTITY_SOLD), sum(AMOUNT_SOLD) from sales_part where CALENDARYEAR=2000 group by CALENDARYEAR;

CALENDARYEAR SUM(QUANTITY_SOLD) SUM(AMOUNT_SOLD)
------------ ------------------ ----------------
	2000		 232646       23765506.6

Elapsed: 00:00:00.06



Ahora exporto a DMP la partición P_2000 !!!

expdp admin/AaZZ0r_cle#1@benchadw19_medium \
     dumpfile=expdp.P_2000.dmp \
     logfile=expdp.P_2000.log \
     TABLES=SDU.SALES_PART:P_2000 \
     directory=data_pump_dir

Export: Release 19.0.0.0.0 - Production on Wed Jun 10 15:06:02 2020
Version 19.6.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Starting "ADMIN"."SYS_EXPORT_TABLE_03":  admin/xxxxxxx@benchadw19_medium dumpfile=expdp.P_2000.dmp logfile=expdp.P_2000.log TABLES=SDU.SALES_PART:P_2000 directory=data_pump_dir 
Processing object type TABLE_EXPORT/TABLE/TABLE_DATA
Processing object type TABLE_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
Processing object type TABLE_EXPORT/TABLE/STATISTICS/MARKER
Processing object type TABLE_EXPORT/TABLE/TABLE
. . exported "SDU"."SALES_PART":"P_2000"                 8.183 MB  232646 rows
ORA-39173: Encrypted data has been stored unencrypted in dump file set.
Master table "ADMIN"."SYS_EXPORT_TABLE_03" successfully loaded/unloaded
******************************************************************************
Dump file set for ADMIN.SYS_EXPORT_TABLE_03 is:
  /u03/dbfs/A3BBF6D430DAA0E8E0537B10000AFB21/data/dpdump/expdp.P_2000.dmp
Job "ADMIN"."SYS_EXPORT_TABLE_03" successfully completed at Wed Jun 10 15:08:04 2020 elapsed 0 00:01:58


sqlplus sdu/AaZZ0r_cle#1@benchadw19_low

SQL> SELECT HYBRID FROM USER_TABLES WHERE TABLE_NAME = 'SALES_PART';

HYB
---
NO

-- Borro la partición P_2000 !!!

alter table sales_part drop partition P_2000;

Table altered.


--- Ahora me subo el DMP generado por el expdp a un bucket de Object Storage !!!

sqlplus admin/AaZZ0r_cle#1@benchadw19_low

SQL> select * from table(dbms_cloud.list_files ('DATA_PUMP_DIR')) where OBJECT_NAME = 'expdp.P_2000.dmp';

OBJECT_NAME
--------------------------------------------------------------------------------
     BYTES
----------
CHECKSUM
--------------------------------------------------------------------------------
CREATED
---------------------------------------------------------------------------
LAST_MODIFIED
---------------------------------------------------------------------------
expdp.P_2000.dmp
   8777728


OBJECT_NAME
--------------------------------------------------------------------------------
     BYTES
----------
CHECKSUM
--------------------------------------------------------------------------------
CREATED
---------------------------------------------------------------------------
LAST_MODIFIED
---------------------------------------------------------------------------
10-JUN-20 03.06.09.000000 PM +00:00
10-JUN-20 03.08.03.000000 PM +00:00

--- Creo una credential !!!!

-- Uso ADMIN.SDU_CRED_NAME !!!
-- Copio el DMP al Bucket !!!

BEGIN
DBMS_CLOUD.PUT_OBJECT
(
    credential_name => 'SDU_CRED_NAME',
    object_uri => 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/wedoinfra/b/SDU4DMP/o/expdp.P_2000.dmp',
    directory_name  => 'DATA_PUMP_DIR',
    file_name => 'expdp.P_2000.dmp');
END;
/

PL/SQL procedure successfully completed.


--- A mi tabla no le puedo añadir una partición externa que se un DMP en Object Storage !!!!!
-- Pero puedo crear una tabla externa y crear una vista que englobe las 2 tablas !!! 

sqlplus admin/AaZZ0r_cle#1@benchadw19_low

BEGIN
   DBMS_CLOUD.CREATE_EXTERNAL_TABLE(
    table_name =>'SALES_EXT_PART',
    credential_name =>'SDU_CRED_NAME',
    file_uri_list =>'https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/wedoinfra/b/SDU4DMP/o/expdp.P_2000.dmp',
    format => json_object('type' value 'datapump', 'rejectlimit' value '1'),
    column_list => 'CALENDARYEAR NUMBER(4), PROD_ID NUMBER, CUST_ID NUMBER,TIME_ID DATE,CHANNEL_ID NUMBER,PROMO_ID NUMBER,QUANTITY_SOLD NUMBER(10,2),AMOUNT_SOLD NUMBER(10,2)' );
END;
/

PL/SQL procedure successfully completed.

REM: la tabla externa la creo en ADMIN y doy GRANT SELECT a SDU sobre ella. Lo suyo es crearla directamente en el esquema SDU !!!

grant select on SALES_EXT_PART to SDU;

Grant succeeded.

sqlplus sdu/AaZZ0r_cle#1@benchadw19_medium

create synonym SALES_EXT_PART for admin.SALES_EXT_PART;

select count(*) from SALES_EXT_PART;

ERROR at line 1:
ORA-29913: error in executing ODCIEXTTABLEOPEN callout
ORA-29400: data cartridge error
KUP-04080: directory object DATA_PUMP_DIR not found


[opc@benchcn01 instantclient_19_6]$ sqlplus admin/AaZZ0r_cle#1@benchadw19_low

SQL*Plus: Release 19.0.0.0.0 - Production on Thu Jun 11 08:28:23 2020
Version 19.6.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Last Successful login time: Wed Jun 10 2020 16:19:24 +00:00

Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.5.0.0.0

SQL> select count(*) from SALES_EXT_PART;
select count(*) from SALES_EXT_PART
                     *
ERROR at line 1:
ORA-29913: error in executing ODCIEXTTABLEOPEN callout
ORA-39324: cannot load data from Data Pump dump file
"https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/wedoinfra/b/SDU4DMP/o/ex
pdp.P_2000.dmp"


=> No parece que funcione con DMP.

--- Pruebo con ficheros TXT planos:
--- *******************************

https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/S_9Pz5CPpaXFo22MQ5xJASr-EEfVYGYFzvLT3btPheE/n/wedoinfra/b/SDU4DMP/o/expdp.P_2000.dmp

La partición P_2000 la vuelvo a importar en la tabla SDU.TT, para luego poder generar un fichero plano:

SQL> select count(*) from tt;

  COUNT(*)
----------
    232646

SQL> desc tt
 Name					   Null?    Type
 ----------------------------------------- -------- ----------------------------
 CALENDARYEAR				   NOT NULL NUMBER(4)
 PROD_ID				   NOT NULL NUMBER
 CUST_ID				   NOT NULL NUMBER
 TIME_ID				   NOT NULL DATE
 CHANNEL_ID				   NOT NULL NUMBER
 PROMO_ID				   NOT NULL NUMBER
 QUANTITY_SOLD					    NUMBER(10,2)
 AMOUNT_SOLD					    NUMBER(10,2)

set term off    
set echo off    
set underline off    
set pages 0    
set trimspool on    
set trimout on    
set feedback off    
set heading off    
set newpage 0    
set termout off    
set long 20000 

spool /tmp/P_2000.txt
select 
	'"' || to_char( CALENDARYEAR ) || '"|"' ||
	to_char( PROD_ID ) || '"|"' ||
	to_char( CUST_ID ) || '"|"' ||
	to_char ( TIME_ID , 'YYYYMMDD') || '"|"' ||
	to_char( CHANNEL_ID ) || '"|"' ||
	to_char( PROMO_ID ) || '"|"' ||
	to_char ( QUANTITY_SOLD ) || '"|"' ||
	to_char ( AMOUNT_SOLD ) || '"'
from SDU.TT;
spool off

[opc@benchcn01 tmp]$ head /tmp/P_2000.txt
"2000"|"21"|"5774"|"20001202"|"3"|"999"|"1"|"993.63"
"2000"|"21"|"22"|"20001203"|"3"|"999"|"1"|"1018.26"
"2000"|"21"|"2668"|"20001203"|"3"|"999"|"1"|"1018.26"
"2000"|"21"|"3815"|"20001203"|"3"|"999"|"1"|"1018.26"
"2000"|"21"|"6315"|"20001203"|"3"|"999"|"1"|"1018.26"
"2000"|"21"|"345"|"20001207"|"3"|"999"|"1"|"993.63"
"2000"|"21"|"1005"|"20001207"|"3"|"999"|"1"|"993.63"
"2000"|"21"|"3302"|"20001207"|"3"|"999"|"1"|"993.63"
"2000"|"21"|"3510"|"20001207"|"3"|"999"|"1"|"993.63"
"2000"|"21"|"3695"|"20001207"|"3"|"999"|"1"|"993.63"

--- Este fichero lo copio al bucket !!!

curl -k -vX PUT -T /tmp/P_2000.txt https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/rt3DcRqMuhIGdTAOXKv_xm0gYh6xPNZ_fcaqOpnihmE/n/wedoinfra/b/SDU4DMP/o/


--- Ahora creo una tabla con particiones hibridas !!!

sqlplus admin/AaZZ0r_cle#1@benchadw19_low

BEGIN
  DBMS_CLOUD.CREATE_HYBRID_PART_TABLE(
      table_name =>'SALES_EXT_PART',  
      credential_name =>'SDU_CRED_NAME',  
      format => json_object('delimiter' value '|', 'quote' value '"' ,'recorddelimiter' value 'newline', 'characterset' value 'al32utf8'),  
      column_list => 'CALENDARYEAR number(4) not null, PROD_ID number not null, CUST_ID number not null, TIME_ID date not null, CHANNEL_ID NUMBER not null,PROMO_ID number not null,QUANTITY_SOLD NUMBER(10,2), AMOUNT_SOLD NUMBER(10,2)',
      partitioning_clause => 'partition by LIST (CALENDARYEAR)
           (partition P_1998 values (1998),
	    partition P_1999 values (1999),
	    partition P_2000 values (2000) external location (''https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/wedoinfra/b/SDU4DMP/o/P_2000.txt''),
	    partition P_2001 values (2001),
	    partition P_ANYOTHER values (DEFAULT))'
     );
END;
/

SQL> select count(*) from SALES_EXT_PART partition (P_2000);
select count(*) from SALES_EXT_PART partition (P_2000)
*
ERROR at line 1:
ORA-29913: error in executing ODCIEXTTABLEFETCH callout
ORA-30653: reject limit reached


 => Hay que validar la tabla hibrida !!!

BEGIN
 DBMS_CLOUD.VALIDATE_HYBRID_PART_TABLE(
    table_name => 'SALES_EXT_PART',
    partition_name => 'P_2000');
END;
/

ERROR at line 1:
ORA-20003: Reject limit reached, query table "ADMIN"."VALIDATE$21_LOG" for
error details
ORA-06512: at "C##CLOUD$SERVICE.DBMS_CLOUD", line 943
ORA-06512: at "C##CLOUD$SERVICE.DBMS_CLOUD", line 1229
ORA-06512: at "C##CLOUD$SERVICE.DBMS_CLOUD", line 1990
ORA-06512: at line 2

select count(*) from "ADMIN"."VALIDATE$21_LOG";

SQL> select count(*) from "ADMIN"."VALIDATE$21_LOG";

  COUNT(*)
----------
	49

SQL> select * from "ADMIN"."VALIDATE$21_LOG";

RECORD
--------------------------------------------------------------------------------


 LOG file opened at 06/11/20 09:55:32

Total Number of Files=1

Data File: https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/wedoinfra/b/SD
U4DMP/o/P_2000.txt


Log File: VALIDATE$21_206296.log

RECORD
--------------------------------------------------------------------------------



 LOG file opened at 06/11/20 09:55:32

Bad File: VALIDATE$21_206296.bad

Field Definitions for table SALES_EXT_PART
  Record format DELIMITED BY
  Data in file has same endianness as the platform
  Rows with all null fields are accepted

RECORD
--------------------------------------------------------------------------------

  Fields in Data Source:

    CALENDARYEAR		    CHAR (255)
      Terminated by "|"
      Enclosed by """ and """
    PROD_ID			    CHAR (255)
      Terminated by "|"
      Enclosed by """ and """
    CUST_ID			    CHAR (255)
      Terminated by "|"

RECORD
--------------------------------------------------------------------------------
      Enclosed by """ and """
    TIME_ID			    CHAR (255)
      Terminated by "|"
      Enclosed by """ and """
    CHANNEL_ID			    CHAR (255)
      Terminated by "|"
      Enclosed by """ and """
    PROMO_ID			    CHAR (255)
      Terminated by "|"
      Enclosed by """ and """
    QUANTITY_SOLD		    CHAR (255)

RECORD
--------------------------------------------------------------------------------
      Terminated by "|"
      Enclosed by """ and """
    AMOUNT_SOLD 		    CHAR (255)
      Terminated by "|"
      Enclosed by """ and """
error processing column TIME_ID in row 1 for datafile https://objectstorage.eu-f
rankfurt-1.oraclecloud.com/n/wedoinfra/b/SDU4DMP/o/P_2000.txt

ORA-01861: literal does not match format string

49 rows selected.


--- Es por la fecha !!!

drop table SALES_EXT_PART;

BEGIN
  DBMS_CLOUD.CREATE_HYBRID_PART_TABLE(
      table_name =>'SALES_EXT_PART',  
      credential_name =>'SDU_CRED_NAME',  
      format => json_object('delimiter' value '|', 'quote' value '"' ,'recorddelimiter' value 'newline', 'characterset' value 'al32utf8','dateformat' value 'YYYYMMDD'),  
      column_list => 'CALENDARYEAR number(4) not null, PROD_ID number not null, CUST_ID number not null, TIME_ID date not null, CHANNEL_ID NUMBER not null,PROMO_ID number not null,QUANTITY_SOLD NUMBER(10,2), AMOUNT_SOLD NUMBER(10,2)',
      partitioning_clause => 'partition by LIST (CALENDARYEAR)
           (partition P_1998 values (1998),
	    partition P_1999 values (1999),
	    partition P_2000 values (2000) external location (''https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/wedoinfra/b/SDU4DMP/o/P_2000.txt''),
	    partition P_2001 values (2001),
	    partition P_ANYOTHER values (DEFAULT))'
     );
END;
/

BEGIN
 DBMS_CLOUD.VALIDATE_HYBRID_PART_TABLE(
    table_name => 'SALES_EXT_PART',
    partition_name => 'P_2000');
END;
/

PL/SQL procedure successfully completed.

SQL> r
  1* select count(*) from SALES_EXT_PART partition (P_2000)

  COUNT(*)
----------
    232646

Elapsed: 00:00:00.75

--- Inserto datos en las particiones internas !!!

insert into ADMIN.SALES_EXT_PART select * from SDU.SALES_PART;


686197 rows created.

Elapsed: 00:00:01.82
SQL> commit;

Commit complete.

Elapsed: 00:00:00.01

select CALENDARYEAR, sum(QUANTITY_SOLD), sum(AMOUNT_SOLD) from sales_ext_part group by CALENDARYEAR;

select CALENDARYEAR, sum(QUANTITY_SOLD), sum(AMOUNT_SOLD) from sales_ext_part where CALENDARYEAR=2000 group by CALENDARYEAR;


SQL> r
  1* select CALENDARYEAR, sum(QUANTITY_SOLD), sum(AMOUNT_SOLD) from sales_ext_part group by CALENDARYEAR

CALENDARYEAR SUM(QUANTITY_SOLD) SUM(AMOUNT_SOLD)
------------ ------------------ ----------------
	1998		 178834 	24083915
	1999		 247945       22219947.7
	2000		 232646       23765506.6
	2001		 259418 	28136462

Elapsed: 00:00:00.92


SQL> select CALENDARYEAR, sum(QUANTITY_SOLD), sum(AMOUNT_SOLD) from sales_ext_part where CALENDARYEAR=2000 group by CALENDARYEAR;

CALENDARYEAR SUM(QUANTITY_SOLD) SUM(AMOUNT_SOLD)
------------ ------------------ ----------------
	2000		 232646       23765506.6

Elapsed: 00:00:00.82







