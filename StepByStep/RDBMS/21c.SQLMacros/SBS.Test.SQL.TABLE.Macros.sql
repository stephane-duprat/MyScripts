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

--- Polymorphic views !!!

CREATE or replace FUNCTION sample(t DBMS_TF.Table_t, pct number DEFAULT 5) 
RETURN VARCHAR2 SQL_MACRO(TABLE)
AS 
BEGIN
	RETURN q'[SELECT * FROM t WHERE dbms_random.value<=sample.pct/100]';
END sample;
/

SELECT *
FROM sample(t=>demo_macro.customers, pct=>1);


create or replace function dame_cust_list (p_city IN VARCHAR2)
RETURN VARCHAR2 SQL_MACRO(TABLE)
AS
BEGIN
	return q'[select CUST_FIRST_NAME, CUST_LAST_NAME from customers where CUST_CITY = p_city]';
END dame_cust_list;
/

select * from dame_cust_list ('Leighton') where rownum < 11;

SQL> select * from dame_cust_list ('Leighton') where rownum < 11;

CUST_FIRST_NAME      CUST_LAST_NAME
-------------------- ----------------------------------------
don		     alvarez
lucas		     hartman
jermaine	     ferguson
hubert		     price
marcos		     jackson
kerry		     richardson
ronald		     parker
tyler		     hansen
damon		     graham
shawn		     chandler

10 rows selected.







