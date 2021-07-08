sqlplus admin/AaZZ0r_cle#1@sdudb_low

SQL> select version from v$instance;

VERSION
-----------------
19.0.0.0.0

SQL> col comp_name format a40
SQL> r
  1* select COMP_NAME, VERSION_FULL from dba_registry

COMP_NAME				 VERSION_FULL
---------------------------------------- ------------------------------
Oracle Database Catalog Views		 19.5.0.0.0
Oracle Database Packages and Types	 19.5.0.0.0
Oracle Real Application Clusters	 19.5.0.0.0
Oracle Label Security			 19.5.0.0.0
Oracle Text				 19.5.0.0.0
Spatial 				 19.5.0.0.0
Oracle Application Express		 20.2.0.00.20
Oracle Database Vault			 19.5.0.0.0

8 rows selected.

create user HYPT identified by "AaZZ0r_cle#1";
grant dwrole to hypt;
alter user hypt quota unlimited on DATA;

sqlplus hypt/AaZZ0r_cle#1@sdudb_high

SQL> select to_char(LO_ORDERDATE,'YYYY'), count(*) from ssb.lineorder group by to_char(LO_ORDERDATE,'YYYY');

TO_C   COUNT(*)
---- ----------
1992  912730718
1995  910183681
1993  910193238
1998  533696688
1997  910240598
1996  912680745
1994  910264041

7 rows selected.

create table lineorder 
(
calendar_year number not null,
LO_ORDERKEY				   NUMBER NOT NULL
,LO_LINENUMBER				NUMBER NOT NULL
,LO_CUSTKEY				   NUMBER NOT NULL
,LO_PARTKEY				   NUMBER NOT NULL
,LO_SUPPKEY				   NUMBER NOT NULL
,LO_ORDERDATE				   DATE NOT NULL
,LO_ORDERPRIORITY				    CHAR(15)
,LO_SHIPPRIORITY				    CHAR(1)
,LO_QUANTITY					    NUMBER
,LO_EXTENDEDPRICE				    NUMBER
,LO_ORDTOTALPRICE				    NUMBER
,LO_DISCOUNT					    NUMBER
,LO_REVENUE					    NUMBER
,LO_SUPPLYCOST					    NUMBER
,LO_TAX 					    NUMBER
,LO_COMMITDATE				   NUMBER NOT NULL
,LO_SHIPMODE					    CHAR(10)
)
partition by list (CALENDAR_YEAR)
(
partition P_1992 values (1992),
partition P_1993 values (1993),
partition P_1994 values (1994),
partition P_1995 values (1995),
partition P_1996 values (1996),
partition P_1997 values (1997),
partition P_1998 values (1998)
);

insert /*+ APPEND */ into lineorder
select to_number(to_char(CCCP.LO_ORDERDATE,'YYYY')),
       CCCP.*
from ssb.lineorder CCCP
where rownum < 1000001;

commit;

SQL> select calendar_year, count(*) from lineorder group by calendar_year;

CALENDAR_YEAR	COUNT(*)
------------- ----------
	 1997	  152303
	 1995	  152034
	 1998	   89828
	 1994	  152097
	 1993	  151740
	 1992	  151266
	 1996	  150732

7 rows selected.


--- Ahora exporto a DMP la partición P_1992 !!!

expdp admin/AaZZ0r_cle#1@sdudb_medium \
     dumpfile=expdp.P_1992.dmp \
     logfile=expdp.P_1992.log \
     TABLES=HYPT.LINEORDER:P_1992 \
     directory=data_pump_dir

Export: Release 19.0.0.0.0 - Production on Mon May 24 08:58:16 2021
Version 19.6.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Starting "ADMIN"."SYS_EXPORT_TABLE_01":  admin/********@sdudb_medium dumpfile=expdp.P_1992.dmp logfile=expdp.P_1992.log TABLES=HYPT.LINEORDER:P_1992 directory=data_pump_dir
Processing object type TABLE_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
Processing object type TABLE_EXPORT/TABLE/TABLE_DATA
Processing object type TABLE_EXPORT/TABLE/TABLE
Processing object type TABLE_EXPORT/TABLE/STATISTICS/MARKER
. . exported "HYPT"."LINEORDER":"P_1992"                 15.75 MB  151266 rows
ORA-39173: Encrypted data has been stored unencrypted in dump file set.
Master table "ADMIN"."SYS_EXPORT_TABLE_01" successfully loaded/unloaded
******************************************************************************
Dump file set for ADMIN.SYS_EXPORT_TABLE_01 is:
  /u03/dbfs/C2AF931CA92544B8E0538E14000A4D46/data/dpdump/expdp.P_1992.dmp
Job "ADMIN"."SYS_EXPORT_TABLE_01" successfully completed at Mon May 24 08:58:48 2021 elapsed 0 00:00:27
*/

sqlplus hypt/AaZZ0r_cle#1@sdudb_high

SELECT HYBRID FROM USER_TABLES WHERE TABLE_NAME = 'LINEORDER';

HYB
---
NO

--- Dropeo la partición P_1992 !!!

alter table lineorder drop partition P_1992;

--- Subo el DMP a Object Storage !!!

select * from table(dbms_cloud.list_files ('DATA_PUMP_DIR')) where OBJECT_NAME = 'expdp.P_1992.dmp';

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
expdp.P_1992.dmp
  16777216


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
24-MAY-21 08.58.23.000000 AM +00:00
24-MAY-21 08.58.48.000000 AM +00:00

--- Me creo un PAR en un Object Storage !!!

https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/7MhAIDCpugsm4qC3m4a3-mTDPmuO18zWKZUAgtwIqaFzALKMnyo3sEZnzfYDUPau/n/wedoinfra/b/SDU4DMP/o/

BEGIN
DBMS_CLOUD.PUT_OBJECT
(
    -- credential_name => 'TT',
    object_uri => 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/7MhAIDCpugsm4qC3m4a3-mTDPmuO18zWKZUAgtwIqaFzALKMnyo3sEZnzfYDUPau/n/wedoinfra/b/SDU4DMP/o/expdp.P_1992.dmp',
    directory_name  => 'DATA_PUMP_DIR',
    file_name => 'expdp.P_1992.dmp');
END;
/

PL/SQL procedure successfully completed.

SQL>

-- NB: el credential_name es opcional, ya que utilizo un PAR para escribir en el bucket !!!

--- Ahora intento añadir una partición externa a mi tabla !!!

SQL> ALTER TABLE LINEORDER
  ADD EXTERNAL PARTITION ATTRIBUTES
   (TYPE ORACLE_DATAPUMP
    DEFAULT DIRECTORY DATA_PUMP_DIR
   )
;   2    3    4    5

Table altered.

SQL> SELECT HYBRID FROM USER_TABLES WHERE TABLE_NAME = 'LINEORDER';

HYB
---
YES

SQL>

--- Creo un PAR sobrel el DMP: https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/X-cvUR7lE3ZArUSZWug5BTsQYzGccj5tAK2ZXdj_uPDmI_FdBUVMgqvdaU-ibyXT/n/wedoinfra/b/SDU4DMP/o/expdp.P_1992.dmp

alter table lineorder 
add partition P_1992_EXT values (1992) 
external location ('https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/X-cvUR7lE3ZArUSZWug5BTsQYzGccj5tAK2ZXdj_uPDmI_FdBUVMgqvdaU-ibyXT/n/wedoinfra/b/SDU4DMP/o/expdp.P_1992.dmp');

Table altered.

SQL>

SQL> select count(*) from lineorder where calendar_year =1992;
select count(*) from lineorder where calendar_year =1992
*
ERROR at line 1:
ORA-29913: error in executing ODCIEXTTABLEOPEN callout
ORA-39324: cannot load data from Data Pump dump file
"https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/X-cvUR7lE3ZArUSZWug5BTsQ
YzGccj5tAK2ZXdj_uPDmI_FdBUVMgqvdaU-ibyXT/n/wedoinfra/b/SDU4DMP/o/expdp.P_1992.dm
p"


--- Intento exportar la partición P_1992 como CSV !!!

--- Para eso vuelvo a crear y cargar la tabla !!!

drop table LINEORDER purge;

create table lineorder 
(
calendar_year number not null,
LO_ORDERKEY				   NUMBER NOT NULL
,LO_LINENUMBER				NUMBER NOT NULL
,LO_CUSTKEY				   NUMBER NOT NULL
,LO_PARTKEY				   NUMBER NOT NULL
,LO_SUPPKEY				   NUMBER NOT NULL
,LO_ORDERDATE				   DATE NOT NULL
,LO_ORDERPRIORITY				    CHAR(15)
,LO_SHIPPRIORITY				    CHAR(1)
,LO_QUANTITY					    NUMBER
,LO_EXTENDEDPRICE				    NUMBER
,LO_ORDTOTALPRICE				    NUMBER
,LO_DISCOUNT					    NUMBER
,LO_REVENUE					    NUMBER
,LO_SUPPLYCOST					    NUMBER
,LO_TAX 					    NUMBER
,LO_COMMITDATE				   NUMBER NOT NULL
,LO_SHIPMODE					    CHAR(10)
)
partition by list (CALENDAR_YEAR)
(
partition P_1992 values (1992),
partition P_1993 values (1993),
partition P_1994 values (1994),
partition P_1995 values (1995),
partition P_1996 values (1996),
partition P_1997 values (1997),
partition P_1998 values (1998)
);

insert /*+ APPEND */ into lineorder
select to_number(to_char(CCCP.LO_ORDERDATE,'YYYY')),
       CCCP.*
from ssb.lineorder CCCP
where rownum < 1000001;

commit;

--- Ejecutar lo siguiente en un script SQL !!!

[opc@benchcn01 ~]$ cat extract_P_1992.sql
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
set long 20000 lines 200

spool /tmp/P_1992.txt
select
	'"' || to_char( CALENDAR_YEAR ) || '"|"' ||
	to_char( LO_ORDERKEY ) || '"|"' ||
	to_char( LO_LINENUMBER ) || '"|"' ||
	to_char ( LO_CUSTKEY ) || '"|"' ||
	to_char( LO_PARTKEY ) || '"|"' ||
	to_char( LO_SUPPKEY ) || '"|"' ||
    to_char ( LO_ORDERDATE , 'YYYYMMDD') || '"|"' ||
    LO_ORDERPRIORITY  || '"|"' ||
    LO_SHIPPRIORITY   || '"|"' ||
	to_char ( LO_QUANTITY ) || '"|"' ||
    to_char (LO_EXTENDEDPRICE) || '"|"' ||
    to_char (LO_ORDTOTALPRICE) || '"|"' ||
    to_char (LO_DISCOUNT) || '"|"' ||
    to_char (LO_REVENUE) || '"|"' ||
    to_char (LO_SUPPLYCOST) || '"|"' ||
    to_char (LO_TAX) || '"|"' ||
    to_char (LO_COMMITDATE) || '"|"' ||
     LO_SHIPMODE || '"'
from hypt.lineorder;
spool off

echo "start extract_P_1992.sql" | sqlplus hypt/AaZZ0r_cle#1@sdudb_high

--- Luego el fichero plano lo subo a Object Storage:

--- Utilizo el PAR sobre el bucket !!!

https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/7MhAIDCpugsm4qC3m4a3-mTDPmuO18zWKZUAgtwIqaFzALKMnyo3sEZnzfYDUPau/n/wedoinfra/b/SDU4DMP/o/


curl -k -vX PUT -T /tmp/P_1992.txt https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/7MhAIDCpugsm4qC3m4a3-mTDPmuO18zWKZUAgtwIqaFzALKMnyo3sEZnzfYDUPau/n/wedoinfra/b/SDU4DMP/o/

--- Ahora dropeo la partición P_1992 en la tabla !!!

alter table lineorder drop partition P_1992;

ALTER TABLE LINEORDER
  ADD EXTERNAL PARTITION ATTRIBUTES
   (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY DATA_PUMP_DIR
    ACCESS PARAMETERS (
       FIELDS TERMINATED BY '|' ENCLOSED BY '"'
       (CALENDAR_YEAR ,
        LO_ORDERKEY ,
        LO_LINENUMBER ,
        LO_CUSTKEY ,
        LO_PARTKEY , 
        LO_SUPPKEY ,
        LO_ORDERDATE DATE 'YYYYMMDD',
        LO_ORDERPRIORITY CHAR(15),
        LO_SHIPPRIORITY CHAR(1),
        LO_QUANTITY ,
        LO_EXTENDEDPRICE ,
        LO_ORDTOTALPRICE ,
        LO_DISCOUNT ,
        LO_REVENUE ,
        LO_SUPPLYCOST ,
        LO_TAX ,
        LO_COMMITDATE ,
        LO_SHIPMODE CHAR(10)
        )
     )
   )
;

Table altered.

alter table lineorder 
add partition P_1992_EXT values (1992) 
external location ('https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/kHCmsTqs82XXDiDdtcFU-jqo-klGyqANvjgaTq_CMIHz_YcIog6OSEBEPaAg7Uw3/n/wedoinfra/b/SDU4DMP/o/P_1992.txt');

Table altered.

SQL>
SQL>
SQL> select count(*) from lineorder where calendar_year = 1992;

  COUNT(*)
----------
   1000000

=> Working fine !!!

SQL> set timing on
SQL> select sum(LO_EXTENDEDPRICE) from lineorder where calendar_year = 1994;

SUM(LO_EXTENDEDPRICE)
---------------------
	   5.7985E+11

Elapsed: 00:00:00.18
SQL> select sum(LO_EXTENDEDPRICE) from lineorder where calendar_year = 1992;

SUM(LO_EXTENDEDPRICE)
---------------------
	   3.8241E+12

Elapsed: 00:00:02.93
SQL> select LO_SHIPMODE, sum(LO_QUANTITY) from lineorder where calendar_year = 1992 group by LO_SHIPMODE;

LO_SHIPMOD SUM(LO_QUANTITY)
---------- ----------------
SHIP		    3633087
FOB		    3656409
TRUCK		    3659693
AIR		    3629647
RAIL		    3656243
MAIL		    3629177
REG AIR 	    3640931

7 rows selected.

Elapsed: 00:00:03.17
SQL>