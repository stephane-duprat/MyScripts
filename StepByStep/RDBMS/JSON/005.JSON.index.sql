create table SALES_JSON_INDEX (
ID VARCHAR2(50),
sales_json CLOB,
CONSTRAINT sales_json_index_pk primary Key (id),
CONSTRAINT sales_json_index_check CHECK (sales_json IS JSON)
) tablespace SH;

create table SALES_JSON_INDEX2 (
ID VARCHAR2(50),
sales_json CLOB,
CONSTRAINT sales_json_index_pk2 primary Key (id),
CONSTRAINT sales_json_index_check2 CHECK (sales_json IS JSON)
) tablespace SH;

alter session enable parallel DML;
alter session force parallel query parallel 4;


insert /*+ APPEND NOLOGGING */
into SALES_JSON_INDEX
select * from SALES_JSON_CHECK;

commit;

insert /*+ APPEND NOLOGGING */
into SALES_JSON_INDEX2
select * from SALES_JSON_CHECK;

commit;


create index I_JSON_CUSTID on
SALES_JSON_INDEX 
(
	JSON_VALUE (sales_json,'$.CUSTID' returning NUMBER(10) error on error null on empty)
) tablespace SH;

Index created.

Elapsed: 00:00:05.33

create index I_JSON_CUSTID2 on
SALES_JSON_INDEX2 
(
	JSON_VALUE (sales_json,'$.CUSTID' returning NUMBER(10) error on error null on empty)
) tablespace SH;


SQL> select count(*) from SALES_JSON_INDEX;

  COUNT(*)
----------
   1000000

Elapsed: 00:00:00.18
SQL> 

select count(*) from SALES_JSON_INDEX2;

  COUNT(*)
----------
   1000000



select * from SALES_JSON_INDEX s
where json_value(sales_json,'$.CUSTID' returning NUMBER(10) error on error) = 397071;

select * from SALES_JSON_INDEX s where s.sales_json.CUSTID = 397071;


--- SEARCH INDEX !!!

create search index I_JSON_SEARCH on SALES_JSON_INDEX(SALES_JSON) for JSON;

Index created.

Elapsed: 00:02:44.73
SQL> 


select * from SALES_JSON_INDEX s 
where s.sales_json.PRODID = 115
and s.sales_json.CHANNELID = 4
and s.sales_json.PROMOID = 258;

ID
--------------------------------------------------
SALES_JSON
--------------------------------------------------------------------------------
77C8A45473775A3AE053030110ACE94E
{"PRODID":115,"CUSTID":1177473,"TIMEID":"2009-03-21T00:00:00","CHANNELID":4,"PRO

77C8A45129035A3AE053030110ACE94E
{"PRODID":115,"CUSTID":4166008,"TIMEID":"1995-01-11T00:00:00","CHANNELID":4,"PRO

77C8A447F49B5A3AE053030110ACE94E
{"PRODID":115,"CUSTID":2083961,"TIMEID":"1995-12-18T00:00:00","CHANNELID":4,"PRO


Elapsed: 00:00:01.05
SQL> set autotrace traceonly explain statistics
SQL> r
  1  select * from SALES_JSON_INDEX s
  2  where s.sales_json.PRODID = 115
  3  and s.sales_json.CHANNELID = 4
  4* and s.sales_json.PROMOID = 258

Elapsed: 00:00:00.58

Execution Plan
----------------------------------------------------------
Plan hash value: 3845631988

--------------------------------------------------------------------------------
----------------

| Id  | Operation		    | Name	       | Rows  | Bytes | Cost (%
CPU)| Time     |

--------------------------------------------------------------------------------
----------------

|   0 | SELECT STATEMENT	    |		       |   491 |   978K|   152
 (0)| 00:00:01 |

|   1 |  TABLE ACCESS BY INDEX ROWID| SALES_JSON_INDEX |   491 |   978K|   152
 (0)| 00:00:01 |

|*  2 |   DOMAIN INDEX		    | I_JSON_SEARCH    |       |       |     4
 (0)| 00:00:01 |

--------------------------------------------------------------------------------
----------------


Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("CTXSYS"."CONTAINS"("S"."SALES_JSON",'(sdatap(CTXSYS.JSON_SEARCH_G
ROUPNUM*

		= 115 /PRODID)) and ((sdatap(CTXSYS.JSON_SEARCH_GROUPNUM*  = 4 /
CHANNELID)) and

	      (sdatap(CTXSYS.JSON_SEARCH_GROUPNUM*  = 258 /PROMOID)))')>0)

Note
-----
   - dynamic statistics used: dynamic sampling (level=4)
   - Degree of Parallelism is 1 because of session


Statistics
----------------------------------------------------------
	279  recursive calls
	  0  db block gets
       6339  consistent gets
	  0  physical reads
	980  redo size
       2899  bytes sent via SQL*Net to client
       1512  bytes received via SQL*Net from client
	  8  SQL*Net roundtrips to/from client
	  3  sorts (memory)
	  0  sorts (disk)
	  3  rows processed


### Cruce de tablas por JSON !!!

select ch.channel_desc, c.sales_json.TOTAL_SOLD+c1.sales_json.TOTAL_SOLD
from SALES_JSON_INDEX c,
     SALES_JSON_INDEX2 c1,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
and   c1.sales_json.CHANNELID = ch.channel_id
and   c.sales_json.CUSTID = c1.sales_json.CUSTID
and   c.sales_json.CUSTID = 397071;

CHANNEL_DESC	     C.SALES_JSON.TOTAL_SOLD+C1.SALES_JSON.TOTAL_SOLD
-------------------- ------------------------------------------------
Catalog 							11376

Elapsed: 00:00:08.53

