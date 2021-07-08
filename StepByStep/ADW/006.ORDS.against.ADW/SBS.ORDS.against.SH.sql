##### As ADMIN: connect through SqlDeveloper Web Console: https://ixcsyvrmtjm8ebr-benchadwdb.adb.eu-frankfurt-1.oraclecloudapps.com/ords/admin/_sdw/?nav=worksheet 


### Create your own copy of SH schema:

create user MYOWNSH IDENTIFIED BY "AaZZ0r_cle#1";
GRANT CONNECT, resource TO MYOWNSH;
 
ALTER USER MYOWNSH QUOTA UNLIMITED ON DATA;

BEGIN
    ords_admin.enable_schema (
        p_enabled               => TRUE,
        p_schema                => 'MYOWNSH',
        p_url_mapping_type      => 'BASE_PATH',
        p_url_mapping_pattern   => 'myownsh', -- this flag says, use 'myownsh' in the URIs for MYOWNSH
        p_auto_rest_auth        => TRUE   -- this flag says, don't expose my REST APIs
    );
    COMMIT;
END;
/


#### Now connect to your schema through Sqldev web console:

https://ixcsyvrmtjm8ebr-benchadwdb.adb.eu-frankfurt-1.oraclecloudapps.com/ords/myownsh/_sdw/?nav=worksheet

### Create your own table as of SH schema tables: (9 tables)

  CREATE TABLE "MYOWNSH"."TIMES" 
   (	"TIME_ID" DATE NOT NULL ENABLE, 
	"DAY_NAME" VARCHAR2(9 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"DAY_NUMBER_IN_WEEK" NUMBER(1,0) NOT NULL ENABLE, 
	"DAY_NUMBER_IN_MONTH" NUMBER(2,0) NOT NULL ENABLE, 
	"CALENDAR_WEEK_NUMBER" NUMBER(2,0) NOT NULL ENABLE, 
	"FISCAL_WEEK_NUMBER" NUMBER(2,0) NOT NULL ENABLE, 
	"WEEK_ENDING_DAY" DATE NOT NULL ENABLE, 
	"WEEK_ENDING_DAY_ID" NUMBER NOT NULL ENABLE, 
	"CALENDAR_MONTH_NUMBER" NUMBER(2,0) NOT NULL ENABLE, 
	"FISCAL_MONTH_NUMBER" NUMBER(2,0) NOT NULL ENABLE, 
	"CALENDAR_MONTH_DESC" VARCHAR2(8 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CALENDAR_MONTH_ID" NUMBER NOT NULL ENABLE, 
	"FISCAL_MONTH_DESC" VARCHAR2(8 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"FISCAL_MONTH_ID" NUMBER NOT NULL ENABLE, 
	"DAYS_IN_CAL_MONTH" NUMBER NOT NULL ENABLE, 
	"DAYS_IN_FIS_MONTH" NUMBER NOT NULL ENABLE, 
	"END_OF_CAL_MONTH" DATE NOT NULL ENABLE, 
	"END_OF_FIS_MONTH" DATE NOT NULL ENABLE, 
	"CALENDAR_MONTH_NAME" VARCHAR2(9 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"FISCAL_MONTH_NAME" VARCHAR2(9 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CALENDAR_QUARTER_DESC" CHAR(7 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CALENDAR_QUARTER_ID" NUMBER NOT NULL ENABLE, 
	"FISCAL_QUARTER_DESC" CHAR(7 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"FISCAL_QUARTER_ID" NUMBER NOT NULL ENABLE, 
	"DAYS_IN_CAL_QUARTER" NUMBER NOT NULL ENABLE, 
	"DAYS_IN_FIS_QUARTER" NUMBER NOT NULL ENABLE, 
	"END_OF_CAL_QUARTER" DATE NOT NULL ENABLE, 
	"END_OF_FIS_QUARTER" DATE NOT NULL ENABLE, 
	"CALENDAR_QUARTER_NUMBER" NUMBER(1,0) NOT NULL ENABLE, 
	"FISCAL_QUARTER_NUMBER" NUMBER(1,0) NOT NULL ENABLE, 
	"CALENDAR_YEAR" NUMBER(4,0) NOT NULL ENABLE, 
	"CALENDAR_YEAR_ID" NUMBER NOT NULL ENABLE, 
	"FISCAL_YEAR" NUMBER(4,0) NOT NULL ENABLE, 
	"FISCAL_YEAR_ID" NUMBER NOT NULL ENABLE, 
	"DAYS_IN_CAL_YEAR" NUMBER NOT NULL ENABLE, 
	"DAYS_IN_FIS_YEAR" NUMBER NOT NULL ENABLE, 
	"END_OF_CAL_YEAR" DATE NOT NULL ENABLE, 
	"END_OF_FIS_YEAR" DATE NOT NULL ENABLE, 
	 CONSTRAINT "TIMES_PK" PRIMARY KEY ("TIME_ID") RELY DISABLE
   )  ;

   COMMENT ON COLUMN "MYOWNSH"."TIMES"."TIME_ID" IS 'primary key; day date, finest granularity, CORRECT ORDER';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."DAY_NAME" IS 'Monday to Sunday, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."DAY_NUMBER_IN_WEEK" IS '1 to 7, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."DAY_NUMBER_IN_MONTH" IS '1 to 31, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."CALENDAR_WEEK_NUMBER" IS '1 to 53, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."FISCAL_WEEK_NUMBER" IS '1 to 53, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."WEEK_ENDING_DAY" IS 'date of last day in week, CORRECT ORDER';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."CALENDAR_MONTH_NUMBER" IS '1 to 12, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."FISCAL_MONTH_NUMBER" IS '1 to 12, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."CALENDAR_MONTH_DESC" IS 'e.g. 1998-01, CORRECT ORDER';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."FISCAL_MONTH_DESC" IS 'e.g. 1998-01, CORRECT ORDER';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."DAYS_IN_CAL_MONTH" IS 'e.g. 28,31, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."DAYS_IN_FIS_MONTH" IS 'e.g. 25,32, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."END_OF_CAL_MONTH" IS 'last day of calendar month';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."END_OF_FIS_MONTH" IS 'last day of fiscal month';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."CALENDAR_MONTH_NAME" IS 'January to December, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."FISCAL_MONTH_NAME" IS 'January to December, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."CALENDAR_QUARTER_DESC" IS 'e.g. 1998-Q1, CORRECT ORDER';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."FISCAL_QUARTER_DESC" IS 'e.g. 1999-Q3, CORRECT ORDER';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."DAYS_IN_CAL_QUARTER" IS 'e.g. 88,90, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."DAYS_IN_FIS_QUARTER" IS 'e.g. 88,90, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."END_OF_CAL_QUARTER" IS 'last day of calendar quarter';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."END_OF_FIS_QUARTER" IS 'last day of fiscal quarter';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."CALENDAR_QUARTER_NUMBER" IS '1 to 4, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."FISCAL_QUARTER_NUMBER" IS '1 to 4, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."CALENDAR_YEAR" IS 'e.g. 1999, CORRECT ORDER';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."FISCAL_YEAR" IS 'e.g. 1999, CORRECT ORDER';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."DAYS_IN_CAL_YEAR" IS '365,366 repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."DAYS_IN_FIS_YEAR" IS 'e.g. 355,364, repeating';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."END_OF_CAL_YEAR" IS 'last day of cal year';
   COMMENT ON COLUMN "MYOWNSH"."TIMES"."END_OF_FIS_YEAR" IS 'last day of fiscal year';
   COMMENT ON TABLE "MYOWNSH"."TIMES"  IS 'Time dimension table to support multiple hierarchies and materialized views';

  CREATE TABLE "MYOWNSH"."SUPPLEMENTARY_DEMOGRAPHICS" 
   (	"CUST_ID" NUMBER NOT NULL ENABLE, 
	"EDUCATION" VARCHAR2(21 BYTE) COLLATE "USING_NLS_COMP", 
	"OCCUPATION" VARCHAR2(21 BYTE) COLLATE "USING_NLS_COMP", 
	"HOUSEHOLD_SIZE" VARCHAR2(21 BYTE) COLLATE "USING_NLS_COMP", 
	"YRS_RESIDENCE" NUMBER, 
	"AFFINITY_CARD" NUMBER(10,0), 
	"BULK_PACK_DISKETTES" NUMBER(10,0), 
	"FLAT_PANEL_MONITOR" NUMBER(10,0), 
	"HOME_THEATER_PACKAGE" NUMBER(10,0), 
	"BOOKKEEPING_APPLICATION" NUMBER(10,0), 
	"PRINTER_SUPPLIES" NUMBER(10,0), 
	"Y_BOX_GAMES" NUMBER(10,0), 
	"OS_DOC_SET_KANJI" NUMBER(10,0), 
	"COMMENTS" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	 CONSTRAINT "SUPP_DEMO_PK" PRIMARY KEY ("CUST_ID") RELY DISABLE
   ) ;

  CREATE TABLE "MYOWNSH"."CHANNELS" 
   (	"CHANNEL_ID" NUMBER NOT NULL ENABLE, 
	"CHANNEL_DESC" VARCHAR2(20 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CHANNEL_CLASS" VARCHAR2(20 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CHANNEL_CLASS_ID" NUMBER NOT NULL ENABLE, 
	"CHANNEL_TOTAL" VARCHAR2(13 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CHANNEL_TOTAL_ID" NUMBER NOT NULL ENABLE, 
	 CONSTRAINT "CHANNELS_PK" PRIMARY KEY ("CHANNEL_ID") RELY DISABLE
   );

   COMMENT ON COLUMN "MYOWNSH"."CHANNELS"."CHANNEL_ID" IS 'primary key column';
   COMMENT ON COLUMN "MYOWNSH"."CHANNELS"."CHANNEL_DESC" IS 'e.g. telesales, internet, catalog';
   COMMENT ON COLUMN "MYOWNSH"."CHANNELS"."CHANNEL_CLASS" IS 'e.g. direct, indirect';
   COMMENT ON TABLE "MYOWNSH"."CHANNELS"  IS 'small dimension table';


  CREATE TABLE "MYOWNSH"."COUNTRIES" 
   (	"COUNTRY_ID" NUMBER NOT NULL ENABLE, 
	"COUNTRY_ISO_CODE" CHAR(2 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"COUNTRY_NAME" VARCHAR2(40 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"COUNTRY_SUBREGION" VARCHAR2(30 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"COUNTRY_SUBREGION_ID" NUMBER NOT NULL ENABLE, 
	"COUNTRY_REGION" VARCHAR2(20 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"COUNTRY_REGION_ID" NUMBER NOT NULL ENABLE, 
	"COUNTRY_TOTAL" VARCHAR2(11 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"COUNTRY_TOTAL_ID" NUMBER NOT NULL ENABLE, 
	"COUNTRY_NAME_HIST" VARCHAR2(40 BYTE) COLLATE "USING_NLS_COMP", 
	 CONSTRAINT "COUNTRIES_PK" PRIMARY KEY ("COUNTRY_ID") RELY DISABLE
   );

   COMMENT ON COLUMN "MYOWNSH"."COUNTRIES"."COUNTRY_ID" IS 'primary key';
   COMMENT ON COLUMN "MYOWNSH"."COUNTRIES"."COUNTRY_NAME" IS 'country name';
   COMMENT ON COLUMN "MYOWNSH"."COUNTRIES"."COUNTRY_SUBREGION" IS 'e.g. Western Europe, to allow hierarchies';
   COMMENT ON COLUMN "MYOWNSH"."COUNTRIES"."COUNTRY_REGION" IS 'e.g. Europe, Asia';
   COMMENT ON TABLE "MYOWNSH"."COUNTRIES"  IS 'country dimension table (snowflake)';


  CREATE TABLE "MYOWNSH"."CUSTOMERS" 
   (	"CUST_ID" NUMBER NOT NULL ENABLE, 
	"CUST_FIRST_NAME" VARCHAR2(20 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CUST_LAST_NAME" VARCHAR2(40 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CUST_GENDER" CHAR(1 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CUST_YEAR_OF_BIRTH" NUMBER(4,0) NOT NULL ENABLE, 
	"CUST_MARITAL_STATUS" VARCHAR2(20 BYTE) COLLATE "USING_NLS_COMP", 
	"CUST_STREET_ADDRESS" VARCHAR2(40 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CUST_POSTAL_CODE" VARCHAR2(10 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CUST_CITY" VARCHAR2(30 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CUST_CITY_ID" NUMBER NOT NULL ENABLE, 
	"CUST_STATE_PROVINCE" VARCHAR2(40 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CUST_STATE_PROVINCE_ID" NUMBER NOT NULL ENABLE, 
	"COUNTRY_ID" NUMBER NOT NULL ENABLE, 
	"CUST_MAIN_PHONE_NUMBER" VARCHAR2(25 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CUST_INCOME_LEVEL" VARCHAR2(30 BYTE) COLLATE "USING_NLS_COMP", 
	"CUST_CREDIT_LIMIT" NUMBER, 
	"CUST_EMAIL" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP", 
	"CUST_TOTAL" VARCHAR2(14 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CUST_TOTAL_ID" NUMBER NOT NULL ENABLE, 
	"CUST_SRC_ID" NUMBER, 
	"CUST_EFF_FROM" DATE, 
	"CUST_EFF_TO" DATE, 
	"CUST_VALID" VARCHAR2(1 BYTE) COLLATE "USING_NLS_COMP", 
	 CONSTRAINT "CUSTOMERS_PK" PRIMARY KEY ("CUST_ID") RELY DISABLE, 
	 CONSTRAINT "CUSTOMERS_COUNTRY_FK" FOREIGN KEY ("COUNTRY_ID")
	  REFERENCES "MYOWNSH"."COUNTRIES" ("COUNTRY_ID") RELY DISABLE
   );

   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."CUST_ID" IS 'primary key';
   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."CUST_FIRST_NAME" IS 'first name of the customer';
   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."CUST_LAST_NAME" IS 'last name of the customer';
   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."CUST_GENDER" IS 'gender; low cardinality attribute';
   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."CUST_YEAR_OF_BIRTH" IS 'customer year of birth';
   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."CUST_MARITAL_STATUS" IS 'customer marital status; low cardinality attribute';
   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."CUST_STREET_ADDRESS" IS 'customer street address';
   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."CUST_POSTAL_CODE" IS 'postal code of the customer';
   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."CUST_CITY" IS 'city where the customer lives';
   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."CUST_STATE_PROVINCE" IS 'customer geography: state or province';
   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."COUNTRY_ID" IS 'foreign key to the countries table (snowflake)';
   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."CUST_MAIN_PHONE_NUMBER" IS 'customer main phone number';
   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."CUST_INCOME_LEVEL" IS 'customer income level';
   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."CUST_CREDIT_LIMIT" IS 'customer credit limit';
   COMMENT ON COLUMN "MYOWNSH"."CUSTOMERS"."CUST_EMAIL" IS 'customer email id';
   COMMENT ON TABLE "MYOWNSH"."CUSTOMERS"  IS 'dimension table';


  CREATE TABLE "MYOWNSH"."PRODUCTS" 
   (	"PROD_ID" NUMBER(6,0) NOT NULL ENABLE, 
	"PROD_NAME" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PROD_DESC" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PROD_SUBCATEGORY" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PROD_SUBCATEGORY_ID" NUMBER NOT NULL ENABLE, 
	"PROD_SUBCATEGORY_DESC" VARCHAR2(2000 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PROD_CATEGORY" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PROD_CATEGORY_ID" NUMBER NOT NULL ENABLE, 
	"PROD_CATEGORY_DESC" VARCHAR2(2000 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PROD_WEIGHT_CLASS" NUMBER(3,0) NOT NULL ENABLE, 
	"PROD_UNIT_OF_MEASURE" VARCHAR2(20 BYTE) COLLATE "USING_NLS_COMP", 
	"PROD_PACK_SIZE" VARCHAR2(30 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"SUPPLIER_ID" NUMBER(6,0) NOT NULL ENABLE, 
	"PROD_STATUS" VARCHAR2(20 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PROD_LIST_PRICE" NUMBER(8,2) NOT NULL ENABLE, 
	"PROD_MIN_PRICE" NUMBER(8,2) NOT NULL ENABLE, 
	"PROD_TOTAL" VARCHAR2(13 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PROD_TOTAL_ID" NUMBER NOT NULL ENABLE, 
	"PROD_SRC_ID" NUMBER, 
	"PROD_EFF_FROM" DATE, 
	"PROD_EFF_TO" DATE, 
	"PROD_VALID" VARCHAR2(1 BYTE) COLLATE "USING_NLS_COMP", 
	 CONSTRAINT "PRODUCTS_PK" PRIMARY KEY ("PROD_ID") RELY DISABLE
   );

   COMMENT ON COLUMN "MYOWNSH"."PRODUCTS"."PROD_ID" IS 'primary key';
   COMMENT ON COLUMN "MYOWNSH"."PRODUCTS"."PROD_NAME" IS 'product name';
   COMMENT ON COLUMN "MYOWNSH"."PRODUCTS"."PROD_DESC" IS 'product description';
   COMMENT ON COLUMN "MYOWNSH"."PRODUCTS"."PROD_SUBCATEGORY" IS 'product subcategory';
   COMMENT ON COLUMN "MYOWNSH"."PRODUCTS"."PROD_SUBCATEGORY_DESC" IS 'product subcategory description';
   COMMENT ON COLUMN "MYOWNSH"."PRODUCTS"."PROD_CATEGORY" IS 'product category';
   COMMENT ON COLUMN "MYOWNSH"."PRODUCTS"."PROD_CATEGORY_DESC" IS 'product category description';
   COMMENT ON COLUMN "MYOWNSH"."PRODUCTS"."PROD_WEIGHT_CLASS" IS 'product weight class';
   COMMENT ON COLUMN "MYOWNSH"."PRODUCTS"."PROD_UNIT_OF_MEASURE" IS 'product unit of measure';
   COMMENT ON COLUMN "MYOWNSH"."PRODUCTS"."PROD_PACK_SIZE" IS 'product package size';
   COMMENT ON COLUMN "MYOWNSH"."PRODUCTS"."SUPPLIER_ID" IS 'this column';
   COMMENT ON COLUMN "MYOWNSH"."PRODUCTS"."PROD_STATUS" IS 'product status';
   COMMENT ON COLUMN "MYOWNSH"."PRODUCTS"."PROD_LIST_PRICE" IS 'product list price';
   COMMENT ON COLUMN "MYOWNSH"."PRODUCTS"."PROD_MIN_PRICE" IS 'product minimum price';
   COMMENT ON TABLE "MYOWNSH"."PRODUCTS"  IS 'dimension table';


  CREATE TABLE "MYOWNSH"."PROMOTIONS" 
   (	"PROMO_ID" NUMBER(6,0) NOT NULL ENABLE, 
	"PROMO_NAME" VARCHAR2(30 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PROMO_SUBCATEGORY" VARCHAR2(30 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PROMO_SUBCATEGORY_ID" NUMBER NOT NULL ENABLE, 
	"PROMO_CATEGORY" VARCHAR2(30 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PROMO_CATEGORY_ID" NUMBER NOT NULL ENABLE, 
	"PROMO_COST" NUMBER(10,2) NOT NULL ENABLE, 
	"PROMO_BEGIN_DATE" DATE NOT NULL ENABLE, 
	"PROMO_END_DATE" DATE NOT NULL ENABLE, 
	"PROMO_TOTAL" VARCHAR2(15 BYTE) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"PROMO_TOTAL_ID" NUMBER NOT NULL ENABLE, 
	 CONSTRAINT "PROMO_PK" PRIMARY KEY ("PROMO_ID") RELY DISABLE
   ) ;

   COMMENT ON COLUMN "MYOWNSH"."PROMOTIONS"."PROMO_ID" IS 'primary key column';
   COMMENT ON COLUMN "MYOWNSH"."PROMOTIONS"."PROMO_NAME" IS 'promotion description';
   COMMENT ON COLUMN "MYOWNSH"."PROMOTIONS"."PROMO_SUBCATEGORY" IS 'enables to investigate promotion hierarchies';
   COMMENT ON COLUMN "MYOWNSH"."PROMOTIONS"."PROMO_CATEGORY" IS 'promotion category';
   COMMENT ON COLUMN "MYOWNSH"."PROMOTIONS"."PROMO_COST" IS 'promotion cost, to do promotion effect calculations';
   COMMENT ON COLUMN "MYOWNSH"."PROMOTIONS"."PROMO_BEGIN_DATE" IS 'promotion begin day';
   COMMENT ON COLUMN "MYOWNSH"."PROMOTIONS"."PROMO_END_DATE" IS 'promotion end day';
   COMMENT ON TABLE "MYOWNSH"."PROMOTIONS"  IS 'dimension table without a PK-FK relationship with the facts table, to show outer join functionality';


  CREATE TABLE "MYOWNSH"."SALES" 
   (	"PROD_ID" NUMBER NOT NULL ENABLE, 
	"CUST_ID" NUMBER NOT NULL ENABLE, 
	"TIME_ID" DATE NOT NULL ENABLE, 
	"CHANNEL_ID" NUMBER NOT NULL ENABLE, 
	"PROMO_ID" NUMBER NOT NULL ENABLE, 
	"QUANTITY_SOLD" NUMBER(10,2) NOT NULL ENABLE, 
	"AMOUNT_SOLD" NUMBER(10,2) NOT NULL ENABLE, 
	 CONSTRAINT "SALES_PROMO_FK" FOREIGN KEY ("PROMO_ID")
	  REFERENCES "MYOWNSH"."PROMOTIONS" ("PROMO_ID") RELY DISABLE, 
	 CONSTRAINT "SALES_PRODUCT_FK" FOREIGN KEY ("PROD_ID")
	  REFERENCES "MYOWNSH"."PRODUCTS" ("PROD_ID") RELY DISABLE, 
	 CONSTRAINT "SALES_CUSTOMER_FK" FOREIGN KEY ("CUST_ID")
	  REFERENCES "MYOWNSH"."CUSTOMERS" ("CUST_ID") RELY DISABLE, 
	 CONSTRAINT "SALES_CHANNEL_FK" FOREIGN KEY ("CHANNEL_ID")
	  REFERENCES "MYOWNSH"."CHANNELS" ("CHANNEL_ID") RELY DISABLE, 
	 CONSTRAINT "SALES_TIME_FK" FOREIGN KEY ("TIME_ID")
	  REFERENCES "MYOWNSH"."TIMES" ("TIME_ID") RELY DISABLE
   )  ;

   COMMENT ON COLUMN "MYOWNSH"."SALES"."PROD_ID" IS 'FK to the products dimension table';
   COMMENT ON COLUMN "MYOWNSH"."SALES"."CUST_ID" IS 'FK to the customers dimension table';
   COMMENT ON COLUMN "MYOWNSH"."SALES"."TIME_ID" IS 'FK to the times dimension table';
   COMMENT ON COLUMN "MYOWNSH"."SALES"."CHANNEL_ID" IS 'FK to the channels dimension table';
   COMMENT ON COLUMN "MYOWNSH"."SALES"."PROMO_ID" IS 'promotion identifier, without FK constraint (intentionally) to show outer join optimization';
   COMMENT ON COLUMN "MYOWNSH"."SALES"."QUANTITY_SOLD" IS 'product quantity sold with the transaction';
   COMMENT ON COLUMN "MYOWNSH"."SALES"."AMOUNT_SOLD" IS 'invoiced amount to the customer';
   COMMENT ON TABLE "MYOWNSH"."SALES"  IS 'facts table, without a primary key; all rows are uniquely identified by the combination of all foreign keys';


  CREATE TABLE "MYOWNSH"."COSTS" 
   (	"PROD_ID" NUMBER NOT NULL ENABLE, 
	"TIME_ID" DATE NOT NULL ENABLE, 
	"PROMO_ID" NUMBER NOT NULL ENABLE, 
	"CHANNEL_ID" NUMBER NOT NULL ENABLE, 
	"UNIT_COST" NUMBER(10,2) NOT NULL ENABLE, 
	"UNIT_PRICE" NUMBER(10,2) NOT NULL ENABLE, 
	 CONSTRAINT "COSTS_PROMO_FK" FOREIGN KEY ("PROMO_ID")
	  REFERENCES "MYOWNSH"."PROMOTIONS" ("PROMO_ID") RELY DISABLE, 
	 CONSTRAINT "COSTS_CHANNEL_FK" FOREIGN KEY ("CHANNEL_ID")
	  REFERENCES "MYOWNSH"."CHANNELS" ("CHANNEL_ID") RELY DISABLE, 
	 CONSTRAINT "COSTS_PRODUCT_FK" FOREIGN KEY ("PROD_ID")
	  REFERENCES "MYOWNSH"."PRODUCTS" ("PROD_ID") RELY DISABLE, 
	 CONSTRAINT "COSTS_TIME_FK" FOREIGN KEY ("TIME_ID")
	  REFERENCES "MYOWNSH"."TIMES" ("TIME_ID") RELY DISABLE
   );


#### INSERT DATA in your own tables:

insert into "MYOWNSH"."TIMES" select * from "SH"."TIMES";
commit;
insert into "MYOWNSH"."SUPPLEMENTARY_DEMOGRAPHICS" select * from "SH"."SUPPLEMENTARY_DEMOGRAPHICS";
commit;
insert into "MYOWNSH"."CHANNELS" select * from "SH"."CHANNELS";
commit;
insert into "MYOWNSH"."COUNTRIES" select * from "SH"."COUNTRIES"
commit;
insert into "MYOWNSH"."CUSTOMERS" select * from "SH"."CUSTOMERS"
commit;
insert into "MYOWNSH"."PRODUCTS" select * from "SH"."PRODUCTS"
commit;
insert into "MYOWNSH"."PROMOTIONS" select * from "SH"."PROMOTIONS"
commit;
insert into "MYOWNSH"."SALES" select * from "SH"."SALES"
commit;
insert into "MYOWNSH"."COSTS" select * from "SH"."COSTS"
commit;


### Publish MYOWNSH's tables for REST access

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MYOWNSH',
                       p_object => 'TIMES',
                       p_object_type => 'TABLE',
                       p_object_alias => 'times',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MYOWNSH',
                       p_object => 'SUPPLEMENTARY_DEMOGRAPHICS',
                       p_object_type => 'TABLE',
                       p_object_alias => 'supdemo',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MYOWNSH',
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
                       p_schema => 'MYOWNSH',
                       p_object => 'COUNTRIES',
                       p_object_type => 'TABLE',
                       p_object_alias => 'countries',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MYOWNSH',
                       p_object => 'CUSTOMERS',
                       p_object_type => 'TABLE',
                       p_object_alias => 'customers',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MYOWNSH',
                       p_object => 'PRODUCTS',
                       p_object_type => 'TABLE',
                       p_object_alias => 'products',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/


DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MYOWNSH',
                       p_object => 'PROMOTIONS',
                       p_object_type => 'TABLE',
                       p_object_alias => 'promotions',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'MYOWNSH',
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
                       p_schema => 'MYOWNSH',
                       p_object => 'COSTS',
                       p_object_type => 'TABLE',
                       p_object_alias => 'costs',
                       p_auto_rest_auth => FALSE);

    commit;

END;
/

### Now you can use simple defaults URL to access data:

### Retrive all channels from channels table:

https://ixcsyvrmtjm8ebr-benchadwdb.adb.eu-frankfurt-1.oraclecloudapps.com/ords/myownsh/channels

### Retrieve channel ID=9 from channels table:

https://ixcsyvrmtjm8ebr-benchadwdb.adb.eu-frankfurt-1.oraclecloudapps.com/ords/myownsh/channels/9

### Link a REST API to SQL query

BEGIN
  ORDS.define_service(
    p_module_name    => 'analytics',
    p_base_path      => 'bi/',
    p_pattern        => 'promotions/',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'SELECT count(*) FROM myownsh.promotions',
    p_items_per_page => 0);
    
  COMMIT;
END;
/

https://ixcsyvrmtjm8ebr-benchadwdb.adb.eu-frankfurt-1.oraclecloudapps.com/ords/myownsh/bi/promotions

### Query with Bind variable

BEGIN
  ORDS.define_service(
    p_module_name    => 'salesreporting',
    p_base_path      => 'salesrep/',
    p_pattern        => 'sales/:mydate',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'SELECT sum(amount_sold) FROM myownsh.sales where time_id = to_date(:mydate,''YYYY-MM-DD'')',
    p_items_per_page => 0);
    
  COMMIT;
END;
/


https://ixcsyvrmtjm8ebr-benchadwdb.adb.eu-frankfurt-1.oraclecloudapps.com/ords/myownsh/salesrep/sales/1998-01-28


#### Create a sales order:

CREATE OR REPLACE PROCEDURE create_sales (
 P_PROD_ID	sales.prod_id%TYPE,
 P_CUST_ID	sales.cust_id%TYPE,
 P_TIME_ID	VARCHAR2,
 P_CHANNEL_ID	sales.CHANNEL_ID%TYPE,
 P_PROMO_ID	sales.PROMO_ID%TYPE,
 P_QUANTITY_SOLD	sales.QUANTITY_SOLD%TYPE,
 P_AMOUNT_SOLD  sales.AMOUNT_SOLD%TYPE
)
AS
BEGIN
  INSERT INTO sales (PROD_ID, CUST_ID, TIME_ID, CHANNEL_ID, PROMO_ID, QUANTITY_SOLD, AMOUNT_SOLD )
  VALUES (
 P_PROD_ID,
 P_CUST_ID,
 to_date(P_TIME_ID,'YYYY-MM-DD HH24:MI:SS'),
 P_CHANNEL_ID,
 P_PROMO_ID,
 P_QUANTITY_SOLD,
 P_AMOUNT_SOLD);
EXCEPTION
  WHEN OTHERS THEN
    HTP.print(SQLERRM);
END create_sales;
/

BEGIN
  ORDS.define_module(
    p_module_name    => 'salesmgt',
    p_base_path      => 'cresale/',
    p_items_per_page => 0);

  ORDS.define_template(
   p_module_name    => 'salesmgt',
   p_pattern        => 'sales/');

  ORDS.define_handler(
    p_module_name    => 'salesmgt',
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
 P_AMOUNT_SOLD => :amountsold);
 END;',
    p_items_per_page => 0);
commit;
  END;
/

### Create a JSON file with the new order data:

{
  "prodid": "132",
  "custid": "1684090",
  "timeid": "2018-03-28 00:00:00",
  "channelid": "9",
  "promoid": "419",
  "qtysold": "34",
  "amountsold": "1000"
}

curl -i -X POST --data-binary @cre.sales.order.json -H "Content-Type: application/json" https://ixcsyvrmtjm8ebr-benchadwdb.adb.eu-frankfurt-1.oraclecloudapps.com/ords/myownsh/cresale/sales/

Check the new sales order:

https://ixcsyvrmtjm8ebr-benchadwdb.adb.eu-frankfurt-1.oraclecloudapps.com/ords/myownsh/salesrep/sales/2018-03-28


