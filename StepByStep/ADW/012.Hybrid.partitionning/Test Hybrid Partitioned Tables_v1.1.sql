------------------------------------
-- Test Hybrid Partitioned Tables --
------------------------------------
--base on https://database-heartbeat.com/2021/03/23/save-storage-cost-with-hybrid-partitioned-tables-in-oracle-autonomous-database/
--Oracle doc: https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/dbms-cloud-subprograms.html#GUID-9C7D1555-F323-4F48-9C8C-6AB025EF8C86
--Video: https://www.youtube.com/watch?v=Z21-Mc_s3a4
--Live Labs: https://oracle.github.io/learning-library/developer-library/oracle-db-features-for-developers/workshops/hybridpart-freetier/index.html?lab=partitioning

--TEST ENVIRONMENT: Autonomous Database Shared Infrastructure & Object Storage Bucket
drop table HYBRID_PART_TAB;
drop table HYBRID_PART_TAB_TIMESTAMP;


-- Step 1: Create Credential
begin
  DBMS_CLOUD.create_credential(
    credential_name => 'OBJ_STORE_CRED',
    username => 'oracleidentitycloudservice/fernando.albares@oracle.com',
    password => 'xxxxx_user_token_xxxxx'
  );
end;
/

alter database property set default_credential = 'ADMIN.OBJ_STORE_CRED';

--check credential
select owner, credential_name, enabled from dba_credentials;

--check files in object storage
select * from dbms_cloud.list_objects('OBJ_STORE_CRED','https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/');


-- Step2: Create the hybrid partitioned table
drop table HYBRID_PART_TAB;

BEGIN
    DBMS_CLOUD.CREATE_HYBRID_PART_TABLE(
        table_name => 'HYBRID_PART_TAB',
        credential_name => 'OBJ_STORE_CRED',
        format => json_object('type' VALUE 'CSV'),
        column_list => 'pid number(3), name varchar2(64)',
        partitioning_clause => 'partition by list (pid)
        ( partition p1 values (1) external location (''https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/pid1.csv''),
          partition p2 values (2),
          partition p3 values (3) )'
    );
END;
/

select * from HYBRID_PART_TAB;

--export first partition to dmp
BEGIN
 DBMS_CLOUD.EXPORT_DATA(
    credential_name => 'OBJ_STORE_CRED',
    file_uri_list => 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/pid1.dmp',
    format => json_object('type' value 'datapump'),
    query => 'select pid, name from HYBRID_PART_TAB where pid=1'
 );
END;
/

--files in Object storage
select * from dbms_cloud.list_objects('OBJ_STORE_CRED','https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/');
/

--Create Hybrid Partitioned table with dmp file
drop table HYBRID_PART_TAB;
/

BEGIN
    DBMS_CLOUD.CREATE_HYBRID_PART_TABLE(
        table_name => 'HYBRID_PART_TAB',
        credential_name => 'OBJ_STORE_CRED',
        format => json_object('type' VALUE 'datapump'),
        column_list => 'pid number(3), name varchar2(64)',
        partitioning_clause => 'partition by list (pid)
        ( partition p1 values (1) external location (''https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/pid1.dmp''),
          partition p2 values (2),
          partition p3 values (3) )'
    );
END;
/

--Validate
execute DBMS_CLOUD.VALIDATE_EXTERNAL_TABLE (table_name => 'HYBRID_PART_TAB');
/

--Hybrid metadata column in dba_tables
select table_name, hybrid from dba_tables where owner = 'ADMIN' and table_name = 'HYBRID_PART_TAB';
/

--Hybrid metadata column in dba_tab_partitions
select partition_name, tablespace_name, case read_only when 'YES' then 'external' else 'internal' end AS partition_type
from dba_tab_partitions
where table_owner = 'ADMIN' and table_name = 'HYBRID_PART_TAB'
order by partition_name;
/

--check data
select pid, name from HYBRID_PART_TAB order by pid;


-- Step 3: Insert some data
INSERT INTO HYBRID_PART_TAB values (1, 'name1a');
/
/*
ORA-14466: Data in a read-only partition or subpartition cannot be modified.
*/

INSERT INTO HYBRID_PART_TAB values (2, 'name2');
INSERT INTO HYBRID_PART_TAB values (3, 'name3');
commit;
/

--check data
select pid, name from HYBRID_PART_TAB order by pid;
/


-- Step 4: Add a further internal partition
ALTER TABLE HYBRID_PART_TAB ADD PARTITION p4 VALUES (4);

-- check the new partition
select partition_name, tablespace_name, case read_only when 'YES' then 'external' else 'internal' end AS partition_type
from dba_tab_partitions
where table_owner = 'ADMIN' and table_name = 'HYBRID_PART_TAB'
order by partition_name;

INSERT INTO HYBRID_PART_TAB values (4, 'name4');
commit;

select pid, name from HYBRID_PART_TAB order by pid;


-- Step 5: data in partition 2 is getting old
--export internal data into dmp external file
BEGIN
 DBMS_CLOUD.EXPORT_DATA(
    credential_name => 'OBJ_STORE_CRED',
    file_uri_list => 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/pid2.dmp',
    format => json_object('type' value 'datapump'),
    query => 'select pid, name from HYBRID_PART_TAB where pid=2'
 );
END;
/

--check files
select * from dbms_cloud.list_objects('OBJ_STORE_CRED','https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/');

--drop internal partition
ALTER TABLE HYBRID_PART_TAB DROP PARTITION p2;

select partition_name, tablespace_name, case read_only when 'YES' then 'external' else 'internal' end AS partition_type
from dba_tab_partitions
where table_owner = 'ADMIN' and table_name = 'HYBRID_PART_TAB'
order by partition_name;

--add external partition
ALTER TABLE HYBRID_PART_TAB
ADD PARTITION p2 VALUES (2) 
external location ('https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/pid2.dmp');
/

select partition_name, tablespace_name, case read_only when 'YES' then 'external' else 'internal' end AS partition_type
from dba_tab_partitions
where table_owner = 'ADMIN' and table_name = 'HYBRID_PART_TAB'
order by partition_name;

--check data
select pid, name from HYBRID_PART_TAB order by pid;

select partition_name, tablespace_name, case read_only when 'YES' then 'external' else 'internal' end AS partition_type
from dba_tab_partitions
where table_owner = 'ADMIN' and table_name = 'HYBRID_PART_TAB'
order by partition_name;



---
--- Partitioning by DATE or TIMESTAMP ---
---
drop table HYBRID_PART_TAB_TIMESTAMP;

-- create table in csv format
BEGIN 
DBMS_CLOUD.CREATE_HYBRID_PART_TABLE( 
    table_name      => 'HYBRID_PART_TAB_TIMESTAMP',  
    credential_name => 'OBJ_STORE_CRED',  
    format          => json_object('type' VALUE 'csv'),  
    column_list     => 'sale_date TIMESTAMP, product_name varchar2(64)',
    partitioning_clause => 'partition by RANGE (sale_date) 
      ( partition p1 values less than (to_timestamp(''1-feb-2021 00:00:00'',''dd-mon-yyyy hh24:mi:ss'')) external location (''https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/timestamp_pid1.csv''),
        partition p2 values less than (to_timestamp(''1-mar-2021 00:00:00'',''dd-mon-yyyy hh24:mi:ss'')), 
        partition p3 values less than (to_timestamp(''1-apr-2021 00:00:00'',''dd-mon-yyyy hh24:mi:ss'')),
        partition p999 values less than (MAXVALUE) 
)'
     );
END;
/

select sale_date, product_name from HYBRID_PART_TAB_TIMESTAMP;
/


-- export to dumpfile
BEGIN
 DBMS_CLOUD.EXPORT_DATA(
    credential_name => 'OBJ_STORE_CRED',
    file_uri_list => 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/timestamp_pid1.dmp',
    format => json_object('type' value 'datapump'),
    query => 'select sale_date, product_name from HYBRID_PART_TAB_TIMESTAMP where sale_date < to_timestamp(''1-feb-2021  00:00:00'', ''dd-mon-yyyy hh24:mi:ss'')'
 );
END;
/
 
-- recreate using datapump format
drop table HYBRID_PART_TAB_TIMESTAMP;
 
BEGIN 
DBMS_CLOUD.CREATE_HYBRID_PART_TABLE( 
    table_name      => 'HYBRID_PART_TAB_TIMESTAMP',  
    credential_name => 'OBJ_STORE_CRED',  
    format          => json_object('type' VALUE 'datapump'),  
    column_list     => 'sale_date TIMESTAMP, product_name varchar2(64)',
    partitioning_clause => 'partition by RANGE (sale_date) 
      ( partition p1 values less than (to_timestamp(''1-feb-2021 00:00:00'',''dd-mon-yyyy hh24:mi:ss'')) external location (''https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/timestamp_pid1.dmp''),
        partition p2 values less than (to_timestamp(''1-mar-2021 00:00:00'',''dd-mon-yyyy hh24:mi:ss'')), 
        partition p3 values less than (to_timestamp(''1-apr-2021 00:00:00'',''dd-mon-yyyy hh24:mi:ss'')),
        partition p999 values less than (MAXVALUE) 
)'
     );
END;
/
 
-- check data
select to_char(sale_date, 'yyyy-mm-dd hh24:mi:ss') as sale_date, product_name
from HYBRID_PART_TAB_TIMESTAMP
order by sale_date;

-- Add new partition
select partition_name, tablespace_name, case read_only when 'YES' then 'external' else 'internal' end AS partition_type
from dba_tab_partitions
where table_owner = 'ADMIN' and table_name = 'HYBRID_PART_TAB_TIMESTAMP'
order by partition_name;

ALTER TABLE HYBRID_PART_TAB_TIMESTAMP 
    SPLIT PARTITION p999 AT (to_date('1-may-2021 00:00:00','dd-mon-yyyy hh24:mi:ss')) 
    INTO (PARTITION p4, 
          PARTITION p999);

-- insert data 
INSERT INTO HYBRID_PART_TAB_TIMESTAMP values (to_timestamp('15-feb-2021 7:20:13','dd-mon-yyyy hh24:mi:ss'), 'product2'); 
INSERT INTO HYBRID_PART_TAB_TIMESTAMP values (to_timestamp('15-mar-2021 9:41:59','dd-mon-yyyy hh24:mi:ss'), 'product3');
INSERT INTO HYBRID_PART_TAB_TIMESTAMP values (to_timestamp('15-apr-2021 11:51:8','dd-mon-yyyy hh24:mi:ss'), 'product4');
commit;
/

-- check data
select to_char(sale_date, 'yyyy-mm-dd hh24:mi:ss') as sale_date, product_name
from HYBRID_PART_TAB_TIMESTAMP
order by sale_date;

-- check partitions
select partition_name, tablespace_name, case read_only when 'YES' then 'external' else 'internal' end AS partition_type
from dba_tab_partitions
where table_owner = 'ADMIN' and table_name = 'HYBRID_PART_TAB_TIMESTAMP'
order by partition_name;

--P2 is getting old. Export partition 2 (February) to Object Storage and drop the internal partition:
-- export internal partition to Object Storage
BEGIN
 DBMS_CLOUD.EXPORT_DATA(
    credential_name => 'OBJ_STORE_CRED',
    file_uri_list => 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/timestamp_pid2.dmp',
    format => json_object('type' value 'datapump'),
    query => 'select sale_date, product_name from HYBRID_PART_TAB_TIMESTAMP where sale_date between to_timestamp(''1-feb-2021  00:00:00'', ''dd-mon-yyyy hh24:mi:ss'') and to_timestamp(''28-feb-2021  23:59:59'', ''dd-mon-yyyy hh24:mi:ss'')'
 );
END;
/
 
-- drop the internal partition
ALTER TABLE HYBRID_PART_TAB_TIMESTAMP DROP PARTITION p2;

-- add the partition as external
ALTER TABLE HYBRID_PART_TAB_TIMESTAMP
ADD PARTITION p2 
VALUES less than (to_timestamp('1-mar-2021 00:00:00','dd-mon-yyyy hh24:mi:ss')) 
external location ('https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/timestamp_pid2.dmp');

/*
ORA-14047
Expected behaviour
*/

ALTER TABLE HYBRID_PART_TAB_TIMESTAMP 
    SPLIT PARTITION p3 AT (to_date('1-mar-2021 00:00:00','dd-mon-yyyy hh24:mi:ss')) 
    INTO (PARTITION p2 EXTERNAL LOCATION ('https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/timestamp_pid2.dmp') tablespace DATA, 
          PARTITION p3);

-- check partitions
select partition_name, tablespace_name, case read_only when 'YES' then 'external' else 'internal' end AS partition_type
from dba_tab_partitions
where table_owner = 'ADMIN' and table_name = 'HYBRID_PART_TAB_TIMESTAMP'
order by partition_name;


---
--- How to modify table structure ---
---

select to_char(sale_date, 'yyyy-mm-dd hh24:mi:ss') as sale_date, product_name
from HYBRID_PART_TAB_TIMESTAMP
order by sale_date;


alter table HYBRID_PART_TAB_TIMESTAMP add product_type varchar2(64);

desc HYBRID_PART_TAB_TIMESTAMP;

select * from HYBRID_PART_TAB_TIMESTAMP;
/*
ORA-29913: error in executing ODCIEXTTABLEOPEN callout ORA-29400: data cartridge error ORA-26034: Column PRODUCT_TYPE does not exist in stream
*/

select sale_date, product_name from HYBRID_PART_TAB_TIMESTAMP;
/*
ORA-29913: error in executing ODCIEXTTABLEOPEN callout ORA-29400: data cartridge error ORA-26034: Column PRODUCT_TYPE does not exist in stream
*/

alter table HYBRID_PART_TAB_TIMESTAMP drop column product_type;


BEGIN
 DBMS_CLOUD.EXPORT_DATA(
    credential_name => 'OBJ_STORE_CRED',
    file_uri_list => 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/timestamp_pid1b.dmp',
    format => json_object('type' value 'datapump'),
    query => 'select sale_date, product_name, ''n/a'' product_type from HYBRID_PART_TAB_TIMESTAMP where sale_date < to_timestamp(''1-feb-2021  00:00:00'', ''dd-mon-yyyy hh24:mi:ss'')'
 );
END;
/

BEGIN
 DBMS_CLOUD.EXPORT_DATA(
    credential_name => 'OBJ_STORE_CRED',
    file_uri_list => 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/timestamp_pid2b.dmp',
    format => json_object('type' value 'datapump'),
    query => 'select sale_date, product_name, ''n/a'' product_type from HYBRID_PART_TAB_TIMESTAMP where sale_date between to_timestamp(''1-feb-2021  00:00:00'', ''dd-mon-yyyy hh24:mi:ss'') and to_timestamp(''28-feb-2021  23:59:59'', ''dd-mon-yyyy hh24:mi:ss'')'
 );
END;
/

ALTER TABLE HYBRID_PART_TAB_TIMESTAMP
MODIFY PARTITION p1 
external location ('https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/timestamp_pid1b.dmp');

ALTER TABLE HYBRID_PART_TAB_TIMESTAMP
MODIFY PARTITION p2 
external location ('https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/timestamp_pid2b.dmp');

alter table HYBRID_PART_TAB_TIMESTAMP add product_type varchar2(64);

desc HYBRID_PART_TAB_TIMESTAMP;

select * from HYBRID_PART_TAB_TIMESTAMP;


---
--- Converting to Hybrid Partitioned Tables ---
---
-- Create partitioned table NON Hybrid
drop table INTERNAL_TO_HYPT_TABLE;
CREATE TABLE INTERNAL_TO_HYPT_TABLE (
    sale_date TIMESTAMP,
    product_name varchar2(64)
  ) partition by RANGE (sale_date) 
      ( partition p1 values less than (to_timestamp('1-feb-2021 00:00:00','dd-mon-yyyy hh24:mi:ss')),
        partition p2 values less than (to_timestamp('1-mar-2021 00:00:00','dd-mon-yyyy hh24:mi:ss')), 
        partition p3 values less than (to_timestamp('1-apr-2021 00:00:00','dd-mon-yyyy hh24:mi:ss')),
        partition p999 values less than (MAXVALUE) 
  );

-- insert data 
INSERT INTO INTERNAL_TO_HYPT_TABLE values (to_timestamp('15-jan-2021 10:30:51','dd-mon-yyyy hh24:mi:ss'), 'product1'); 
INSERT INTO INTERNAL_TO_HYPT_TABLE values (to_timestamp('15-feb-2021 7:20:13','dd-mon-yyyy hh24:mi:ss'), 'product2'); 
INSERT INTO INTERNAL_TO_HYPT_TABLE values (to_timestamp('15-mar-2021 9:41:59','dd-mon-yyyy hh24:mi:ss'), 'product3');
INSERT INTO INTERNAL_TO_HYPT_TABLE values (to_timestamp('15-apr-2021 11:51:8','dd-mon-yyyy hh24:mi:ss'), 'product4');
commit;
/

-- check partitions
select partition_name, tablespace_name, case read_only when 'YES' then 'external' else 'internal' end AS partition_type
from dba_tab_partitions
where table_owner = 'ADMIN' and table_name = 'INTERNAL_TO_HYPT_TABLE'
order by partition_name;

SELECT HYBRID FROM USER_TABLES WHERE TABLE_NAME = 'INTERNAL_TO_HYPT_TABLE';

ALTER TABLE internal_to_hypt_table 
  ADD EXTERNAL PARTITION ATTRIBUTES
   (TYPE ORACLE_DATAPUMP      
    DEFAULT DIRECTORY "DATA_PUMP_DIR"      
    ACCESS PARAMETERS      ( CREDENTIAL "OBJ_STORE_CRED" NOLOGFILE   )   
    REJECT LIMIT 0   )
;

SELECT HYBRID FROM USER_TABLES WHERE TABLE_NAME = 'INTERNAL_TO_HYPT_TABLE';

BEGIN
 DBMS_CLOUD.EXPORT_DATA(
    credential_name => 'OBJ_STORE_CRED',
    file_uri_list => 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/internal_to_hypt_pid1.dmp',
    format => json_object('type' value 'datapump'),
    query => 'select sale_date, product_name from INTERNAL_TO_HYPT_TABLE where sale_date < to_timestamp(''1-feb-2021  00:00:00'', ''dd-mon-yyyy hh24:mi:ss'')'
 );
END;
/

ALTER TABLE INTERNAL_TO_HYPT_TABLE 
    SPLIT PARTITION p2 AT (to_date('1-feb-2021 00:00:00','dd-mon-yyyy hh24:mi:ss')) 
    INTO (PARTITION p1 EXTERNAL LOCATION ('https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/emeasespainsandbox/b/external_partitions/o/internal_to_hypt_pid1.dmp') tablespace DATA, 
          PARTITION p2);


-- check partitions
select partition_name, tablespace_name, case read_only when 'YES' then 'external' else 'internal' end AS partition_type
from dba_tab_partitions
where table_owner = 'ADMIN' and table_name = 'INTERNAL_TO_HYPT_TABLE'
order by partition_name;

select * from INTERNAL_TO_HYPT_TABLE;


