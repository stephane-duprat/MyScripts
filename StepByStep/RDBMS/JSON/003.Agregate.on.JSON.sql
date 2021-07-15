--- Agregado sobre el JSON:

desc SALES_JSON_CHECK

SQL> desc SALES_JSON_CHECK     
 Name					   Null?    Type
 ----------------------------------------- -------- ----------------------------
 ID					   NOT NULL VARCHAR2(50)
 SALES_JSON					    CLOB

select c.sales_json.TOTAL_SOLD
from SALES_JSON_CHECK c
where rownum < 11;

TOTAL_SOLD
--------------------------------------------------------------------------------
52
1200
765
5396
7347
1081
1144
3850
306
531

10 rows selected.


select sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK c;

SUM(C.SALES_JSON.TOTAL_SOLD)
----------------------------
		  2451515347

Elapsed: 00:00:03.57

select c.sales_json.CHANNELID, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK c
group by c.sales_json.CHANNELID;

CHANNELID
--------------------------------------------------------------------------------
SUM(C.SALES_JSON.TOTAL_SOLD)
----------------------------
2
		   491431757

5
		   489629350

3
		   489147053


CHANNELID
--------------------------------------------------------------------------------
SUM(C.SALES_JSON.TOTAL_SOLD)
----------------------------
4
		   490124296

9
		   491182891


Elapsed: 00:00:03.70
SQL> 

select ch.channel_desc, sum(c.sales_json.TOTAL_SOLD)
from SALES_JSON_CHECK c,
      CHANNELS ch
where c.sales_json.CHANNELID = ch.channel_id
group by ch.channel_desc;

CHANNEL_DESC	     SUM(C.SALES_JSON.TOTAL_SOLD)
-------------------- ----------------------------
Direct Sales				489147053
Tele Sales				491182891
Internet				490124296
Partners				491431757
Catalog 				489629350

Elapsed: 00:00:03.73






