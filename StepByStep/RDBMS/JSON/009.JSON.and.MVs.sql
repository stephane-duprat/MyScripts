SELECT	sales.*,
	(select JSON_OBJECTAGG (
	KEY to_char(c.CHANNEL_ID) value c.CHANNEL_CLASS || '-' || c.CHANNEL_DESC
	) as canales
	from channels c
	)
from sales
where rownum < 11;


create materialized view MV_WITH_JSON_OBJECT
-- refresh fast on commit
as
SELECT	sales.*,
	(select JSON_OBJECTAGG (
	KEY to_char(c.CHANNEL_ID) value c.CHANNEL_CLASS || '-' || c.CHANNEL_DESC
	) as canales
	from channels c
	)
from sales;
