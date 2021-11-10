--*******************

--DDL S_ASSET

--*******************

 

create table DATA_USER.SBL_S_ASSET (
       ROW_ID               VARCHAR2(18) NOT NULL,
       CREATED              DATE,
       LAST_UPD             DATE,
       LAST_UPD_BY          VARCHAR2(60),
       ASSET_NUM            VARCHAR2(18),
       START_DT             DATE,
       END_DT               DATE,     
       BILL_ACCNT_ID        VARCHAR2(18), --INDEX
       BILL_PROFILE_ID      VARCHAR2(18), --INDEX
       INTEGRATION_ID       VARCHAR2(32),
       OWNER_ACCNT_ID       VARCHAR2(18), --INDEX
       PAR_ASSET_ID         VARCHAR2(18),
       PROD_ID              VARCHAR2(18),
       ROOT_ASSET_ID        VARCHAR2(18), --INDEX
       SERIAL_NUM           VARCHAR2(18), --INDEX
       SERV_ACCT_ID         VARCHAR2(18),
       STATUS_CD            VARCHAR(32),   --INDEX
       PROM_INTEG_ID        VARCHAR2(18)
);

--PK

ALTER TABLE DATA_USER.SBL_S_ASSET ADD CONSTRAINT PK_SBL_S_ASSET PRIMARY KEY (ROW_ID);
CREATE INDEX I_SBL_S_ASSET_1 ON DATA_USER.SBL_S_ASSET(SERIAL_NUM);
CREATE INDEX I_SBL_S_ASSET_2 ON DATA_USER.SBL_S_ASSET(BILL_ACCNT_ID);
CREATE INDEX I_SBL_S_ASSET_3 ON DATA_USER.SBL_S_ASSET(BILL_PROFILE_ID);
CREATE INDEX I_SBL_S_ASSET_4 ON DATA_USER.SBL_S_ASSET(OWNER_ACCNT_ID);
CREATE INDEX I_SBL_S_ASSET_5 ON DATA_USER.SBL_S_ASSET(ROOT_ASSET_ID);
CREATE INDEX I_SBL_S_ASSET_6 ON DATA_USER.SBL_S_ASSET(STATUS_CD);

 

--*******************

--DDL S_PROD_INT

--*******************

create table DATA_USER.SBL_S_PROD_INT
(
       ROW_ID             VARCHAR2(18) NOT NULL,
       CREATED            DATE,
       CREATED_BY         VARCHAR2(60),
       LAST_UPD           DATE,
       NAME               VARCHAR2(64), --INDEX
       ORDERABLE_FLG      VARCHAR2(4),
       BILLING_TYPE_CD    VARCHAR2(60),
       DESC_TEXT          VARCHAR2(256),
       PROD_CD            VARCHAR2(60),
       TYPE               VARCHAR2(60)
);

--PK

ALTER TABLE DATA_USER.SBL_S_PROD_INT ADD CONSTRAINT PK_SBL_S_PROD_INT PRIMARY KEY (ROW_ID);
CREATE INDEX I_SBL_S_PROD_INT_1 ON DATA_USER.SBL_S_PROD_INT(NAME);


CREATE MATERIALIZED VIEW LOG ON DATA_USER.SBL_S_ASSET
WITH ROWID, PRIMARY KEY
INCLUDING NEW VALUES;

 

CREATE MATERIALIZED VIEW LOG ON DATA_USER.SBL_S_PROD_INT
WITH ROWID, PRIMARY KEY
INCLUDING NEW VALUES;
 

CREATE MATERIALIZED VIEW DATA_USER.ASSET_MV
BUILD IMMEDIATE
REFRESH FAST ON COMMIT
ENABLE QUERY REWRITE
AS
    select
           T1.row_id, --1
           T1.owner_accnt_id, --2
           T1.bill_accnt_id, --3          
           coalesce(T1.serial_num, T2.serial_num, T3.serial_num) as ccir_num,  --4
           T1.start_dt, --5
           T1.end_dt, --6
           T4.desc_text, --7
           T4.name as product_name --8
   from DATA_USER.SBL_S_ASSET T1
    left join DATA_USER.SBL_S_ASSET T2
    on T1.root_asset_id = T2.row_id
    left join DATA_USER.SBL_S_ASSET T3
    on T2.root_asset_id = T3.row_id
    left join DATA_USER.SBL_S_PROD_INT T4
    on T1.PROD_ID = T4.ROW_ID;

ERROR at line 17:
ORA-12054: cannot set the ON COMMIT refresh attribute for the materialized view

 --- Under schema DATA_USER, create the MV_CAPABILITIES_TABLE utility table !!!

 @?/rdbms/admin/utlxmv.sql

 SQL> desc MV_CAPABILITIES_TABLE
 Name					   Null?    Type
 ----------------------------------------- -------- ----------------------------
 STATEMENT_ID					    VARCHAR2(128)
 MVOWNER					    VARCHAR2(128)
 MVNAME 					    VARCHAR2(128)
 CAPABILITY_NAME				    VARCHAR2(128)
 POSSIBLE					    CHAR(1)
 RELATED_TEXT					    VARCHAR2(2000)
 RELATED_NUM					    NUMBER
 MSGNO						    NUMBER(38)
 MSGTXT 					    VARCHAR2(2000)
 SEQ						    NUMBER

drop MATERIALIZED VIEW DATA_USER.ASSET_MV;
CREATE MATERIALIZED VIEW DATA_USER.ASSET_MV
BUILD IMMEDIATE
REFRESH FORCE on DEMAND
ENABLE QUERY REWRITE
AS
    select
            T1.ROWID as ROWID_T1,
            T2.ROWID as ROWID_T2,
            T3.ROWID as ROWID_T3,
            T4.ROWID as ROWID_T4,
           T1.row_id, --1
           T1.owner_accnt_id, --2
           T1.bill_accnt_id, --3          
           coalesce(T1.serial_num, T2.serial_num, T3.serial_num) as ccir_num,  --4
           T1.start_dt, --5
           T1.end_dt, --6
           T4.desc_text, --7
           T4.name as product_name --8
   from DATA_USER.SBL_S_ASSET T1,
        DATA_USER.SBL_S_ASSET T2,
        DATA_USER.SBL_S_ASSET T3,
        DATA_USER.SBL_S_PROD_INT T4
    where T1.root_asset_id = T2.row_id
    and T2.root_asset_id = T3.row_id
    and T1.PROD_ID = T4.ROW_ID;

Materialized view created.

truncate table mv_capabilities_table;
exec dbms_mview.explain_mview('DATA_USER.ASSET_MV');

set linesize 100
col capability_name format a30
SELECT capability_name,  possible, msgtxt
           FROM mv_capabilities_table
           WHERE capability_name like '%FAST%';

drop MATERIALIZED VIEW DATA_USER.ASSET_MV;
CREATE MATERIALIZED VIEW DATA_USER.ASSET_MV
BUILD IMMEDIATE
REFRESH FAST on COMMIT
ENABLE QUERY REWRITE
AS
    select
            T1.ROWID as ROWID_T1,
            T2.ROWID as ROWID_T2,
            T3.ROWID as ROWID_T3,
            T4.ROWID as ROWID_T4,
           T1.row_id, --1
           T1.owner_accnt_id, --2
           T1.bill_accnt_id, --3          
           coalesce(T1.serial_num, T2.serial_num, T3.serial_num) as ccir_num,  --4
           T1.start_dt, --5
           T1.end_dt, --6
           T4.desc_text, --7
           T4.name as product_name --8
   from DATA_USER.SBL_S_ASSET T1,
        DATA_USER.SBL_S_ASSET T2,
        DATA_USER.SBL_S_ASSET T3,
        DATA_USER.SBL_S_PROD_INT T4
    where T1.root_asset_id = T2.row_id
    and T2.root_asset_id = T3.row_id
    and T1.PROD_ID = T4.ROW_ID;