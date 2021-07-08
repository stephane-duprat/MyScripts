
COLUMN dbid NEW_VALUE _dbid NOPRINT
select dbid from v$database;
COLUMN beginsnapid NEW_VALUE _beginsnapid NOPRINT
select max(snap_id)-1 beginsnapid from dba_hist_snapshot where dbid = &_dbid;
COLUMN endsnapid NEW_VALUE _endsnapid NOPRINT
select max(snap_id) endsnapid from dba_hist_snapshot where dbid = &_dbid;
COLUMN instancenumber NEW_VALUE _instnumber NOPRINT
select instance_number instancenumber from v$instance;
 
col event format a35 heading "Event"
col waits format 999,999,990 heading "Waits"
col time format 999,999,990 heading "Time (s)"
col avgwt format 9990 heading "Avg|wait|(ms)"
col pctwtt format 9,999.9 heading "% DB|time"
col wait_class format a15 heading "Wait Class"
 
SELECT EVENT,
       WAITS,
       TIME,
       DECODE(WAITS,
              NULL,
              TO_NUMBER(NULL),
              0,
              TO_NUMBER(NULL),
              TIME / WAITS * 1000) AVGWT,
       PCTWTT,
       WAIT_CLASS
  FROM (SELECT EVENT, WAITS, TIME, PCTWTT, WAIT_CLASS
          FROM (SELECT E.EVENT_NAME EVENT,
                       E.TOTAL_WAITS - NVL(B.TOTAL_WAITS, 0) WAITS,
                       (E.TIME_WAITED_MICRO - NVL(B.TIME_WAITED_MICRO, 0)) /
                       1000000 TIME,
                       100 *
                       (E.TIME_WAITED_MICRO - NVL(B.TIME_WAITED_MICRO, 0)) /
                       ((SELECT sum(value)
                           FROM DBA_HIST_SYS_TIME_MODEL e
                          WHERE e.SNAP_ID = &_endsnapid
                            AND e.DBID = &_dbid
                            AND e.INSTANCE_NUMBER = &_instnumber
                            AND e.STAT_NAME = 'DB time') -
                       (SELECT sum(value)
                           FROM DBA_HIST_SYS_TIME_MODEL b
                          WHERE b.SNAP_ID = &_beginsnapid
                            AND b.DBID = &_dbid
                            AND b.INSTANCE_NUMBER = &_instnumber
                            AND b.STAT_NAME = 'DB time')) PCTWTT,
                       E.WAIT_CLASS WAIT_CLASS
                  FROM DBA_HIST_SYSTEM_EVENT B, DBA_HIST_SYSTEM_EVENT E
                 WHERE B.SNAP_ID(+) = &_beginsnapid
                   AND E.SNAP_ID = &_endsnapid
                   AND B.DBID(+) = &_dbid
                   AND E.DBID = &_dbid
                   AND B.INSTANCE_NUMBER(+) = &_instnumber
                   AND E.INSTANCE_NUMBER = &_instnumber
                   AND B.EVENT_ID(+) = E.EVENT_ID
                   AND E.TOTAL_WAITS > NVL(B.TOTAL_WAITS, 0)
                   AND E.WAIT_CLASS != 'Idle'
                UNION ALL
                SELECT 'CPU time' EVENT,
                       TO_NUMBER(NULL) WAITS,
                       ((SELECT sum(value)
                           FROM DBA_HIST_SYS_TIME_MODEL e
                          WHERE e.SNAP_ID = &_endsnapid
                            AND e.DBID = &_dbid
                            AND e.INSTANCE_NUMBER = &_instnumber
                            AND e.STAT_NAME = 'DB CPU') -
                       (SELECT sum(value)
                           FROM DBA_HIST_SYS_TIME_MODEL b
                          WHERE b.SNAP_ID = &_beginsnapid
                            AND b.DBID = &_dbid
                            AND b.INSTANCE_NUMBER = &_instnumber
                            AND b.STAT_NAME = 'DB CPU')) / 1000000 TIME,
                       100 * ((SELECT sum(value)
                                 FROM DBA_HIST_SYS_TIME_MODEL e
                                WHERE e.SNAP_ID = &_endsnapid
                                  AND e.DBID = &_dbid
                                  AND e.INSTANCE_NUMBER = &_instnumber
                                  AND e.STAT_NAME = 'DB CPU') -
                       (SELECT sum(value)
                                 FROM DBA_HIST_SYS_TIME_MODEL b
                                WHERE b.SNAP_ID = &_beginsnapid
                                  AND b.DBID = &_dbid
                                  AND b.INSTANCE_NUMBER = &_instnumber
                                  AND b.STAT_NAME = 'DB CPU')) /
                       ((SELECT sum(value)
                           FROM DBA_HIST_SYS_TIME_MODEL e
                          WHERE e.SNAP_ID = &_endsnapid
                            AND e.DBID = &&_dbid
                            AND e.INSTANCE_NUMBER = &_instnumber
                            AND e.STAT_NAME = 'DB time') -
                       (SELECT sum(value)
                           FROM DBA_HIST_SYS_TIME_MODEL b
                          WHERE b.SNAP_ID = &_beginsnapid
                            AND b.DBID = &_dbid
                            AND b.INSTANCE_NUMBER = &_instnumber
                            AND b.STAT_NAME = 'DB time')) PCTWTT,
                       NULL WAIT_CLASS
                  from dual
                 WHERE ((SELECT sum(value)
                           FROM DBA_HIST_SYS_TIME_MODEL e
                          WHERE e.SNAP_ID = &_endsnapid
                            AND e.DBID = &_dbid
                            AND e.INSTANCE_NUMBER = &_instnumber
                            AND e.STAT_NAME = 'DB CPU') -
                       (SELECT sum(value)
                           FROM DBA_HIST_SYS_TIME_MODEL b
                          WHERE b.SNAP_ID = &_beginsnapid
                            AND b.DBID = &_dbid
                            AND b.INSTANCE_NUMBER = &_instnumber
                            AND b.STAT_NAME = 'DB CPU')) > 0)
         ORDER BY TIME DESC, WAITS DESC)
 WHERE ROWNUM <= 5;
