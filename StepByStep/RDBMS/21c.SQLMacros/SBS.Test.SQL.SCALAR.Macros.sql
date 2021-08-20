### Creación del entorno !!!
##

sqlplus system/AaZZ0r_cle#1@dbcn20c:1521/pdb20c.sub05271030030.skynet.oraclevcn.com

create bigfile tablespace TBS_DEMO datafile size 10G autoextend on maxsize 40G;

Tablespace created.

SQL> create user demo_macro identified by "AaZZ0r_cle#1" default tablespace TBS_DEMO temporary tablespace TEMP;

User created.

SQL> alter user demo_macro quota unlimited on TBS_DEMO;

User altered.

SQL> grant connect, resource to demo_macro;

Grant succeeded.

### En el usuario demo_macro, importo los datos de SH !!!

sqlplus demo_macro/AaZZ0r_cle#1@dbcn20c:1521/pdb20c.sub05271030030.skynet.oraclevcn.com

SQL> select count(*) from CUSTOMERS;

  COUNT(*)
----------
   4878192

SQL> desc customers
 Name					   Null?    Type
 ----------------------------------------- -------- ----------------------------
 CUST_ID				   NOT NULL NUMBER
 CUST_FIRST_NAME			   NOT NULL VARCHAR2(20)
 CUST_LAST_NAME 			   NOT NULL VARCHAR2(40)
 CUST_GENDER				   NOT NULL CHAR(1)
 CUST_YEAR_OF_BIRTH			   NOT NULL NUMBER(4)
 CUST_MARITAL_STATUS				    VARCHAR2(20)
 CUST_STREET_ADDRESS			   NOT NULL VARCHAR2(40)
 CUST_POSTAL_CODE			   NOT NULL VARCHAR2(10)
 CUST_CITY				   NOT NULL VARCHAR2(30)
 CUST_CITY_ID				   NOT NULL NUMBER
 CUST_STATE_PROVINCE			   NOT NULL VARCHAR2(40)
 CUST_STATE_PROVINCE_ID 		   NOT NULL NUMBER
 COUNTRY_ID				   NOT NULL NUMBER
 CUST_MAIN_PHONE_NUMBER 		   NOT NULL VARCHAR2(25)
 CUST_INCOME_LEVEL				    VARCHAR2(30)
 CUST_CREDIT_LIMIT				    NUMBER
 CUST_EMAIL					    VARCHAR2(50)
 CUST_TOTAL				   NOT NULL VARCHAR2(14)
 CUST_TOTAL_ID				   NOT NULL NUMBER
 CUST_SRC_ID					    NUMBER
 CUST_EFF_FROM					    DATE
 CUST_EFF_TO					    DATE
 CUST_VALID					    VARCHAR2(1)

SQL> 

--- Función de calculo del nombre completo !!!

create or replace function FN_FULLNAME (
p_first_name IN VARCHAR2,
p_last_name IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN
	RETURN (p_last_name || ', ' || p_first_name);
END FN_FULLNAME;
/


set autotrace traceonly explain statistics
set timing on

select CUST_GENDER, FN_FULLNAME (CUST_FIRST_NAME,CUST_LAST_NAME)
from customers
where CUST_CREDIT_LIMIT <= 5000;

1829073 rows selected.

Elapsed: 00:00:38.36

Execution Plan
----------------------------------------------------------
Plan hash value: 2487033814

--------------------------------------------------------------------------------
-------------------------------

| Id  | Operation	     | Name	 | Rows  | Bytes | Cost (%CPU)| Time
 |    TQ  |IN-OUT| PQ Distrib |

--------------------------------------------------------------------------------
-------------------------------

|   0 | SELECT STATEMENT     |		 |  1874K|    37M| 19656   (1)| 00:00:01
 |	  |	 |	      |

|   1 |  PX COORDINATOR      |		 |	 |	 |	      |
 |	  |	 |	      |

|   2 |   PX SEND QC (RANDOM)| :TQ10000  |  1874K|    37M| 19656   (1)| 00:00:01
 |  Q1,00 | P->S | QC (RAND)  |

|   3 |    PX BLOCK ITERATOR |		 |  1874K|    37M| 19656   (1)| 00:00:01
 |  Q1,00 | PCWC |	      |

|*  4 |     TABLE ACCESS FULL| CUSTOMERS |  1874K|    37M| 19656   (1)| 00:00:01
 |  Q1,00 | PCWP |	      |

--------------------------------------------------------------------------------
-------------------------------


Predicate Information (identified by operation id):
---------------------------------------------------

   4 - filter("CUST_CREDIT_LIMIT"<=5000)

Note
-----
   - Degree of Parallelism is 2 because of table property


Statistics
----------------------------------------------------------
	 77  recursive calls
	 23  db block gets
     129928  consistent gets
     129793  physical reads
       4104  redo size
   62125735  bytes sent via SQL*Net to client
    1344443  bytes received via SQL*Net from client
     121940  SQL*Net roundtrips to/from client
	  1  sorts (memory)
	  0  sorts (disk)
    1829073  rows processed

set autotrace off

create or replace function MACRO_FULLNAME (
p_first_name IN VARCHAR2,
p_last_name IN VARCHAR2
)
RETURN VARCHAR2 SQL_MACRO (SCALAR)
IS
BEGIN
	RETURN q'{(p_last_name || ', ' || p_first_name)}';
END MACRO_FULLNAME;
/


set autotrace traceonly explain statistics
set timing on

select CUST_GENDER, MACRO_FULLNAME (CUST_FIRST_NAME,CUST_LAST_NAME)
from customers
where CUST_CREDIT_LIMIT <= 5000;


1829073 rows selected.

Elapsed: 00:00:38.64

Execution Plan
----------------------------------------------------------
Plan hash value: 2487033814

--------------------------------------------------------------------------------
-------------------------------

| Id  | Operation	     | Name	 | Rows  | Bytes | Cost (%CPU)| Time
 |    TQ  |IN-OUT| PQ Distrib |

--------------------------------------------------------------------------------
-------------------------------

|   0 | SELECT STATEMENT     |		 |  1874K|    37M| 19656   (1)| 00:00:01
 |	  |	 |	      |

|   1 |  PX COORDINATOR      |		 |	 |	 |	      |
 |	  |	 |	      |

|   2 |   PX SEND QC (RANDOM)| :TQ10000  |  1874K|    37M| 19656   (1)| 00:00:01
 |  Q1,00 | P->S | QC (RAND)  |

|   3 |    PX BLOCK ITERATOR |		 |  1874K|    37M| 19656   (1)| 00:00:01
 |  Q1,00 | PCWC |	      |

|*  4 |     TABLE ACCESS FULL| CUSTOMERS |  1874K|    37M| 19656   (1)| 00:00:01
 |  Q1,00 | PCWP |	      |

--------------------------------------------------------------------------------
-------------------------------


Predicate Information (identified by operation id):
---------------------------------------------------

   4 - filter("CUST_CREDIT_LIMIT"<=5000)

Note
-----
   - Degree of Parallelism is 2 because of table property


Statistics
----------------------------------------------------------
	 40  recursive calls
	  6  db block gets
     129926  consistent gets
     129793  physical reads
       1044  redo size
   62125754  bytes sent via SQL*Net to client
    1344446  bytes received via SQL*Net from client
     121940  SQL*Net roundtrips to/from client
	  0  sorts (memory)
	  0  sorts (disk)
    1829073  rows processed

SQL> SQL> 

select CUST_GENDER, FN_FULLNAME (CUST_FIRST_NAME,CUST_LAST_NAME)
from customers
where CUST_CREDIT_LIMIT > 14500
and FN_FULLNAME (CUST_FIRST_NAME,CUST_LAST_NAME) like 'A%';



select CUST_GENDER, MACRO_FULLNAME (CUST_FIRST_NAME,CUST_LAST_NAME)
from customers
where CUST_CREDIT_LIMIT > 14500
and MACRO_FULLNAME (CUST_FIRST_NAME,CUST_LAST_NAME) like 'A%';

--- OTRA PRUEBA:

[oracle@dbcn20c ~]$ sqlplus demo_macro/AaZZ0r_cle#1@dbcn20c:1521/pdb20c.sub05271030030.skynet.oraclevcn.com

SQL*Plus: Release 20.0.0.0.0 - Production on Thu Jun 4 12:14:18 2020
Version 20.3.0.0.0

Copyright (c) 1982, 2020, Oracle.  All rights reserved.

Last Successful login time: Tue Jun 02 2020 17:04:46 +02:00

Connected to:
Oracle Database 20c EE Extreme Perf Release 20.0.0.0.0 - Production
Version 20.3.0.0.0

create or replace function pdiff(m number, n number) return number
is
begin
  return(case when abs(m - n) = 0 then 0 else 1 end);
end;
/

Function created.

create or replace function mdiff(m number, n number) return varchar2
SQL_MACRO(SCALAR) is
begin
  return 'case when abs(m - n) = 0 then 0 else 1 end';
end;
/

Function created.

SQL> create table sd(m not null, n not null) as select r1, r1 + r2 from (select rownum r1 from dual connect by rownum <= 1e6), (select rownum - 6 r2 from dual connect by rownum <= 1e1);

Table created.

SQL> select count(*) from sd;

  COUNT(*)
----------
  10000000

SQL> set autotrace on explain statistics echo on linesize 132 pagesize 66 tab off timing on trimspool on
alter system flush buffer_cache;
select /*+ NO_INMEMORY */ count(*) from sd where pdiff(m, n) > 0;

  COUNT(*)
----------
   9000000

Elapsed: 00:00:16.72

Execution Plan
----------------------------------------------------------
Plan hash value: 2551399908

---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |     1 |    10 |  6524  (14)| 00:00:01 |
|   1 |  SORT AGGREGATE    |      |     1 |    10 |            |          |
|*  2 |   TABLE ACCESS FULL| SD   |   500K|  4882K|  6524  (14)| 00:00:01 |
---------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("PDIFF"("M","N")>0)


Statistics
----------------------------------------------------------
         40  recursive calls
          0  db block gets
      20714  consistent gets
      20701  physical reads
          0  redo size
        568  bytes sent via SQL*Net to client
        426  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed


alter system flush buffer_cache;
SQL> select count(*) from sd where mdiff(m, n) > 0;

  COUNT(*)
----------
   9000000

Elapsed: 00:00:01.20

Execution Plan
----------------------------------------------------------
Plan hash value: 2551399908

------------------------------------------------------------------------------------
| Id  | Operation                   | Name | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |      |     1 |    10 |   383  (43)| 00:00:01 |
|   1 |  SORT AGGREGATE             |      |     1 |    10 |            |          |
|*  2 |   TABLE ACCESS INMEMORY FULL| SD   |   500K|  4882K|   383  (43)| 00:00:01 |
------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - inmemory(CASE ABS("M"-"N") WHEN 0 THEN 0 ELSE 1 END >0)
       filter(CASE ABS("M"-"N") WHEN 0 THEN 0 ELSE 1 END >0)


Statistics
----------------------------------------------------------
        338  recursive calls
          4  db block gets
        349  consistent gets
        108  physical reads
          0  redo size
        568  bytes sent via SQL*Net to client
        407  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
         15  sorts (memory)
          0  sorts (disk)
          1  rows processed

alter system flush buffer_cache;
select /*+ NO_INMEMORY */ count(*) from sd where mdiff(m, n) > 0;

  COUNT(*)
----------
   9000000

Elapsed: 00:00:01.66

Execution Plan
----------------------------------------------------------
Plan hash value: 2551399908

---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |     1 |    10 |  5815   (3)| 00:00:01 |
|   1 |  SORT AGGREGATE    |      |     1 |    10 |            |          |
|*  2 |   TABLE ACCESS FULL| SD   |   500K|  4882K|  5815   (3)| 00:00:01 |
---------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(CASE ABS("M"-"N") WHEN 0 THEN 0 ELSE 1 END >0)


Statistics
----------------------------------------------------------
         19  recursive calls
          4  db block gets
      20750  consistent gets
      20708  physical reads
          0  redo size
        568  bytes sent via SQL*Net to client
        426  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed



alter system flush buffer_cache;
SQL> select /*+ NO_INMEMORY */ count(*) from sd where case when abs(m - n) = 0 then 0 else 1 end > 0;

  COUNT(*)
----------
   9000000

Elapsed: 00:00:01.65

Execution Plan
----------------------------------------------------------
Plan hash value: 2551399908

---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |     1 |    10 |  5815   (3)| 00:00:01 |
|   1 |  SORT AGGREGATE    |      |     1 |    10 |            |          |
|*  2 |   TABLE ACCESS FULL| SD   |   500K|  4882K|  5815   (3)| 00:00:01 |
---------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(CASE ABS("M"-"N") WHEN 0 THEN 0 ELSE 1 END >0)


Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
      20710  consistent gets
      20700  physical reads
          0  redo size
        568  bytes sent via SQL*Net to client
        457  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed


alter system flush buffer_cache;
SQL> select /*+ NO_INMEMORY */ count(*) from sd where m != n;

  COUNT(*)
----------
   9000000

Elapsed: 00:00:00.62

Execution Plan
----------------------------------------------------------
Plan hash value: 2551399908

---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |     1 |    10 |  5721   (2)| 00:00:01 |
|   1 |  SORT AGGREGATE    |      |     1 |    10 |            |          |
|*  2 |   TABLE ACCESS FULL| SD   |  9999K|    95M|  5721   (2)| 00:00:01 |
---------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("M"<>"N")


Statistics
----------------------------------------------------------
          6  recursive calls
          0  db block gets
      20716  consistent gets
      20704  physical reads
          0  redo size
        568  bytes sent via SQL*Net to client
        417  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed


create or replace function pragmadiff(m number, n number) return number
is
PRAGMA UDF;
begin
  return(case when abs(m - n) = 0 then 0 else 1 end);
end;
/

Function created.

Elapsed: 00:00:00.02

alter system flush buffer_cache;
SQL> select /*+ NO_INMEMORY */ count(*) from sd where pragmadiff(m, n) > 0;

  COUNT(*)
----------
   9000000

Elapsed: 00:00:05.98

Execution Plan
----------------------------------------------------------
Plan hash value: 2551399908

---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |     1 |    10 |  6524  (14)| 00:00:01 |
|   1 |  SORT AGGREGATE    |      |     1 |    10 |            |          |
|*  2 |   TABLE ACCESS FULL| SD   |   500K|  4882K|  6524  (14)| 00:00:01 |
---------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("PRAGMADIFF"("M","N")>0)


Statistics
----------------------------------------------------------
        179  recursive calls
          0  db block gets
      20811  consistent gets
      20761  physical reads
          0  redo size
        568  bytes sent via SQL*Net to client
        431  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          5  sorts (memory)
          0  sorts (disk)
          1  rows processed

alter system flush buffer_cache;
with FUNCTION diffonthefly (m number, n number) return number
IS 
begin
  return(case when abs(m - n) = 0 then 0 else 1 end);
end;
select /*+ NO_INMEMORY */ count(*) from sd where diffonthefly(m, n) > 0
/

  COUNT(*)
----------
   9000000

Elapsed: 00:00:06.37

Execution Plan
----------------------------------------------------------
Plan hash value: 2551399908

---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |     1 |    10 |  6524  (14)| 00:00:01 |
|   1 |  SORT AGGREGATE    |      |     1 |    10 |            |          |
|*  2 |   TABLE ACCESS FULL| SD   |   500K|  4882K|  6524  (14)| 00:00:01 |
---------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("DIFFONTHEFLY"("M","N")>0)


Statistics
----------------------------------------------------------
         40  recursive calls
          0  db block gets
      20714  consistent gets
      20701  physical reads
          0  redo size
        568  bytes sent via SQL*Net to client
        563  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed


alter system flush buffer_cache;
with FUNCTION diffontheflyudf (m number, n number) return number
IS 
PRAGMA UDF;
begin
  return(case when abs(m - n) = 0 then 0 else 1 end);
end;
select /*+ NO_INMEMORY */ count(*) from sd where diffontheflyudf(m, n) > 0
/

  COUNT(*)
----------
   9000000

Elapsed: 00:00:05.25

Execution Plan
----------------------------------------------------------
Plan hash value: 2551399908

---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |     1 |    10 |  6524  (14)| 00:00:01 |
|   1 |  SORT AGGREGATE    |      |     1 |    10 |            |          |
|*  2 |   TABLE ACCESS FULL| SD   |   500K|  4882K|  6524  (14)| 00:00:01 |
---------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("DIFFONTHEFLYUDF"("M","N")>0)


Statistics
----------------------------------------------------------
         40  recursive calls
          0  db block gets
      20714  consistent gets
      20701  physical reads
          0  redo size
        568  bytes sent via SQL*Net to client
        581  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed




