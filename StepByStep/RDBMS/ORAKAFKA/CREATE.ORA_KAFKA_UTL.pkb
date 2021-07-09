
Unwrap It!

Unwrap More Code

    1 PACKAGE BODY ORA_KAFKA_UTL
    2 IS
    3 
    4   
    5   
    6   
    7   
    8 
    9 
   10 
   11   FUNCTION CREATE_LOCATION_FILE_NAME(P_CLUSTER_NAME        IN VARCHAR2,
   12                                      P_GROUP_ID            IN VARCHAR2,
   13                                      P_TOPIC_NAME          IN VARCHAR2,
   14                                      P_PARTITION_ID        IN INTEGER)
   15   RETURN VARCHAR2;
   16 
   17   
   18 
   19 
   20 
   21 
   22 
   23 
   24 
   25 
   26 
   27 
   28 
   29 
   30 
   31 
   32   PROCEDURE CREATE_STREAM_LOCATION_FILE(P_CLUSTER_NAME        IN VARCHAR2, 
   33                                         P_GROUP_ID            IN VARCHAR2,
   34                                         P_TOPIC_NAME          IN VARCHAR2,
   35                                         P_TOPIC_RECORD_FORMAT IN VARCHAR2,
   36                                         P_TOPIC_FIELD_DELIM   IN VARCHAR2,
   37                                         P_TOPIC_RECORD_DELIM  IN VARCHAR2,
   38                                         P_PARTITION_ID        IN INTEGER,
   39                                         P_BOOTSTRAP_SERVERS   IN VARCHAR2,
   40                                         P_FETCH_MAX_BYTES     IN INTEGER,
   41                                         P_LOCATION_DIR        IN VARCHAR2); 
   42                                        
   43 
   44   
   45 
   46 
   47 
   48 
   49 
   50   PROCEDURE DISABLE_STATS(P_TABLE_NAME IN VARCHAR2);
   51 
   52 
   53   
   54 
   55 
   56 
   57 
   58 
   59 
   60 
   61 
   62   PROCEDURE GET_ORAKAFKA_DIRECTORIES(P_CLUSTER_NAME IN VARCHAR2,
   63                                      P_LOCATION_DIR OUT VARCHAR2,
   64                                      P_DEFAULT_DIR  OUT VARCHAR2,
   65                                      P_CLUSTER_CONF_DIR OUT VARCHAR2);
   66   
   67 
   68 
   69 
   70 
   71 
   72 
   73 
   74 
   75 
   76 
   77 
   78 
   79   PROCEDURE RAISE_MISSING_CGT_EXCEPTION(P_CLUSTER_NAME IN VARCHAR2,
   80                                         P_GROUP_NAME   IN VARCHAR2,
   81                                         P_TOPIC_NAME   IN VARCHAR2);
   82 
   83   
   84 
   85 
   86 
   87 
   88   FUNCTION CONVERT_TO(INPUT       VARCHAR2,
   89                      ESCAPESPACE BOOLEAN) RETURN VARCHAR2;
   90 
   91   
   92 
   93 
   94 
   95 
   96 
   97 
   98 
   99   FUNCTION CONVERT_FROM(INPUT       NVARCHAR2, 
  100                        BIDX        PLS_INTEGER,
  101                        EIDX        PLS_INTEGER) RETURN VARCHAR2;
  102   
  103   TB    CONSTANT CHAR(1) := CHR(9);  
  104   NL    CONSTANT CHAR(1) := CHR(10); 
  105   FF    CONSTANT CHAR(1) := CHR(12); 
  106   CR    CONSTANT CHAR(1) := CHR(13); 
  107 
  108 
  109   
  110   FUNCTION MAX_VARCHAR2_SIZE RETURN INTEGER;
  111 
  112   
  113   MAX_VARCHAR2_LEN INTEGER := MAX_VARCHAR2_SIZE();
  114 
  115   
  116   
  117   
  118   
  119 
  120   
  121   
  122   
  123 
  124   
  125 
  126 
  127 
  128 
  129   FUNCTION CONVERT_TO(INPUT       VARCHAR2,
  130                       ESCAPESPACE BOOLEAN)
  131   RETURN VARCHAR2
  132   IS
  133    LEN    CONSTANT PLS_INTEGER := NVL(LENGTH(INPUT), 0);
  134    OUTPUT VARCHAR2(2000) := NULL;
  135    C      CHAR(1);
  136   BEGIN
  137    FOR I IN 1..LEN  LOOP
  138      C := SUBSTR(INPUT, I, 1);
  139      
  140      IF(C > '=') AND (C <= '~') THEN
  141        OUTPUT := OUTPUT || C;
  142        IF(C = '\') THEN 
  143          OUTPUT := OUTPUT || '\';
  144        END IF;
  145        CONTINUE;
  146      END IF;
  147      CASE C
  148        WHEN ' ' THEN 
  149          BEGIN 
  150            IF (I = 1 OR ESCAPESPACE) THEN 
  151              OUTPUT := OUTPUT || '\ '; 
  152            ELSE
  153              OUTPUT := OUTPUT || ' ';
  154            END IF;
  155          END; 
  156        WHEN TB  THEN OUTPUT := OUTPUT || '\t';
  157        WHEN NL  THEN OUTPUT := OUTPUT || '\n';
  158        WHEN CR  THEN OUTPUT := OUTPUT || '\r';
  159        WHEN FF  THEN OUTPUT := OUTPUT || '\f';
  160        WHEN '=' THEN OUTPUT := OUTPUT || '\=';
  161        WHEN ':' THEN OUTPUT := OUTPUT || '\:';
  162        WHEN '#' THEN OUTPUT := OUTPUT || '\#';
  163        WHEN '!' THEN OUTPUT := OUTPUT || '\!';
  164        ELSE OUTPUT := OUTPUT || C;
  165      END CASE;
  166    END LOOP;
  167    RETURN OUTPUT;
  168   END;
  169 
  170 
  171 
  172   
  173 
  174 
  175 
  176 
  177 
  178 
  179 
  180   FUNCTION CONVERT_FROM(INPUT      NVARCHAR2, 
  181                        BIDX        PLS_INTEGER,
  182                        EIDX        PLS_INTEGER)
  183   RETURN VARCHAR2
  184   IS
  185    OUTPUT VARCHAR2(1200) := NULL;
  186    C      NCHAR(1);
  187    SLASH  BOOLEAN := FALSE;
  188   BEGIN
  189    
  190    FOR I IN BIDX..EIDX LOOP
  191      C := SUBSTRC(INPUT, I, 1);
  192      IF NOT SLASH AND C = '\' THEN 
  193        SLASH := TRUE; 
  194        CONTINUE; 
  195      ELSIF SLASH THEN
  196        CASE C
  197          WHEN 't' THEN OUTPUT := OUTPUT || TB;
  198          WHEN 'r' THEN OUTPUT := OUTPUT || CR;
  199          WHEN 'n' THEN OUTPUT := OUTPUT || NL;
  200          WHEN 'f' THEN OUTPUT := OUTPUT || FF;      
  201          ELSE OUTPUT := OUTPUT || C;
  202        END CASE;
  203      ELSE
  204        OUTPUT := OUTPUT || C;
  205      END IF;
  206      SLASH := FALSE;
  207    END LOOP;
  208    RETURN OUTPUT;
  209   END;
  210 
  211 
  212   
  213 
  214 
  215 
  216 
  217 
  218 
  219 
  220 
  221 
  222 
  223 
  224 
  225   PROCEDURE CHECK_BOOTSTRAP_SERVERS(P_BOOTSTRAP_SERVERS IN VARCHAR2)
  226   IS
  227     V_BSCOUNT INTEGER;
  228     V_VALUE   VARCHAR2(4000);
  229     V_COUNT   INTEGER;
  230     V_ONEPAIR BOOLEAN := FALSE;
  231 
  232   BEGIN
  233 
  234     
  235     
  236     V_BSCOUNT := REGEXP_COUNT(P_BOOTSTRAP_SERVERS, ',') + 1;
  237 
  238     FOR I IN 1 .. V_BSCOUNT LOOP 
  239       V_VALUE := REGEXP_SUBSTR(P_BOOTSTRAP_SERVERS, '[^,]+', 1, I);
  240       
  241       
  242       
  243       
  244       
  245       
  246       
  247       
  248       
  249       
  250       
  251       
  252       
  253       
  254 
  255       
  256       IF (V_VALUE IS NULL) 
  257       THEN
  258         CONTINUE;
  259       END IF;
  260 
  261       
  262       
  263       
  264       V_ONEPAIR := TRUE;
  265 
  266       
  267       
  268       
  269       
  270       
  271       
  272       
  273       
  274       V_COUNT := 
  275         REGEXP_COUNT(V_VALUE, '.*?\[?([0-9a-zA-Z\-\%._:]*)\]?:([0-9]+)');
  276 
  277       
  278       IF (V_COUNT = 0)
  279       THEN
  280         RAISE_APPLICATION_ERROR(-20000,
  281           'BOOTSTRAP_SERVERS is a comma separated list of host:port values.' || 
  282           '  Value ''' || V_VALUE || ''' in ''' || P_BOOTSTRAP_SERVERS || 
  283           ''' needs to be a host:port value.');
  284       END IF;
  285 
  286 
  287 
  288 
  289 
  290 
  291 
  292 
  293 
  294     END LOOP;
  295 
  296     
  297     IF (V_ONEPAIR = FALSE)
  298     THEN
  299         RAISE_APPLICATION_ERROR(-20000,
  300           'BOOTSTRAP_SERVERS ''' || P_BOOTSTRAP_SERVERS || 
  301           ''' needs to be a comma separated list of host:port values.');
  302     END IF;
  303 
  304   END;
  305 
  306    
  307 
  308 
  309 
  310 
  311 
  312 
  313 
  314 
  315 
  316 
  317    FUNCTION CHECK_CLUSTER_CONF_DIRECTORY(P_PARAM_VALUE IN VARCHAR2)
  318                                          RETURN VARCHAR2
  319    IS
  320      V_STR     VARCHAR2(128);
  321    BEGIN
  322 
  323      IF LENGTH(P_PARAM_VALUE) > 128 THEN
  324        RAISE_APPLICATION_ERROR(-20000, 
  325          'CLUSTER_CONF_DIRECTORY '''|| P_PARAM_VALUE ||
  326          ''' is restricted to 128 characters or less.');
  327      END IF;
  328 
  329      V_STR := CHECK_SIMPLE_SQL_NAME('cluster_conf_directory', P_PARAM_VALUE);
  330      VALIDATE_DIR_OBJECT_WITH_RX(V_STR);
  331      RETURN V_STR;
  332    END;
  333  
  334    
  335 
  336 
  337 
  338 
  339 
  340 
  341 
  342 
  343 
  344 
  345    FUNCTION CHECK_DEFAULT_DIRECTORY(P_PARAM_VALUE IN VARCHAR2)
  346                                     RETURN VARCHAR2
  347    IS
  348      V_STR     VARCHAR2(128);
  349    BEGIN
  350 
  351      IF LENGTH(P_PARAM_VALUE) > 128 THEN
  352        RAISE_APPLICATION_ERROR(-20000, 
  353          'DEFAULT_DIRECTORY '''|| P_PARAM_VALUE ||
  354          ''' is restricted to 128 characters or less.');
  355      END IF;
  356 
  357      V_STR := CHECK_SIMPLE_SQL_NAME('default_directory', P_PARAM_VALUE);
  358      VALIDATE_DIR_OBJECT_WITH_RW(V_STR);
  359      RETURN V_STR;
  360    END;
  361  
  362    
  363 
  364 
  365 
  366 
  367 
  368 
  369 
  370 
  371 
  372 
  373    FUNCTION CHECK_LOCATION_DIRECTORY(P_PARAM_VALUE IN VARCHAR2)
  374                                      RETURN VARCHAR2
  375    IS
  376      V_STR     VARCHAR2(128);
  377    BEGIN
  378 
  379      IF LENGTH(P_PARAM_VALUE) > 128 THEN
  380        RAISE_APPLICATION_ERROR(-20000, 
  381          'LOCATION_DIRECTORY '''|| P_PARAM_VALUE ||
  382          ''' is restricted to 128 characters or less.');
  383      END IF;
  384 
  385      V_STR := CHECK_SIMPLE_SQL_NAME('location_directory', P_PARAM_VALUE);
  386      VALIDATE_DIR_OBJECT_WITH_RW(V_STR);
  387      RETURN V_STR;
  388    END;
  389 	
  390   
  391 
  392 
  393 
  394 
  395 
  396 
  397 
  398 
  399 
  400 
  401 
  402 
  403 
  404 
  405 
  406   PROCEDURE CHECK_TOPIC_NAME  (P_PARAM_NAME IN VARCHAR2,
  407                                P_PARAM_VALUE IN VARCHAR2) 
  408   IS
  409     V_BAD_CHAR     VARCHAR2(128) := '';
  410 
  411   BEGIN
  412 
  413     IF (LENGTH(P_PARAM_VALUE) > 30)
  414     THEN
  415       RAISE_APPLICATION_ERROR(-20000, 
  416         UPPER(P_PARAM_NAME) || ' ''' || P_PARAM_VALUE || 
  417           ''' is restricted to 30 characters or less.');
  418     END IF;
  419 
  420     
  421     
  422     
  423     
  424     
  425     
  426     
  427     
  428     
  429 
  430     
  431     
  432     
  433     
  434     
  435     
  436     
  437     
  438     
  439 
  440     V_BAD_CHAR := REGEXP_REPLACE(P_PARAM_VALUE,
  441                        '([-]|[A-Z]|[a-z]|[0-9]|_|\.)+',
  442                        '');
  443 
  444     IF (P_PARAM_VALUE IS NULL OR V_BAD_CHAR IS NOT NULL)
  445     THEN
  446      RAISE_APPLICATION_ERROR(-20000, 
  447       UPPER(P_PARAM_NAME) || ' ''' || P_PARAM_VALUE || 
  448       ''' is restricted to the the following characters ' || 
  449       '[A-Za-z0-9_.-]+');
  450     END IF;
  451 
  452   END;
  453 
  454   
  455 
  456 
  457 
  458 
  459 
  460 
  461 
  462 
  463 
  464 
  465 
  466 
  467   FUNCTION CHECK_SIMPLE_SQL_NAME(P_PARAM_NAME IN VARCHAR2,
  468                                  P_PARAM_VALUE IN VARCHAR2)
  469                                  RETURN VARCHAR2
  470   IS
  471     V_STR     VARCHAR2(128);
  472     SIMPLE_SQL_NAME_EXCEPTION EXCEPTION;
  473     PRAGMA EXCEPTION_INIT(SIMPLE_SQL_NAME_EXCEPTION, -44003);
  474   BEGIN
  475     BEGIN
  476       V_STR := SYS.DBMS_ASSERT.SIMPLE_SQL_NAME(P_PARAM_VALUE);
  477     EXCEPTION
  478       WHEN SIMPLE_SQL_NAME_EXCEPTION THEN
  479         RAISE_APPLICATION_ERROR(-20000,
  480          UPPER(P_PARAM_NAME) || ' ''' || P_PARAM_VALUE || 
  481            ''' must be a simple SQL name');
  482     END;    
  483     RETURN V_STR;
  484   END;
  485 
  486   
  487 
  488 
  489 
  490 
  491 
  492 
  493 
  494 
  495 
  496 
  497 
  498 
  499 
  500 
  501 
  502 
  503 
  504 
  505 
  506   FUNCTION CHECK_SQL_NAME_FRAGMENT(P_PARAM_NAME IN VARCHAR2,
  507                                    P_PARAM_VALUE IN VARCHAR2,
  508                                    P_UPPERCASE IN BOOLEAN) 
  509                                    RETURN VARCHAR2
  510   IS
  511     V_STR          VARCHAR2(128);
  512     V_LENGTH       NUMBER := 0;
  513 
  514   BEGIN
  515 
  516     IF (LENGTH(P_PARAM_VALUE) > 30)
  517     THEN
  518       RAISE_APPLICATION_ERROR(-20000, 
  519         UPPER(P_PARAM_NAME) || ' ''' || P_PARAM_VALUE || 
  520           ''' is restricted to 30 characters or less.');
  521     END IF;
  522 
  523     
  524     
  525     
  526     
  527     
  528     
  529     
  530     
  531     
  532     
  533     
  534     
  535     
  536     
  537     
  538     
  539     
  540     
  541     
  542     
  543     
  544     
  545     
  546     
  547     
  548     
  549     
  550     
  551     
  552     
  553     
  554     
  555     
  556     
  557 
  558     
  559     
  560 
  561     V_LENGTH := REGEXP_COUNT(TRIM(P_PARAM_VALUE),
  562                             '[:ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:]+',
  563                              1,   
  564                              'i'  
  565                             );
  566 
  567     IF (V_LENGTH <> 1)
  568     THEN
  569      RAISE_APPLICATION_ERROR(-20000, 
  570       UPPER(P_PARAM_NAME) || ' ''' || P_PARAM_VALUE || 
  571       ''' is restricted to the alphanumeric characters ' || 
  572       '[A-Za-z0-9]+');
  573     END IF;
  574       
  575     
  576 
  577     V_STR := TRIM(BOTH FROM (CHECK_SIMPLE_SQL_NAME(P_PARAM_NAME,
  578                                                    P_PARAM_VALUE)));
  579 
  580     IF (P_UPPERCASE)
  581     THEN
  582       RETURN UPPER(V_STR);
  583     ELSE
  584       RETURN V_STR;
  585     END IF;
  586 
  587   END;
  588 
  589   
  590 
  591 
  592 
  593 
  594 
  595 
  596 
  597    FUNCTION CHECK_SQL_OBJECT(P_PARAM_NAME IN VARCHAR2,
  598                              P_PARAM_VALUE IN VARCHAR2)
  599                              RETURN VARCHAR2
  600    IS
  601     SQL_OBJECT_NAME_EXCEPTION EXCEPTION;
  602     PRAGMA EXCEPTION_INIT(SQL_OBJECT_NAME_EXCEPTION, -44002);
  603    BEGIN
  604 
  605     BEGIN
  606       RETURN SYS.DBMS_ASSERT.SQL_OBJECT_NAME(P_PARAM_VALUE);
  607     EXCEPTION
  608       WHEN SQL_OBJECT_NAME_EXCEPTION THEN
  609         RAISE_APPLICATION_ERROR(-20000,
  610          UPPER(P_PARAM_NAME) || ' ''' || P_PARAM_VALUE || 
  611          ''' must be an existing SQL object');
  612     END;    
  613 
  614    END;
  615 
  616   
  617 
  618 
  619 
  620 
  621 
  622 
  623 
  624 
  625 
  626 
  627 
  628 
  629 
  630 
  631 
  632 
  633 
  634 
  635 
  636 
  637 
  638 
  639 
  640   PROCEDURE CREATE_CGTP_VIEW
  641                    (P_CLUSTER_NAME        VARCHAR2, 
  642                     P_GROUP_ID            VARCHAR2,
  643                     P_TOPIC_ID            VARCHAR2,
  644                     P_TOPIC_RECORD_FORMAT VARCHAR2,
  645                     P_VIEW_ID             INTEGER,
  646                     P_PARTITION_START     INTEGER,
  647                     P_PARTITION_CNT       INTEGER,
  648                     P_FETCH_MAX_BYTES     INTEGER,
  649                     P_REF_TABLE           VARCHAR2,
  650                     P_BOOTSTRAP_SERVERS   VARCHAR2,
  651                     P_TOPIC_FIELD_DELIM   VARCHAR2,
  652                     P_TOPIC_RECORD_DELIM  VARCHAR2 )
  653   IS
  654     V_LOCATION_DIR       VARCHAR2(128);
  655     V_DEFAULT_DIR        VARCHAR2(128);
  656     V_CLUSTER_CONF_DIR   VARCHAR2(128);
  657     V_LOCATIONFILENAME   VARCHAR2(4000);
  658     V_LOCATION_FILE_LIST VARCHAR2(32767);
  659     V_KAFKACOMMAND       VARCHAR2(4000);
  660     V_STMT0              VARCHAR2(32767);
  661     V_STMT1              VARCHAR2(32767);
  662     V_EXTTAB_NAME        VARCHAR2(128);
  663     V_VIEW_NAME          VARCHAR2(128);
  664     V_LOGBAD_PREFIX      VARCHAR2(128);
  665     V_EXTTAB_NAME_DQ     VARCHAR2(128);
  666     V_CGTVID             VARCHAR2(128);
  667     V_COLUMN_SPEC        VARCHAR2(32767);
  668     V_FIELD_SPEC         VARCHAR2(32767);
  669     V_SELECT_LIST_SPEC   VARCHAR2(32767);
  670     V_LFILE              SYS.UTL_FILE.FILE_TYPE;
  671     V_PARTITION          INTEGER;
  672     V_COMMA  CONSTANT    CHAR(2) := ', ';
  673 
  674   BEGIN
  675 
  676      GEN_TABLE_COL_FLD_SPECS_DML(P_REF_TABLE,
  677                                  P_TOPIC_RECORD_FORMAT,
  678                                  V_COLUMN_SPEC,
  679                                  V_FIELD_SPEC,
  680                                  V_SELECT_LIST_SPEC);
  681 
  682      GET_ORAKAFKA_DIRECTORIES(P_CLUSTER_NAME,
  683                               V_LOCATION_DIR,
  684                               V_DEFAULT_DIR,
  685                               V_CLUSTER_CONF_DIR);
  686   
  687      
  688      
  689      
  690      
  691      
  692      
  693      
  694      FOR V_PARTITION_ID 
  695        IN P_PARTITION_START .. (P_PARTITION_START + P_PARTITION_CNT - 1)
  696      LOOP
  697        V_LOCATIONFILENAME :=  V_LOCATION_DIR || ':' ||
  698            SYS.DBMS_ASSERT.ENQUOTE_LITERAL(
  699                 CREATE_LOCATION_FILE_NAME(P_CLUSTER_NAME,
  700                                           P_GROUP_ID,
  701                                           P_TOPIC_ID,
  702                                           V_PARTITION_ID));
  703 
  704         IF V_LOCATION_FILE_LIST IS NULL THEN
  705           V_LOCATION_FILE_LIST := V_LOCATIONFILENAME;
  706         ELSE
  707           V_LOCATION_FILE_LIST := V_LOCATION_FILE_LIST || V_COMMA || V_LOCATIONFILENAME;
  708         END IF;
  709      END LOOP;
  710 
  711      V_CGTVID := FORMAT_CGTV_NAME(P_CLUSTER_NAME,
  712                                   P_GROUP_ID, 
  713                                   P_TOPIC_ID, 
  714                                   P_VIEW_ID);
  715 
  716      V_EXTTAB_NAME   := 'KX$' || V_CGTVID;
  717 
  718      
  719      
  720      V_LOGBAD_PREFIX := 'KX_' || V_CGTVID;   
  721 
  722      V_STMT0 :=
  723       'CREATE TABLE ' || V_EXTTAB_NAME                                        ||
  724          '( ' || V_COLUMN_SPEC || ' ) '                                       ||
  725           'ORGANIZATION EXTERNAL '                                            ||
  726           '( '                                                                ||
  727             'TYPE ORACLE_LOADER '                                             ||
  728             'DEFAULT DIRECTORY "' || V_DEFAULT_DIR || '" '                    ||
  729             'ACCESS PARAMETERS '                                              ||
  730             '('                                                               ||
  731                'RECORDS DELIMITED BY ' || P_TOPIC_RECORD_DELIM  || ' '        ||
  732                'LOGFILE "' || V_DEFAULT_DIR || '":"'                          ||
  733                      V_LOGBAD_PREFIX                                          ||
  734                      '_%a.log" '                                              ||
  735                'BADFILE "' || V_DEFAULT_DIR || '":"'                          ||
  736                      V_LOGBAD_PREFIX                                          ||
  737                      '_%a.bad" '                                              ||
  738                'CHARACTERSET AL32UTF8 '                                       ||
  739                'STRING SIZES ARE IN BYTES '                                   ||
  740                'PREPROCESSOR "' || V_CLUSTER_CONF_DIR || '":'                 ||
  741                      '"orakafka_stream.sh"   '                                ||
  742                'FIELDS TERMINATED BY ' || P_TOPIC_FIELD_DELIM  || ' '         ||
  743                'MISSING FIELD VALUES ARE NULL '                               ||
  744                '( '                                                           ||
  745                   V_FIELD_SPEC                                                ||
  746                ') '                                                           ||
  747              ') '                                                             ||
  748              'LOCATION ( ' || V_LOCATION_FILE_LIST || ' ) '                   ||
  749           ') REJECT LIMIT 0';
  750 
  751       BEGIN
  752         EXECUTE IMMEDIATE V_STMT0;
  753       EXCEPTION
  754         WHEN OTHERS THEN
  755           IF SQLCODE = -972 THEN
  756              RAISE_APPLICATION_ERROR(-20000, 'Generated table name: ' || 
  757              V_EXTTAB_NAME || 
  758              ' is too large.  See documentation for name size restrictions.'  );       
  759           ELSE
  760             RAISE;
  761           END IF;
  762       END;
  763      
  764       DISABLE_STATS(V_EXTTAB_NAME);
  765      
  766       V_VIEW_NAME := 'KV_' || V_CGTVID;
  767 
  768       V_STMT1 := 'CREATE VIEW ' || V_VIEW_NAME || 
  769                  ' AS SELECT '  || V_SELECT_LIST_SPEC ||
  770                  ' FROM '       || V_EXTTAB_NAME;
  771 
  772       BEGIN
  773         EXECUTE IMMEDIATE V_STMT1;
  774       EXCEPTION 
  775         WHEN OTHERS THEN
  776          IF SQLCODE = -972 THEN
  777            RAISE_APPLICATION_ERROR(-20000, 'Generated view name: ' || 
  778              V_VIEW_NAME || 
  779              ' is too large.  See documentation for name size restrictions.');       
  780         ELSE
  781           RAISE;
  782         END IF;
  783       END;
  784 
  785     
  786     
  787     
  788     
  789     
  790     
  791     FOR V_PARTITION 
  792        IN P_PARTITION_START .. (P_PARTITION_START + P_PARTITION_CNT - 1)
  793     LOOP
  794         CREATE_STREAM_LOCATION_FILE(P_CLUSTER_NAME,
  795                                     P_GROUP_ID,
  796                                     P_TOPIC_ID,
  797                                     P_TOPIC_RECORD_FORMAT,
  798                                     P_TOPIC_FIELD_DELIM,
  799                                     P_TOPIC_RECORD_DELIM,
  800                                     V_PARTITION,
  801                                     P_BOOTSTRAP_SERVERS,
  802                                     P_FETCH_MAX_BYTES,
  803                                     V_LOCATION_DIR);
  804      END LOOP;  
  805 
  806   END;
  807 
  808   
  809 
  810 
  811 
  812 
  813 
  814 
  815 
  816   PROCEDURE CREATE_LIST_TOPIC_VIEW(P_CLUSTER_NAME      VARCHAR2,
  817                                    P_BOOTSTRAP_SERVERS VARCHAR2)
  818   IS
  819     V_LOCATION_DIR          VARCHAR2(128);
  820     V_DEFAULT_DIR           VARCHAR2(128);
  821     V_CLUSTER_CONF_DIR      VARCHAR2(128);
  822     V_LOCATIONFILENAME      VARCHAR2(4000);
  823     V_LFILE                 SYS.UTL_FILE.FILE_TYPE;
  824     V_STMT0                 VARCHAR2(4000);
  825     V_STMT1                 VARCHAR2(4000);
  826     V_TABLE_NAME            VARCHAR2(128);
  827     V_VIEW_NAME             VARCHAR2(128);
  828     V_LFILE_PROPS           PROPERTIES_TYPE;
  829   BEGIN
  830      V_LOCATIONFILENAME := 'KX_' || P_CLUSTER_NAME || '_TOPICS.loc';
  831      GET_ORAKAFKA_DIRECTORIES(P_CLUSTER_NAME, V_LOCATION_DIR, V_DEFAULT_DIR, 
  832                                V_CLUSTER_CONF_DIR);
  833 
  834     
  835     
  836     
  837     V_LFILE_PROPS('ora_kafka_operation')      := 'metadata';
  838     V_LFILE_PROPS('kafka_bootstrap_servers')  := P_BOOTSTRAP_SERVERS;
  839     PROPERTIES_TO_FILE(V_LFILE_PROPS, V_LOCATION_DIR, V_LOCATIONFILENAME);
  840 
  841      
  842 
  843 
  844      V_TABLE_NAME := UPPER('KX$' || P_CLUSTER_NAME || '_TOPICS'); 
  845      V_STMT0 := 
  846       'CREATE TABLE ' || V_TABLE_NAME || ' '                                   ||
  847          '( "TOPIC_NAME" VARCHAR2(4000), "PARTITION_COUNT" INTEGER ) '         ||
  848           'ORGANIZATION EXTERNAL '                                             || 
  849           '( '                                                                 ||
  850             'TYPE ORACLE_LOADER '                                              ||
  851             'DEFAULT DIRECTORY "' || V_DEFAULT_DIR || '" '                     ||
  852             'ACCESS PARAMETERS '                                               || 
  853             '('                                                                ||
  854                'RECORDS DELIMITED BY 0X''0A'' '                                ||
  855                'LOGFILE "' || V_DEFAULT_DIR || '":''KX_'                       || 
  856                      P_CLUSTER_NAME                                            || 
  857                      '_TOPICS_%a.log'' '                                       ||
  858                'BADFILE "' || V_DEFAULT_DIR || '":''KX_'                       || 
  859                      P_CLUSTER_NAME                                            || 
  860                      '_TOPICS_%a.bad'' '                                       ||
  861                'CHARACTERSET AL32UTF8 '                                        ||
  862                'STRING SIZES ARE IN BYTES '                                    ||
  863                'PREPROCESSOR "' || V_CLUSTER_CONF_DIR || '":'                  ||
  864                       '"orakafka_stream.sh" '                                  ||
  865                'FIELDS TERMINATED BY 0X''2C'' '                                ||
  866                'MISSING FIELD VALUES ARE NULL '                                ||
  867                '( '                                                            ||
  868                   '"TOPIC_NAME" CHAR(4000), '                                  || 
  869                   '"PARTITION_COUNT" CHAR'                                     || 
  870                ') '                                                            ||
  871              ') '                                                              ||
  872              'LOCATION (' || V_LOCATION_DIR || ':''' || V_LOCATIONFILENAME     || 
  873              ''' ) ' || 
  874           ')';
  875 
  876 
  877        
  878 
  879       BEGIN
  880         EXECUTE IMMEDIATE V_STMT0;
  881       EXCEPTION
  882         WHEN OTHERS THEN
  883           
  884           BEGIN
  885             DELETE_LOCATION_FILE(V_LOCATION_DIR, V_LOCATIONFILENAME);
  886           EXCEPTION
  887           WHEN OTHERS THEN
  888              
  889              
  890              DBMS_OUTPUT.PUT(DBMS_UTILITY.FORMAT_ERROR_STACK());
  891              DBMS_OUTPUT.PUT(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
  892           END;  
  893 
  894           IF SQLCODE = -972 THEN
  895             RAISE_APPLICATION_ERROR(-20000, 'Generated table name: ' || 
  896               V_TABLE_NAME || 
  897               ' is too large.  See documentation for name size restrictions.');       
  898           ELSE
  899             RAISE;
  900           END IF;
  901       END;
  902 
  903       DISABLE_STATS(V_TABLE_NAME);
  904 
  905 
  906  
  907       
  908 
  909 
  910 
  911 
  912       
  913       V_VIEW_NAME := 'KV_' || P_CLUSTER_NAME || '_TOPICS';
  914       BEGIN
  915         V_STMT1 := 'CREATE VIEW ' || V_VIEW_NAME || 
  916                    ' AS SELECT topic_name, partition_count  FROM  KX$' || 
  917                    P_CLUSTER_NAME || '_TOPICS ';
  918 
  919         EXECUTE IMMEDIATE V_STMT1;
  920       EXCEPTION
  921         WHEN OTHERS THEN
  922           
  923           BEGIN
  924             DELETE_LOCATION_FILE(V_LOCATION_DIR, V_LOCATIONFILENAME);
  925             EXECUTE IMMEDIATE 'drop table ' || V_TABLE_NAME;
  926           EXCEPTION
  927           WHEN OTHERS THEN
  928              
  929              
  930              DBMS_OUTPUT.PUT(DBMS_UTILITY.FORMAT_ERROR_STACK());
  931              DBMS_OUTPUT.PUT(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
  932           END;  
  933 
  934           IF SQLCODE = -972 THEN
  935             RAISE_APPLICATION_ERROR(-20000, 
  936                                    'Generated view name: ' || 
  937                                     V_VIEW_NAME || 
  938              ' is too large.  See documentation for name size restrictions.');       
  939         ELSE
  940           RAISE;
  941         END IF;
  942       END;        
  943   END;
  944 
  945   
  946 
  947 
  948 
  949   FUNCTION CREATE_LOCATION_FILE_NAME(P_CLUSTER_NAME        IN VARCHAR2,
  950                                       P_GROUP_ID            IN VARCHAR2,
  951                                       P_TOPIC_NAME          IN VARCHAR2,
  952                                       P_PARTITION_ID        IN INTEGER)
  953   RETURN VARCHAR2
  954   IS
  955   BEGIN
  956        RETURN    'KX_'  || 
  957                  FORMAT_CGTP_NAME(P_CLUSTER_NAME,
  958                                   P_GROUP_ID,
  959                                   P_TOPIC_NAME, 
  960                                   P_PARTITION_ID) ||
  961                  '.loc';
  962     
  963   END;
  964 
  965 
  966 
  967   
  968 
  969 
  970 
  971 
  972 
  973 
  974 
  975 
  976 
  977 
  978 
  979 
  980 
  981 
  982   PROCEDURE CREATE_STREAM_LOCATION_FILE(P_CLUSTER_NAME       IN VARCHAR2, 
  983                                        P_GROUP_ID            IN VARCHAR2,
  984                                        P_TOPIC_NAME          IN VARCHAR2,
  985                                        P_TOPIC_RECORD_FORMAT IN VARCHAR2,
  986                                        P_TOPIC_FIELD_DELIM   IN VARCHAR2,
  987                                        P_TOPIC_RECORD_DELIM  IN VARCHAR2,
  988                                        P_PARTITION_ID        IN INTEGER,
  989                                        P_BOOTSTRAP_SERVERS   IN VARCHAR2,
  990                                        P_FETCH_MAX_BYTES     IN INTEGER,
  991                                        P_LOCATION_DIR        IN VARCHAR2)
  992   IS
  993     V_LOCATIONFILENAME      VARCHAR2(4000);
  994     V_LFILE                 SYS.UTL_FILE.FILE_TYPE;
  995     V_LFILE_PROPS           PROPERTIES_TYPE;
  996   BEGIN
  997 
  998     V_LOCATIONFILENAME := 
  999                 CREATE_LOCATION_FILE_NAME(P_CLUSTER_NAME,
 1000                                           P_GROUP_ID,
 1001                                           P_TOPIC_NAME,
 1002                                           P_PARTITION_ID);
 1003 
 1004 
 1005     V_LFILE_PROPS('ora_kafka_operation')           := 'stream';
 1006     V_LFILE_PROPS('kafka_bootstrap_servers')       := P_BOOTSTRAP_SERVERS;
 1007     V_LFILE_PROPS('kafka_consumer_group_id')       := P_GROUP_ID;
 1008     V_LFILE_PROPS('kafka_topic_name')              := P_TOPIC_NAME ;
 1009     V_LFILE_PROPS('ora_kafka_topic_record_format') := P_TOPIC_RECORD_FORMAT;
 1010     V_LFILE_PROPS('ora_kafka_topic_field_delim')   := P_TOPIC_FIELD_DELIM;
 1011     V_LFILE_PROPS('ora_kafka_topic_record_delim')  := P_TOPIC_RECORD_DELIM;
 1012     V_LFILE_PROPS('kafka_partition_id')            := P_PARTITION_ID;
 1013     V_LFILE_PROPS('kafka_fetch_max_bytes')         := P_FETCH_MAX_BYTES;
 1014 
 1015     PROPERTIES_TO_FILE(V_LFILE_PROPS, P_LOCATION_DIR, V_LOCATIONFILENAME);
 1016 
 1017   END;
 1018 
 1019   
 1020 
 1021 
 1022 
 1023 
 1024 
 1025 
 1026 
 1027 
 1028 
 1029   PROCEDURE CREATE_TOPIC_PARTITION_VIEW(P_CLUSTER_NAME VARCHAR2,
 1030                                         P_TOPIC_NAME VARCHAR2,
 1031                                         P_BOOTSTRAP_SERVERS VARCHAR2)
 1032   IS
 1033     V_LOCATION_DIR          VARCHAR2(128);
 1034     V_DEFAULT_DIR           VARCHAR2(128);
 1035     V_CLUSTER_CONF_DIR      VARCHAR2(128);
 1036     V_LOCATIONFILENAME      VARCHAR2(4000);
 1037     V_LOCATIONFILECONTENTS  VARCHAR2(32767);
 1038     V_LFILE                 SYS.UTL_FILE.FILE_TYPE;
 1039 
 1040     V_STMT1                 VARCHAR2(32767);
 1041     V_STMT2                 VARCHAR2(32767);
 1042 
 1043     V_IDENTIFIER            VARCHAR2(4000);
 1044     V_VIEW_NAME             VARCHAR2(128);
 1045     V_TABLE_NAME            VARCHAR2(128);
 1046     V_COUNT                 INTEGER;
 1047     V_LFILE_PROPS           PROPERTIES_TYPE;
 1048   BEGIN
 1049 
 1050      V_IDENTIFIER :=  FORMAT_CTP_NAME(P_CLUSTER_NAME, P_TOPIC_NAME);
 1051      V_VIEW_NAME  := 'KV_' || V_IDENTIFIER;
 1052      
 1053      SELECT COUNT(*)
 1054        INTO V_COUNT 
 1055        FROM SYS.USER_VIEWS 
 1056        WHERE VIEW_NAME = V_VIEW_NAME;
 1057      
 1058      IF V_COUNT > 0 THEN
 1059          
 1060         RETURN;
 1061      END IF;
 1062 
 1063      GET_ORAKAFKA_DIRECTORIES(P_CLUSTER_NAME,
 1064                                V_LOCATION_DIR,
 1065                                V_DEFAULT_DIR,
 1066                                V_CLUSTER_CONF_DIR);
 1067 
 1068      V_LOCATIONFILENAME := 'KX_' || V_IDENTIFIER || '.loc';
 1069 
 1070      V_TABLE_NAME := UPPER('KX$' || V_IDENTIFIER);
 1071 
 1072      
 1073 
 1074                        
 1075      V_STMT1 := 
 1076       'CREATE TABLE '|| V_TABLE_NAME                                          ||
 1077          '( "PARTITION_ID" INTEGER, '                                         ||
 1078            '"PARTITION_LEADER" INTEGER, '                                     ||
 1079            '"PARTITION_REPLICA_COUNT" INTEGER, '                              ||
 1080            '"ISRS_COUNT" INTEGER, '                                           ||
 1081            '"LOW_WATER_MARK" INTEGER, '                                       ||
 1082            '"HIGH_WATER_MARK" INTEGER  ) '                                    ||
 1083           'ORGANIZATION EXTERNAL '                                            || 
 1084           '( '                                                                ||
 1085             'TYPE ORACLE_LOADER '                                             ||
 1086             'DEFAULT DIRECTORY "' || V_DEFAULT_DIR || '" '                    ||
 1087             'ACCESS PARAMETERS '                                              || 
 1088             '('                                                               ||
 1089                'RECORDS DELIMITED BY 0X''0A'' '                               ||
 1090                'LOGFILE "' || V_DEFAULT_DIR || '":''KX_'                      || 
 1091                      V_IDENTIFIER                                             || 
 1092                      '_%a.log'' '                                             ||
 1093                'BADFILE "' || V_DEFAULT_DIR || '":''KX_'                      || 
 1094                      V_IDENTIFIER                                             || 
 1095                      '_%a.bad'' '                                             ||
 1096                'CHARACTERSET AL32UTF8 '                                       ||
 1097                'STRING SIZES ARE IN BYTES '                                   ||
 1098                'PREPROCESSOR "' || V_CLUSTER_CONF_DIR || '":'                 ||
 1099                        '"orakafka_stream.sh" '                                ||
 1100                'FIELDS TERMINATED BY 0X''2C'' '                               ||
 1101                'MISSING FIELD VALUES ARE NULL '                               ||
 1102                '( '                                                           ||
 1103                   '"PARTITION_ID"    CHAR, '                                  ||
 1104                   '"PARTITION_LEADER" CHAR, '                                 ||
 1105                   '"PARTITION_REPLICA_COUNT" CHAR, '                          ||
 1106                   '"ISRS_COUNT" CHAR, '                                       ||
 1107                   '"LOW_WATER_MARK" CHAR, '                                   ||
 1108                   '"HIGH_WATER_MARK" CHAR '                                   ||
 1109                ') '                                                           ||
 1110              ') '                                                             ||
 1111              'LOCATION (' || V_LOCATION_DIR || ':''' || V_LOCATIONFILENAME || 
 1112                     ''')' || 
 1113           ')';
 1114 
 1115      
 1116 
 1117      BEGIN
 1118        EXECUTE IMMEDIATE V_STMT1;
 1119      EXCEPTION
 1120        WHEN OTHERS THEN
 1121          IF SQLCODE = -972 THEN
 1122            RAISE_APPLICATION_ERROR(-20000, 
 1123                                    'Generated table name: ' || 
 1124                                     V_TABLE_NAME || 
 1125              ' is too large.  See documentation for name size restrictions.');       
 1126          ELSE
 1127            RAISE;
 1128          END IF;
 1129      END;        
 1130 
 1131      DISABLE_STATS(V_TABLE_NAME);
 1132 
 1133     V_LFILE_PROPS('ora_kafka_operation')      := 'metadata';
 1134     V_LFILE_PROPS('kafka_bootstrap_servers')  := P_BOOTSTRAP_SERVERS;
 1135     V_LFILE_PROPS('kafka_topic_name')         := P_TOPIC_NAME;
 1136 
 1137     PROPERTIES_TO_FILE(V_LFILE_PROPS, V_LOCATION_DIR, V_LOCATIONFILENAME);
 1138 
 1139 
 1140      
 1141 
 1142       
 1143 
 1144      V_STMT2 := 'CREATE VIEW '|| V_VIEW_NAME || 
 1145                 ' AS SELECT partition_id, partition_leader, '||
 1146                 ' partition_replica_count, isrs_count, low_water_mark, '||
 1147                 'high_water_mark  FROM  KX$' || 
 1148          V_IDENTIFIER;
 1149 
 1150      BEGIN
 1151        EXECUTE IMMEDIATE V_STMT2;
 1152      EXCEPTION
 1153        WHEN OTHERS THEN
 1154          IF SQLCODE = -972 THEN
 1155            RAISE_APPLICATION_ERROR(-20000, 
 1156                                    'Generated view name: ' || 
 1157                                   V_VIEW_NAME || 
 1158              ' is too large.  See documentation for name size restrictions.');       
 1159          ELSE
 1160            RAISE;
 1161          END IF;
 1162      END;        
 1163 
 1164   END;
 1165 
 1166   
 1167 
 1168 
 1169 
 1170 
 1171 
 1172 
 1173 
 1174   PROCEDURE DELETE_LOCATION_FILE(P_LOCATION_DIR IN VARCHAR2,
 1175                                  P_FILE_NAME    IN VARCHAR2)
 1176   IS
 1177     V_FILE_EXISTS BOOLEAN;
 1178     V_FILE_LENGTH NUMBER;
 1179     V_BLOCKSIZE NUMBER;
 1180   BEGIN
 1181     SYS.UTL_FILE.FGETATTR(P_LOCATION_DIR, P_FILE_NAME, V_FILE_EXISTS, 
 1182                       V_FILE_LENGTH, V_BLOCKSIZE);
 1183     IF V_FILE_EXISTS THEN
 1184        SYS.UTL_FILE.FREMOVE(P_LOCATION_DIR, P_FILE_NAME);
 1185     END IF;
 1186   END;
 1187 
 1188   
 1189 
 1190 
 1191 
 1192 
 1193 
 1194   PROCEDURE DISABLE_STATS(P_TABLE_NAME IN VARCHAR2)
 1195   IS
 1196   BEGIN
 1197     SYS.DBMS_STATS.LOCK_TABLE_STATS(SYS_CONTEXT('USERENV','CURRENT_SCHEMA'),  
 1198                                     P_TABLE_NAME);
 1199   END;                                         
 1200 
 1201   
 1202 
 1203 
 1204 
 1205 
 1206 
 1207 
 1208   PROCEDURE DROP_OBJECT_IF_EXIST(P_OBJECT_TYPE IN VARCHAR2,
 1209                                  P_OBJECT_NAME IN VARCHAR2)
 1210   IS
 1211     V_STMT VARCHAR2(500);
 1212     V_ERROR_CODE INTEGER;
 1213     V_FULL_OBJECT_NAME VARCHAR2(512);
 1214     V_OBJECT_NAME VARCHAR2(512);
 1215 
 1216     SQL_OBJECT_NAME_EXCEPTION EXCEPTION;
 1217     PRAGMA EXCEPTION_INIT(SQL_OBJECT_NAME_EXCEPTION, -44002);
 1218 
 1219   BEGIN
 1220      V_FULL_OBJECT_NAME := SYS_CONTEXT('USERENV','CURRENT_SCHEMA') ||
 1221                                                                '.' ||
 1222                                         P_OBJECT_NAME;                            
 1223 
 1224     BEGIN
 1225       V_OBJECT_NAME := DBMS_ASSERT.SQL_OBJECT_NAME(V_FULL_OBJECT_NAME);
 1226     EXCEPTION
 1227       WHEN SQL_OBJECT_NAME_EXCEPTION THEN
 1228         RAISE_APPLICATION_ERROR(-20000,
 1229                          P_OBJECT_TYPE || ' ''' || V_FULL_OBJECT_NAME || 
 1230                          ''' must be an existing SQL object');
 1231     END;    
 1232 
 1233     CASE UPPER(P_OBJECT_TYPE)
 1234     WHEN 'TABLE' THEN
 1235        V_STMT := 'DROP TABLE ' || P_OBJECT_NAME;
 1236        V_ERROR_CODE := -942;
 1237     WHEN 'VIEW' THEN
 1238        V_STMT := 'DROP VIEW ' || P_OBJECT_NAME;
 1239        V_ERROR_CODE := -942;
 1240     ELSE
 1241        RAISE_APPLICATION_ERROR(-20000, 'Invalid object type: ' || P_OBJECT_TYPE);
 1242     END CASE;
 1243     
 1244     EXECUTE IMMEDIATE V_STMT;
 1245 
 1246   EXCEPTION WHEN OTHERS THEN
 1247     IF SQLCODE != V_ERROR_CODE THEN
 1248       RAISE;
 1249     END IF;    
 1250   END;
 1251 
 1252   
 1253 
 1254 
 1255 
 1256   PROCEDURE DROP_VIEWS_TABLES_LOCATIONS(P_CLUSTER_NAME IN VARCHAR2,
 1257                                         P_GROUP_NAME   IN VARCHAR2,
 1258                                         P_TOPIC_NAME   IN VARCHAR2)
 1259   IS
 1260     V_NUM_VIEWS INTEGER;
 1261     V_NUM_PARTITIONS INTEGER;
 1262     V_VIEW_NAME VARCHAR2(128);
 1263     V_TABLE_NAME VARCHAR2(128);
 1264     V_LOCATION_DIR VARCHAR2(128);
 1265     V_LOCATION_FILE_NAME VARCHAR2(4000);    
 1266     V_SQL_TOPIC_NAME VARCHAR2(30);
 1267   BEGIN
 1268     
 1269     
 1270 
 1271     V_SQL_TOPIC_NAME := SQL_TOPIC_NAME(P_TOPIC_NAME);
 1272 
 1273     
 1274     BEGIN
 1275       SELECT NUM_VIEWS INTO V_NUM_VIEWS FROM ORA_KAFKA_APPLICATION 
 1276         WHERE CLUSTER_NAME = UPPER(P_CLUSTER_NAME) AND
 1277               GROUP_NAME = P_GROUP_NAME AND
 1278               TOPIC_NAME = P_TOPIC_NAME;
 1279       EXCEPTION WHEN NO_DATA_FOUND THEN
 1280           
 1281           
 1282           RAISE_MISSING_CGT_EXCEPTION(P_CLUSTER_NAME, 
 1283                                       P_GROUP_NAME, 
 1284                                       P_TOPIC_NAME); 
 1285     END;
 1286 
 1287     FOR V_VIEW_ID IN 0 .. V_NUM_VIEWS - 1 LOOP
 1288       V_VIEW_NAME := UPPER('KV_' || P_CLUSTER_NAME || '_' || P_GROUP_NAME 
 1289                      || '_' || V_SQL_TOPIC_NAME || '_' || V_VIEW_ID);
 1290       DROP_OBJECT_IF_EXIST('view', V_VIEW_NAME);
 1291       V_TABLE_NAME := UPPER('KX$' || P_CLUSTER_NAME || '_' || P_GROUP_NAME 
 1292                      || '_' || V_SQL_TOPIC_NAME || '_' || V_VIEW_ID);
 1293       DROP_OBJECT_IF_EXIST('table', V_TABLE_NAME);
 1294     END LOOP;
 1295 
 1296     
 1297 
 1298     SELECT COUNT(*) INTO V_NUM_PARTITIONS FROM ORA_KAFKA_PARTITION 
 1299         WHERE CLUSTER_NAME = P_CLUSTER_NAME AND
 1300               GROUP_NAME = P_GROUP_NAME AND 
 1301               TOPIC_NAME = P_TOPIC_NAME;
 1302    
 1303     V_LOCATION_DIR := GET_LOCATION_DIR(P_CLUSTER_NAME);
 1304     FOR V_PART_ID IN 0 .. V_NUM_PARTITIONS-1 LOOP
 1305       V_LOCATION_FILE_NAME := UPPER('KX_' || P_CLUSTER_NAME || '_' || 
 1306         P_GROUP_NAME || '_' || V_SQL_TOPIC_NAME || '_' || V_PART_ID) || '.loc';
 1307 
 1308       DELETE_LOCATION_FILE(V_LOCATION_DIR, V_LOCATION_FILE_NAME);
 1309       DELETE_LOCATION_FILE(V_LOCATION_DIR, V_LOCATION_FILE_NAME || '.pp.bci');
 1310       DELETE_LOCATION_FILE(V_LOCATION_DIR, V_LOCATION_FILE_NAME || '.pp.bco');
 1311 
 1312     END LOOP;
 1313 
 1314   END;
 1315 
 1316 
 1317   
 1318 
 1319 
 1320 
 1321 
 1322 
 1323 
 1324 
 1325 
 1326   FUNCTION FORMAT_CGTP_NAME(P_CLUSTER_NAME IN VARCHAR2,
 1327                             P_GROUP_ID     IN VARCHAR2,
 1328                             P_TOPIC_NAME   IN VARCHAR2,
 1329                             P_PARTITION_ID IN NUMBER)
 1330   RETURN VARCHAR2
 1331   IS
 1332   BEGIN
 1333     RETURN  UPPER(P_CLUSTER_NAME 
 1334                   || '_' 
 1335                   || P_GROUP_ID 
 1336                   || '_' 
 1337                   || SQL_TOPIC_NAME(P_TOPIC_NAME)
 1338                   || '_' 
 1339                   || P_PARTITION_ID);
 1340   END;
 1341 
 1342   
 1343 
 1344 
 1345 
 1346 
 1347 
 1348 
 1349 
 1350 
 1351 
 1352   FUNCTION FORMAT_CGTV_NAME(P_CLUSTER_NAME IN VARCHAR2,
 1353                             P_GROUP_ID     IN VARCHAR2,
 1354                             P_TOPIC_NAME   IN VARCHAR2,
 1355                             P_VIEW_ID      IN NUMBER)
 1356   RETURN VARCHAR2
 1357   IS
 1358   BEGIN
 1359      
 1360      
 1361      
 1362      
 1363      RETURN  FORMAT_CGTP_NAME(P_CLUSTER_NAME,
 1364                               P_GROUP_ID,
 1365                               P_TOPIC_NAME,
 1366                               P_VIEW_ID);
 1367   END;
 1368 
 1369   
 1370 
 1371 
 1372 
 1373 
 1374 
 1375 
 1376 
 1377   FUNCTION FORMAT_CTP_NAME(P_CLUSTER_NAME IN VARCHAR2,
 1378                            P_TOPIC_NAME   IN VARCHAR2)
 1379   RETURN VARCHAR2
 1380   IS
 1381   BEGIN
 1382     RETURN  UPPER(P_CLUSTER_NAME || '_' || SQL_TOPIC_NAME(P_TOPIC_NAME) || '_PARTITIONS');
 1383   END;
 1384 
 1385   
 1386 
 1387 
 1388 
 1389 
 1390 
 1391 
 1392 
 1393 
 1394   FUNCTION GEN_EXTTAB_HEADER(P_DEFAULT_DIR IN VARCHAR2) RETURN VARCHAR2
 1395   IS
 1396   BEGIN
 1397     RETURN 
 1398             'TYPE ORACLE_LOADER '                                             ||
 1399             'DEFAULT DIRECTORY "'|| P_DEFAULT_DIR ||'" '                      ||
 1400             'ACCESS PARAMETERS ';
 1401 
 1402   END;
 1403 
 1404   
 1405 
 1406 
 1407 
 1408 
 1409 
 1410 
 1411 
 1412 
 1413 
 1414 
 1415 
 1416 
 1417   PROCEDURE GEN_TIMESTAMP_SPEC(P_COLUMN_SPEC      IN OUT VARCHAR2,
 1418                                P_FIELD_SPEC       IN OUT VARCHAR2,
 1419                                P_SELECT_LIST_SPEC IN OUT VARCHAR2,
 1420                                P_COLUMN_NAME      IN VARCHAR2,
 1421                                P_DATA_TYPE        IN VARCHAR2)
 1422   IS
 1423     V_DQ               VARCHAR2(1) := '"';
 1424     V_SQ               VARCHAR2(1) := '''';
 1425   BEGIN     
 1426      P_COLUMN_SPEC := P_COLUMN_SPEC || V_DQ || P_COLUMN_NAME || V_DQ || 
 1427                       ' ' || P_DATA_TYPE;
 1428      P_FIELD_SPEC  := P_FIELD_SPEC  || V_DQ || P_COLUMN_NAME || V_DQ || 
 1429         ' CHAR DATE_FORMAT TIMESTAMP MASK ' || V_SQ || 
 1430         'YYYY-MM-DD HH24:MI:SS.FF' || V_SQ;
 1431      P_SELECT_LIST_SPEC := P_SELECT_LIST_SPEC || V_DQ || P_COLUMN_NAME || V_DQ;
 1432   END;
 1433 
 1434   
 1435 
 1436 
 1437 
 1438 
 1439 
 1440 
 1441 
 1442 
 1443   PROCEDURE GENJSON_VC2_COLFLDSPECS(P_COLUMN_SPEC      IN OUT VARCHAR2,
 1444                                     P_FIELD_SPEC       IN OUT VARCHAR2,
 1445                                     P_SELECT_LIST_SPEC IN OUT VARCHAR2
 1446   )
 1447   IS
 1448   BEGIN
 1449     P_COLUMN_SPEC := P_COLUMN_SPEC || 
 1450            ', KEY VARCHAR2('|| MAX_VARCHAR2_LEN ||
 1451            '), VALUE VARCHAR2(' || MAX_VARCHAR2_LEN || ')';
 1452     P_FIELD_SPEC := P_FIELD_SPEC || ', KEY CHAR('|| MAX_VARCHAR2_LEN || 
 1453                                     '), VALUE CHAR('|| MAX_VARCHAR2_LEN || ')';
 1454     P_SELECT_LIST_SPEC := P_SELECT_LIST_SPEC || ', KEY, VALUE';
 1455   END;
 1456 
 1457   
 1458 
 1459 
 1460 
 1461 
 1462 
 1463 
 1464 
 1465 
 1466 
 1467 
 1468   PROCEDURE GENCSV_COLFLDSPECS(P_REF_TABLE          IN VARCHAR2,
 1469                                P_COLUMN_SPEC        IN OUT VARCHAR2,
 1470                                P_FIELD_SPEC         IN OUT VARCHAR2,
 1471                                P_SELECT_LIST_SPEC   IN OUT VARCHAR2
 1472   )
 1473   IS
 1474     TYPE               USERTABCOLUMNTYPE IS REF CURSOR;
 1475     V_UTC_CURSOR       USERTABCOLUMNTYPE;
 1476     V_UTC_STMT         VARCHAR2(4000);
 1477 
 1478     V_COLUMN_NAME      VARCHAR2(128);
 1479     V_DATA_TYPE        VARCHAR2(128);
 1480 
 1481     V_DATA_LENGTH      NUMBER;
 1482     V_DATA_PRECISION   NUMBER;
 1483     V_DATA_SCALE       NUMBER;
 1484 
 1485     V_DQ   CONSTANT    CHAR(1) := '"';
 1486     V_SQ   CONSTANT    CHAR(1) := '''';
 1487     V_COMMA  CONSTANT  CHAR(2) := ', ';
 1488 
 1489   BEGIN
 1490 
 1491     V_UTC_STMT := 
 1492      'SELECT column_name, data_type, data_length, data_precision,' || 
 1493        ' data_scale ' ||
 1494        ' FROM sys.user_tab_columns WHERE ' || 
 1495        'table_name = :p_table_name ORDER BY column_id';
 1496 
 1497     OPEN V_UTC_CURSOR FOR V_UTC_STMT USING P_REF_TABLE;
 1498 
 1499     LOOP
 1500 
 1501       FETCH V_UTC_CURSOR INTO V_COLUMN_NAME, V_DATA_TYPE, V_DATA_LENGTH, 
 1502                               V_DATA_PRECISION, V_DATA_SCALE;
 1503 
 1504       EXIT WHEN V_UTC_CURSOR%NOTFOUND;
 1505 
 1506       P_COLUMN_SPEC := P_COLUMN_SPEC || V_COMMA;
 1507       P_FIELD_SPEC  := P_FIELD_SPEC  || V_COMMA;
 1508       P_SELECT_LIST_SPEC := P_SELECT_LIST_SPEC || V_COMMA;
 1509 
 1510       CASE V_DATA_TYPE
 1511         WHEN 'VARCHAR2' THEN
 1512           P_COLUMN_SPEC:= P_COLUMN_SPEC || V_DQ || V_COLUMN_NAME || V_DQ || 
 1513                            ' VARCHAR2(' || V_DATA_LENGTH || ')';         
 1514           P_FIELD_SPEC := P_FIELD_SPEC || V_DQ || V_COLUMN_NAME || V_DQ ||
 1515                            ' CHAR(' || V_DATA_LENGTH || ')';         
 1516           P_SELECT_LIST_SPEC := P_SELECT_LIST_SPEC || V_DQ || V_COLUMN_NAME || 
 1517                                  V_DQ;         
 1518         WHEN 'NUMBER' THEN
 1519           IF (V_DATA_PRECISION IS NULL) THEN
 1520              P_COLUMN_SPEC := P_COLUMN_SPEC || V_DQ || V_COLUMN_NAME || V_DQ ||
 1521              ' NUMBER';
 1522           ELSE
 1523             P_COLUMN_SPEC := P_COLUMN_SPEC || V_DQ || V_COLUMN_NAME || V_DQ || 
 1524                            ' NUMBER(' || V_DATA_PRECISION || ',' || V_DATA_SCALE || ')';
 1525           END IF;
 1526           P_FIELD_SPEC  := P_FIELD_SPEC || V_DQ || V_COLUMN_NAME || V_DQ || ' CHAR';         
 1527           P_SELECT_LIST_SPEC  := P_SELECT_LIST_SPEC || V_DQ || V_COLUMN_NAME || V_DQ;         
 1528         WHEN 'TIMESTAMP(0)' THEN
 1529           GEN_TIMESTAMP_SPEC(P_COLUMN_SPEC, P_FIELD_SPEC, P_SELECT_LIST_SPEC,
 1530                              V_COLUMN_NAME, V_DATA_TYPE);
 1531         WHEN 'TIMESTAMP(1)' THEN
 1532           GEN_TIMESTAMP_SPEC(P_COLUMN_SPEC, P_FIELD_SPEC, P_SELECT_LIST_SPEC,
 1533                              V_COLUMN_NAME, V_DATA_TYPE);
 1534         WHEN 'TIMESTAMP(2)' THEN
 1535           GEN_TIMESTAMP_SPEC(P_COLUMN_SPEC, P_FIELD_SPEC, P_SELECT_LIST_SPEC,
 1536                              V_COLUMN_NAME, V_DATA_TYPE);
 1537         WHEN 'TIMESTAMP(3)' THEN
 1538           GEN_TIMESTAMP_SPEC(P_COLUMN_SPEC, P_FIELD_SPEC, P_SELECT_LIST_SPEC,
 1539                              V_COLUMN_NAME, V_DATA_TYPE);
 1540         WHEN 'TIMESTAMP(4)' THEN
 1541           GEN_TIMESTAMP_SPEC(P_COLUMN_SPEC, P_FIELD_SPEC, P_SELECT_LIST_SPEC,
 1542                              V_COLUMN_NAME, V_DATA_TYPE);
 1543         WHEN 'TIMESTAMP(5)' THEN
 1544           GEN_TIMESTAMP_SPEC(P_COLUMN_SPEC, P_FIELD_SPEC, P_SELECT_LIST_SPEC,
 1545                              V_COLUMN_NAME, V_DATA_TYPE);
 1546         WHEN 'TIMESTAMP(6)' THEN
 1547           GEN_TIMESTAMP_SPEC(P_COLUMN_SPEC, P_FIELD_SPEC, P_SELECT_LIST_SPEC,
 1548                              V_COLUMN_NAME, V_DATA_TYPE);
 1549         WHEN 'TIMESTAMP(7)' THEN
 1550           GEN_TIMESTAMP_SPEC(P_COLUMN_SPEC, P_FIELD_SPEC, P_SELECT_LIST_SPEC,
 1551                              V_COLUMN_NAME, V_DATA_TYPE);
 1552         WHEN 'TIMESTAMP(8)' THEN
 1553           GEN_TIMESTAMP_SPEC(P_COLUMN_SPEC, P_FIELD_SPEC, P_SELECT_LIST_SPEC,
 1554                              V_COLUMN_NAME, V_DATA_TYPE);
 1555         WHEN 'TIMESTAMP(9)' THEN
 1556           GEN_TIMESTAMP_SPEC(P_COLUMN_SPEC, P_FIELD_SPEC, P_SELECT_LIST_SPEC,
 1557                              V_COLUMN_NAME, V_DATA_TYPE);
 1558         WHEN 'DATE' THEN
 1559           P_COLUMN_SPEC := P_COLUMN_SPEC || V_DQ || V_COLUMN_NAME || V_DQ || ' DATE';
 1560           P_FIELD_SPEC  := P_FIELD_SPEC  || V_DQ || V_COLUMN_NAME || V_DQ || 
 1561                  ' CHAR DATE_FORMAT DATE MASK ' || V_SQ || 'YYYY-MM-DD HH24:MI:SS' || V_SQ;
 1562           P_SELECT_LIST_SPEC  := P_SELECT_LIST_SPEC || V_DQ || V_COLUMN_NAME || V_DQ;         
 1563 
 1564         ELSE 
 1565           RAISE_APPLICATION_ERROR(-20000, 'Unsupported data type ' || 
 1566                                    V_DATA_TYPE || ' found in table ' || P_REF_TABLE);
 1567       END CASE;
 1568     END LOOP;
 1569 
 1570     CLOSE V_UTC_CURSOR;
 1571 
 1572   END;
 1573 
 1574   
 1575 
 1576 
 1577 
 1578 
 1579 
 1580 
 1581 
 1582 
 1583 
 1584 
 1585 
 1586 
 1587 
 1588 
 1589 
 1590   PROCEDURE GEN_TABLE_COL_FLD_SPECS_DML(
 1591                                         P_REF_TABLE           IN VARCHAR2,
 1592                                         P_TOPIC_RECORD_FORMAT IN VARCHAR2,
 1593                                         P_COLUMN_SPEC        OUT VARCHAR2,
 1594                                         P_FIELD_SPEC         OUT VARCHAR2,
 1595                                         P_SELECT_LIST_SPEC   OUT VARCHAR2
 1596   )
 1597   IS
 1598 
 1599     V_COLUMN_SPEC      VARCHAR2(32767);
 1600     V_FIELD_SPEC       VARCHAR2(32767);
 1601     V_SELECT_LIST_SPEC VARCHAR2(32767);
 1602 
 1603   BEGIN
 1604     
 1605     
 1606     V_COLUMN_SPEC := 
 1607       '"KAFKA$PARTITION" INTEGER, "KAFKA$OFFSET" NUMBER(38,0),' || 
 1608       '"KAFKA$EPOCH_TIMESTAMP" NUMBER(38,0)';
 1609     V_FIELD_SPEC  := 
 1610       '"KAFKA$PARTITION" CHAR, "KAFKA$OFFSET" CHAR, "KAFKA$EPOCH_TIMESTAMP" CHAR';
 1611     V_SELECT_LIST_SPEC := '"KAFKA$PARTITION", "KAFKA$OFFSET", "KAFKA$EPOCH_TIMESTAMP"';
 1612 
 1613     IF (P_TOPIC_RECORD_FORMAT = 'JSON_VARCHAR2') THEN
 1614       GENJSON_VC2_COLFLDSPECS(V_COLUMN_SPEC, V_FIELD_SPEC, 
 1615                               V_SELECT_LIST_SPEC);
 1616     ELSIF (P_TOPIC_RECORD_FORMAT = 'CSV') THEN
 1617       GENCSV_COLFLDSPECS(P_REF_TABLE, V_COLUMN_SPEC, V_FIELD_SPEC, 
 1618                           V_SELECT_LIST_SPEC);
 1619     ELSE
 1620       RAISE_APPLICATION_ERROR(-20000, 'Unsupported topic record format ' ||
 1621                                        P_TOPIC_RECORD_FORMAT );
 1622     END IF;
 1623 
 1624     
 1625 
 1626     P_COLUMN_SPEC := V_COLUMN_SPEC;
 1627     P_FIELD_SPEC  := V_FIELD_SPEC;
 1628     P_SELECT_LIST_SPEC := V_SELECT_LIST_SPEC;
 1629 
 1630   END;
 1631 
 1632   
 1633 
 1634 
 1635 
 1636 
 1637 
 1638   FUNCTION GET_BOOTSTRAP_SERVERS(P_CLUSTER_NAME VARCHAR2) RETURN VARCHAR2
 1639   IS
 1640     V_CLUSTERID  VARCHAR2(30);
 1641     V_BOOTSTRAP_SERVERS  VARCHAR2(4000) := NULL;
 1642     V_STMT0      VARCHAR2(4000);
 1643 
 1644   BEGIN
 1645     V_CLUSTERID   := UPPER(P_CLUSTER_NAME);
 1646 
 1647     V_STMT0 := 'SELECT bootstrap_servers FROM ora_kafka_cluster WHERE ' || 
 1648                 'cluster_name = :p_cluster_name';
 1649 
 1650     BEGIN
 1651       EXECUTE IMMEDIATE V_STMT0 INTO V_BOOTSTRAP_SERVERS USING V_CLUSTERID; 
 1652       EXCEPTION WHEN NO_DATA_FOUND THEN
 1653         NULL;
 1654     END; 
 1655 
 1656     IF V_BOOTSTRAP_SERVERS IS NULL THEN
 1657        RAISE_APPLICATION_ERROR(-20000, 
 1658          'Cluster ''' || P_CLUSTER_NAME || ''' not found.');
 1659     END IF;
 1660 
 1661     
 1662     BEGIN
 1663       CHECK_BOOTSTRAP_SERVERS(V_BOOTSTRAP_SERVERS);
 1664       EXCEPTION WHEN OTHERS THEN
 1665         RAISE_APPLICATION_ERROR(-20000, 
 1666           'The data fetched from ora_kafka_cluster is invalid', TRUE);
 1667     END;
 1668 
 1669     RETURN V_BOOTSTRAP_SERVERS;
 1670   END;
 1671 
 1672   
 1673 
 1674 
 1675 
 1676 
 1677 
 1678 
 1679 
 1680 
 1681   PROCEDURE GET_ORAKAFKA_DIRECTORIES(P_CLUSTER_NAME IN VARCHAR2,
 1682                                      P_LOCATION_DIR OUT VARCHAR2,
 1683                                      P_DEFAULT_DIR  OUT VARCHAR2,
 1684                                      P_CLUSTER_CONF_DIR OUT VARCHAR2)
 1685   IS
 1686   BEGIN
 1687     SELECT DEFAULT_DIRECTORY, LOCATION_DIRECTORY, CLUSTER_CONF_DIRECTORY
 1688         INTO P_DEFAULT_DIR, P_LOCATION_DIR, P_CLUSTER_CONF_DIR 
 1689         FROM ORA_KAFKA_CLUSTER
 1690         WHERE CLUSTER_NAME = UPPER(P_CLUSTER_NAME);
 1691     P_DEFAULT_DIR := CHECK_DEFAULT_DIRECTORY(P_DEFAULT_DIR);
 1692     P_LOCATION_DIR := CHECK_LOCATION_DIRECTORY(P_LOCATION_DIR);
 1693     P_CLUSTER_CONF_DIR := CHECK_CLUSTER_CONF_DIRECTORY(P_CLUSTER_CONF_DIR);
 1694     EXCEPTION WHEN OTHERS THEN
 1695       RAISE_APPLICATION_ERROR(-20000, 
 1696         'The data fetched from ora_kafka_cluster is invalid', TRUE);
 1697   END;
 1698 
 1699   
 1700 
 1701 
 1702 
 1703 
 1704 
 1705   FUNCTION GET_LOAD_COLUMNS(P_TARGET_TABLE IN VARCHAR2) RETURN VARCHAR2
 1706   IS
 1707     TYPE               USERTABCOLUMNTYPE IS REF CURSOR;
 1708     V_TARGET_TABLE     VARCHAR2(128);
 1709     V_DQ    CONSTANT   CHAR := '"';
 1710     V_COMMA CONSTANT   CHAR := ',';
 1711     V_UTC_CURSOR       USERTABCOLUMNTYPE;
 1712     V_UTC_STMT         VARCHAR2(4000);
 1713     V_COLUMN_NAME      VARCHAR2(128);
 1714     V_COLUMN_NAMES     VARCHAR2(4000);
 1715   BEGIN
 1716 
 1717     V_TARGET_TABLE := UPPER(P_TARGET_TABLE);
 1718 
 1719     V_UTC_STMT := 'SELECT column_name FROM sys.user_tab_columns ' || 
 1720        'WHERE table_name = :p_table_name ORDER BY column_id';
 1721     OPEN V_UTC_CURSOR FOR V_UTC_STMT USING V_TARGET_TABLE;
 1722  
 1723     LOOP
 1724       FETCH V_UTC_CURSOR INTO V_COLUMN_NAME;
 1725 
 1726       EXIT WHEN V_UTC_CURSOR%NOTFOUND;
 1727 
 1728       IF (V_COLUMN_NAMES IS NULL) THEN
 1729         V_COLUMN_NAMES := V_DQ || V_COLUMN_NAME || V_DQ;
 1730       ELSE
 1731         V_COLUMN_NAMES := V_COLUMN_NAMES || V_COMMA || V_DQ || V_COLUMN_NAME 
 1732                           || V_DQ; 
 1733       END IF;
 1734 
 1735     END LOOP;
 1736 
 1737     CLOSE V_UTC_CURSOR;
 1738 
 1739     RETURN V_COLUMN_NAMES;
 1740   END;
 1741 
 1742    
 1743 
 1744 
 1745 
 1746 
 1747   FUNCTION GET_LOCATION_DIR(P_CLUSTER_NAME IN VARCHAR2) RETURN VARCHAR2
 1748   IS
 1749     V_LOCATION_DIR VARCHAR2(128);
 1750   BEGIN
 1751     BEGIN
 1752       SELECT LOCATION_DIRECTORY INTO V_LOCATION_DIR FROM ORA_KAFKA_CLUSTER
 1753         WHERE CLUSTER_NAME = UPPER(P_CLUSTER_NAME);
 1754       V_LOCATION_DIR := CHECK_LOCATION_DIRECTORY(V_LOCATION_DIR);
 1755       EXCEPTION WHEN OTHERS THEN
 1756         RAISE_APPLICATION_ERROR(-20000, 
 1757           'The data fetched from ora_kafka_cluster is invalid', TRUE);
 1758     END;
 1759     RETURN V_LOCATION_DIR;
 1760   END;
 1761 
 1762   
 1763 
 1764 
 1765 
 1766 
 1767 
 1768   FUNCTION GET_PARTITION_COUNT(P_CLUSTER_NAME IN VARCHAR2, 
 1769                                P_TOPIC_NAME IN VARCHAR2) RETURN NUMBER
 1770   IS
 1771     V_STMT0 VARCHAR2(4000);
 1772     V_VIEW  VARCHAR2(4000);
 1773     V_KAFKA_ACCESS_ERROR_MSG VARCHAR2(4000);
 1774     V_KAFKA_MISSING_ERROR_MSG VARCHAR2(4000);
 1775     V_PARTITION_COUNT NUMBER;
 1776   BEGIN
 1777     V_KAFKA_ACCESS_ERROR_MSG := 'Error getting partition count for topic "' || 
 1778         P_TOPIC_NAME || '" from Kafka. Check Kafka cluster: ' || P_CLUSTER_NAME;
 1779     V_KAFKA_MISSING_ERROR_MSG := 'Error getting partition count for topic "' || 
 1780         P_TOPIC_NAME || '" from Kafka. Check that the topic exists in the Kafka cluster: ' || P_CLUSTER_NAME;
 1781 
 1782     BEGIN
 1783       V_VIEW := CHECK_SQL_OBJECT('topics_view', 
 1784                  'KV_' || UPPER(P_CLUSTER_NAME) || '_TOPICS');
 1785       V_STMT0 := 'SELECT partition_count FROM ' || V_VIEW ||
 1786                  ' WHERE topic_name = :p_topic_name';
 1787 
 1788       
 1789 
 1790       EXECUTE IMMEDIATE V_STMT0 INTO V_PARTITION_COUNT USING P_TOPIC_NAME;
 1791       IF (V_PARTITION_COUNT  < 1) THEN
 1792         RAISE_APPLICATION_ERROR(-20000, V_KAFKA_ACCESS_ERROR_MSG);    
 1793       END IF;
 1794 
 1795     EXCEPTION
 1796     WHEN NO_DATA_FOUND THEN
 1797         RAISE_APPLICATION_ERROR(-20000, V_KAFKA_MISSING_ERROR_MSG);
 1798  
 1799     WHEN OTHERS THEN
 1800         RAISE_APPLICATION_ERROR(-20000, V_KAFKA_ACCESS_ERROR_MSG);
 1801     END;
 1802 
 1803     RETURN V_PARTITION_COUNT;
 1804   END;
 1805 
 1806   
 1807 
 1808 
 1809 
 1810 
 1811 
 1812 
 1813 
 1814 
 1815 
 1816 
 1817 
 1818 
 1819 
 1820 
 1821 
 1822 
 1823 
 1824 
 1825 
 1826 
 1827 
 1828 
 1829    PROCEDURE PROPERTIES_TO_FILE(PROPERTIES IN PROPERTIES_TYPE,
 1830                               LOCATION   IN VARCHAR2,
 1831                               FILENAME   IN VARCHAR2,
 1832                               COMMENTS   IN VARCHAR2 DEFAULT NULL)
 1833   IS   
 1834     FILE   SYS.UTL_FILE.FILE_TYPE := NULL;
 1835     KEY    VARCHAR2(100);
 1836     KEY2   VARCHAR2(200);
 1837     VALUE  VARCHAR2(2000);
 1838 
 1839   BEGIN
 1840     FILE := SYS.UTL_FILE.FOPEN_NCHAR(LOCATION, FILENAME, 'w', 1200);
 1841 
 1842     
 1843     IF (COMMENTS IS NOT NULL) THEN
 1844       SYS.UTL_FILE.PUTF_NCHAR(FILE, '#%s\n', REPLACE(COMMENTS, NL, NL||'#'));
 1845     END IF;  
 1846 
 1847     
 1848     SYS.UTL_FILE.PUTF_NCHAR(FILE, '#%s\n', 
 1849              TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
 1850 
 1851     IF (PROPERTIES IS NOT NULL) THEN 
 1852       KEY := PROPERTIES.FIRST;
 1853       WHILE KEY IS NOT NULL LOOP
 1854         KEY2 := CONVERT_TO(KEY, TRUE);
 1855         VALUE := CONVERT_TO(PROPERTIES(KEY), FALSE);
 1856         SYS.UTL_FILE.PUTF_NCHAR(FILE, '%s=%s\n', KEY2, VALUE);
 1857         KEY := PROPERTIES.NEXT(KEY);
 1858       END LOOP;
 1859     END IF;  
 1860 
 1861     SYS.UTL_FILE.FFLUSH(FILE);
 1862     SYS.UTL_FILE.FCLOSE(FILE);
 1863 
 1864     EXCEPTION
 1865     WHEN OTHERS THEN
 1866       
 1867       IF SYS.UTL_FILE.IS_OPEN(FILE) THEN
 1868          SYS.UTL_FILE.FCLOSE(FILE);
 1869     END IF;
 1870 
 1871     $IF $$ORAKAFKATRC $THEN      
 1872       DBMS_OUTPUT.PUT_LINE('Error writing file: ' || FILENAME);
 1873     $END
 1874 
 1875       
 1876     RAISE;
 1877 
 1878   END; 
 1879 
 1880   
 1881 
 1882 
 1883 
 1884 
 1885 
 1886   FUNCTION PROPERTIES_FROM_FILE(LOCATION   IN VARCHAR2,
 1887                                FILENAME   IN VARCHAR2) 
 1888   RETURN PROPERTIES_TYPE 
 1889   IS
 1890     FILE  SYS.UTL_FILE.FILE_TYPE := NULL;
 1891     BUF   NVARCHAR2(2400);
 1892     LEN   PLS_INTEGER;
 1893     PROPS PROPERTIES_TYPE;
 1894     C     NCHAR(1);
 1895     KEY   VARCHAR2(100);
 1896     SLASH BOOLEAN;
 1897     SEP   PLS_INTEGER;
 1898   BEGIN
 1899     FILE := SYS.UTL_FILE.FOPEN_NCHAR(LOCATION, FILENAME, 'r', 4096);
 1900     LOOP
 1901     BEGIN
 1902        KEY := NULL;
 1903        SLASH := FALSE;
 1904        SEP := 0;
 1905 
 1906        
 1907        SYS.UTL_FILE.GET_LINE_NCHAR(FILE, BUF);
 1908        LEN := NVL(LENGTHC(BUF), 0);
 1909        FOR I IN 1..LEN LOOP
 1910          C := SUBSTRC(BUF, I, 1);
 1911          CASE C
 1912            WHEN '#' THEN
 1913            
 1914              BEGIN IF (I = 1 AND C = '#') THEN EXIT; END IF; END;
 1915            WHEN '=' THEN
 1916            
 1917              BEGIN IF NOT SLASH THEN SEP := I; EXIT; END IF; END;
 1918            WHEN '\' THEN SLASH := NOT SLASH;
 1919            ELSE SLASH := FALSE;
 1920          END CASE;
 1921        END LOOP;
 1922        
 1923        IF (SEP > 0) THEN
 1924          KEY := CONVERT_FROM(BUF, 1, SEP-1);
 1925          IF (KEY IS NOT NULL) THEN
 1926            PROPS(KEY) := CONVERT_FROM(BUF, SEP+1, LEN);
 1927          END IF;
 1928        END IF;
 1929        EXCEPTION  WHEN NO_DATA_FOUND THEN EXIT;
 1930     END;
 1931     END LOOP;
 1932 
 1933     SYS.UTL_FILE.FCLOSE(FILE);
 1934     RETURN PROPS;
 1935 
 1936   EXCEPTION
 1937    WHEN OTHERS THEN
 1938       
 1939       IF SYS.UTL_FILE.IS_OPEN(FILE) THEN
 1940          SYS.UTL_FILE.FCLOSE(FILE);
 1941       END IF;
 1942 
 1943     $IF $$ORAKAFKATRC $THEN      
 1944       DBMS_OUTPUT.PUT_LINE('Error reading file: ' || FILENAME);
 1945     $END
 1946 
 1947     
 1948     RAISE;
 1949   END;
 1950 
 1951   
 1952 
 1953 
 1954 
 1955 
 1956 
 1957 
 1958 
 1959 
 1960 
 1961 
 1962 
 1963 
 1964   PROCEDURE RAISE_MISSING_CGT_EXCEPTION(P_CLUSTER_NAME IN VARCHAR2,
 1965                                         P_GROUP_NAME   IN VARCHAR2,
 1966                                         P_TOPIC_NAME   IN VARCHAR2)
 1967   IS
 1968     V_BOOTSTRAP_SERVERS   VARCHAR2(4000);
 1969     V_CLUSTERID   VARCHAR2(30);
 1970     V_GROUP_CHECK NUMBER;
 1971     V_STMT0       VARCHAR2(4000);
 1972 
 1973   BEGIN
 1974     
 1975     V_BOOTSTRAP_SERVERS := GET_BOOTSTRAP_SERVERS(P_CLUSTER_NAME);
 1976 
 1977     V_CLUSTERID := UPPER(P_CLUSTER_NAME);
 1978 
 1979     V_STMT0 := 'SELECT 1 FROM ora_kafka_application WHERE ' || 
 1980                 'cluster_name = :p_cluster_name AND ' || 
 1981                 'group_name = :p_group_name';
 1982 
 1983     BEGIN
 1984       EXECUTE IMMEDIATE V_STMT0 INTO V_GROUP_CHECK 
 1985           USING V_CLUSTERID, P_GROUP_NAME; 
 1986       EXCEPTION WHEN NO_DATA_FOUND THEN
 1987         RAISE_APPLICATION_ERROR(-20000, 
 1988           'Group name ''' || P_GROUP_NAME || ''' not found.');
 1989         NULL;
 1990     END; 
 1991 
 1992     RAISE_APPLICATION_ERROR(-20000, 
 1993       'Topic name ''' || P_TOPIC_NAME || ''' not found.');
 1994 
 1995   END;
 1996 
 1997   
 1998 
 1999 
 2000 
 2001 
 2002 
 2003 
 2004 
 2005 
 2006 
 2007 
 2008 
 2009 
 2010 
 2011    FUNCTION SQL_TOPIC_NAME(P_TOPIC_NAME VARCHAR2) RETURN VARCHAR2
 2012    IS
 2013     V_STR          VARCHAR2(128);
 2014 
 2015    BEGIN
 2016 
 2017      
 2018      
 2019      
 2020      
 2021      
 2022      
 2023      
 2024      
 2025      
 2026      
 2027      
 2028      
 2029      
 2030      
 2031      
 2032      
 2033      
 2034      
 2035      
 2036      
 2037      
 2038      
 2039      
 2040      
 2041      
 2042      
 2043      
 2044      
 2045      
 2046      
 2047      
 2048      
 2049      
 2050      
 2051      
 2052      
 2053      
 2054      
 2055      
 2056      
 2057      
 2058 
 2059      
 2060      V_STR := REPLACE(TRIM(BOTH FROM P_TOPIC_NAME),'.', '#');  
 2061 
 2062      
 2063      V_STR := REPLACE(V_STR, '-', '#'); 
 2064 
 2065      
 2066      V_STR := CHECK_SIMPLE_SQL_NAME(P_TOPIC_NAME,
 2067                                     V_STR);
 2068 
 2069     RETURN UPPER(V_STR);
 2070   END;
 2071 
 2072   
 2073 
 2074 
 2075 
 2076 
 2077 
 2078   PROCEDURE VALIDATE_DIR_OBJECT_WITH_RW(P_DIRECTORY_NAME IN VARCHAR2)
 2079   IS
 2080      V_CNT INTEGER;
 2081   BEGIN
 2082 
 2083      SELECT COUNT(*) 
 2084      INTO V_CNT
 2085      FROM SYS.USER_TAB_PRIVS
 2086      WHERE TABLE_NAME = P_DIRECTORY_NAME AND
 2087            (PRIVILEGE = 'WRITE' OR PRIVILEGE = 'READ');
 2088 
 2089      IF (V_CNT != 2) THEN
 2090         RAISE_APPLICATION_ERROR(-20000, 'Directory ''' || P_DIRECTORY_NAME || 
 2091                ''' either does not exist or does not have' ||
 2092                ' READ and WRITE privileges granted to user');
 2093      ELSE
 2094        V_CNT := 0;
 2095        SELECT COUNT(*) 
 2096        INTO V_CNT
 2097        FROM SYS.USER_TAB_PRIVS
 2098        WHERE TABLE_NAME = P_DIRECTORY_NAME AND
 2099              PRIVILEGE = 'EXECUTE';
 2100        IF (V_CNT !=0) THEN
 2101         RAISE_APPLICATION_ERROR(-20000, 'Directory ''' || P_DIRECTORY_NAME || 
 2102                ''' has EXECUTE privilege granted to user,'  || 
 2103                ' revoke this privilege and try again');
 2104        END IF;         
 2105      END IF;         
 2106     
 2107   END;
 2108 
 2109   
 2110 
 2111 
 2112 
 2113 
 2114 
 2115   PROCEDURE VALIDATE_DIR_OBJECT_WITH_RX(P_DIRECTORY_NAME IN VARCHAR2)
 2116   IS
 2117     V_CNT INTEGER;
 2118   BEGIN
 2119     SELECT COUNT(*) 
 2120     INTO V_CNT
 2121     FROM SYS.USER_TAB_PRIVS
 2122     WHERE TABLE_NAME = P_DIRECTORY_NAME AND
 2123           (PRIVILEGE = 'READ' OR PRIVILEGE = 'EXECUTE');
 2124 
 2125     IF (V_CNT != 2) THEN
 2126        RAISE_APPLICATION_ERROR(-20000, 'Directory ''' || P_DIRECTORY_NAME || 
 2127               ''' either does not exist or does not have' || 
 2128               ' READ and EXECUTE privileges granted to user');
 2129      ELSE
 2130        V_CNT := 0;
 2131        SELECT COUNT(*) 
 2132        INTO V_CNT
 2133        FROM SYS.USER_TAB_PRIVS
 2134        WHERE TABLE_NAME = P_DIRECTORY_NAME AND
 2135              PRIVILEGE = 'WRITE';
 2136        IF (V_CNT !=0) THEN
 2137         RAISE_APPLICATION_ERROR(-20000, 'Directory ''' || P_DIRECTORY_NAME || 
 2138                ''' has WRITE privilege granted to user,'  || 
 2139                ' revoke this privilege and try again');
 2140        END IF;         
 2141      END IF;         
 2142   END;
 2143 
 2144   
 2145 
 2146 
 2147 
 2148 
 2149   PROCEDURE VALIDATE_KAFKA_VIEW(P_VIEW_NAME IN VARCHAR2)
 2150   IS
 2151     V_CNT INTEGER;
 2152   BEGIN
 2153     SELECT COUNT(*) INTO V_CNT FROM ORA_KAFKA_PARTITION
 2154     WHERE VIEW_NAME = P_VIEW_NAME;
 2155 
 2156     IF (V_CNT = 0) THEN
 2157       RAISE_APPLICATION_ERROR(-20000, 
 2158         'View ''' || P_VIEW_NAME || ''' is not found.');
 2159     END IF;
 2160   END;
 2161 
 2162 
 2163   
 2164 
 2165 
 2166 
 2167 
 2168 
 2169 
 2170 
 2171 
 2172   PROCEDURE VALIDATE_SEEKABLE_VIEW(P_VIEW_NAME    IN  VARCHAR2, 
 2173                                    P_CLUSTER_NAME OUT VARCHAR2,
 2174                                    P_GROUP_NAME   OUT VARCHAR2,
 2175                                    P_TOPIC_NAME   OUT VARCHAR2,
 2176                                    P_PARTITION_ID OUT INTEGER                                   
 2177                                    )
 2178   IS
 2179     V_NUM_VIEWS      INTEGER;
 2180     V_NUM_PARTITIONS INTEGER;
 2181     V_CNT            INTEGER;
 2182 
 2183   BEGIN
 2184 
 2185     
 2186     
 2187     SELECT COUNT(*)
 2188     INTO  V_CNT 
 2189     FROM  ORA_KAFKA_PARTITION
 2190     WHERE VIEW_NAME = P_VIEW_NAME;
 2191 
 2192     IF (V_CNT = 0) THEN
 2193       RAISE_APPLICATION_ERROR(-20000, 
 2194         'View ''' || P_VIEW_NAME || ''' is not found.');
 2195     END IF;
 2196 
 2197     
 2198     
 2199     
 2200     
 2201     
 2202     
 2203     SELECT DISTINCT CLUSTER_NAME, GROUP_NAME, TOPIC_NAME
 2204     INTO   P_CLUSTER_NAME, P_GROUP_NAME, P_TOPIC_NAME
 2205     FROM   ORA_KAFKA_PARTITION
 2206     WHERE  VIEW_NAME = P_VIEW_NAME;
 2207 
 2208     
 2209 
 2210     SELECT NUM_PARTITIONS, NUM_VIEWS
 2211     INTO  V_NUM_PARTITIONS, V_NUM_VIEWS
 2212     FROM  ORA_KAFKA_APPLICATION
 2213     WHERE CLUSTER_NAME = P_CLUSTER_NAME AND 
 2214           GROUP_NAME   = P_GROUP_NAME AND
 2215           TOPIC_NAME   = P_TOPIC_NAME;
 2216 
 2217     
 2218     IF (V_NUM_PARTITIONS != V_NUM_VIEWS) THEN
 2219       RAISE_APPLICATION_ERROR(-20000, 'View ''' || P_VIEW_NAME || 
 2220                               ''' does not support random access.  View' ||
 2221                               ' must have a 1 to 1 mapping of views to' ||
 2222                               ' partitions for random access support.');
 2223     END IF;
 2224 
 2225     
 2226     
 2227     SELECT CLUSTER_NAME, GROUP_NAME, TOPIC_NAME, PARTITION_ID 
 2228     INTO   P_CLUSTER_NAME, P_GROUP_NAME, P_TOPIC_NAME, P_PARTITION_ID
 2229     FROM   ORA_KAFKA_PARTITION
 2230     WHERE  VIEW_NAME = P_VIEW_NAME;
 2231 
 2232   END;
 2233 
 2234 
 2235   
 2236 
 2237 
 2238   FUNCTION MAX_VARCHAR2_SIZE 
 2239   RETURN INTEGER
 2240   IS
 2241     IGNORE VARCHAR2(4000);
 2242     LEN_TOO_LONG_EXCEPTION EXCEPTION;
 2243     PRAGMA EXCEPTION_INIT(LEN_TOO_LONG_EXCEPTION, -910);
 2244   BEGIN
 2245     
 2246 
 2247 
 2248 
 2249     EXECUTE IMMEDIATE 'select cast(dummy as varchar2(32767)) from sys.dual';
 2250     RETURN 32767;
 2251     EXCEPTION
 2252     WHEN LEN_TOO_LONG_EXCEPTION THEN
 2253       RETURN 4000;
 2254   END;
 2255 
 2256   
 2257   
 2258   
 2259 
 2260 END ORA_KAFKA_UTL;

Unwrap More Code

Copyright © 2019 Manuel Bleichenbacher. All Rights Reserved.

