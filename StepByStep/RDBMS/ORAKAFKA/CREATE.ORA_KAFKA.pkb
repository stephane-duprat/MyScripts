
Unwrap It!

Unwrap More Code

    1 PACKAGE BODY ora_kafka
    2 IS
    3 
    4   
    5   
    6   
    7 
    8   FUNCTION  GET_HEX_VALUE_FROM_JSON(P_JSON_STR   IN VARCHAR2,
    9                                     P_JSON_FIELD IN VARCHAR2)
   10   RETURN VARCHAR2;
   11 
   12   PROCEDURE UPDATE_OFFSET(
   13                    VIEW_NAME         IN VARCHAR2,
   14                    PROCESSED_RECORDS OUT INTEGER);
   15 
   16   
   17   
   18   
   19   
   20   PROCEDURE CREATE_VIEWS_PRIVATE (
   21                           VIEW_TYPE            IN  VARCHAR2,
   22                           CLUSTER_NAME         IN  VARCHAR2,
   23                           GROUP_NAME           IN  VARCHAR2,
   24                           TOPIC_NAME           IN  VARCHAR2,
   25                           TOPIC_RECORD_FORMAT  IN  VARCHAR2,
   26                           REF_TABLE            IN  VARCHAR2,                          
   27                           VIEWS_CREATED        OUT INTEGER, 
   28                           APPLICATION_ID       OUT VARCHAR2,
   29                           VIEW_COUNT           IN  INTEGER DEFAULT 0,
   30                           FORCE_VIEW_COUNT     IN  BOOLEAN DEFAULT FALSE,
   31                           VIEW_PROPERTIES      IN  VARCHAR2 DEFAULT NULL
   32   );
   33 
   34   
   35   
   36   
   37 
   38   
   39 
   40 
   41 
   42 
   43 
   44 
   45 
   46 
   47 
   48 
   49 
   50 
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
   62 
   63 
   64 
   65 
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
   79 
   80 
   81 
   82 
   83 
   84 
   85 
   86 
   87 
   88 
   89 
   90 
   91 
   92 
   93 
   94 
   95 
   96 
   97 
   98 
   99 
  100 
  101 
  102 
  103 
  104 
  105 
  106 
  107 
  108 
  109 
  110 
  111 
  112 
  113 
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
  129 
  130 
  131 
  132 
  133 
  134 
  135 
  136 
  137 
  138 
  139 
  140 
  141 
  142 
  143 
  144 
  145 
  146 
  147 
  148 
  149 
  150 
  151 
  152 
  153 
  154 
  155 
  156 
  157 
  158 
  159 
  160 
  161 
  162 
  163 
  164 
  165 
  166 
  167 
  168 
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
  180 
  181 
  182 
  183 
  184 
  185 
  186 
  187 
  188 
  189 
  190 
  191 
  192 
  193 
  194 
  195 
  196 
  197 
  198 
  199 
  200 
  201 
  202 
  203 
  204 
  205 
  206 
  207 
  208 
  209 
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
  225 
  226 
  227 
  228 
  229 
  230 
  231 
  232 
  233 
  234 
  235 
  236 
  237 
  238 
  239 
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
  256 
  257 
  258 
  259 
  260 
  261 
  262 
  263 
  264 
  265 
  266 
  267 
  268 
  269 
  270 
  271 
  272 
  273 
  274 
  275 
  276 
  277 
  278 
  279 
  280 
  281   PROCEDURE CREATE_VIEWS (
  282                           CLUSTER_NAME         IN  VARCHAR2,
  283                           GROUP_NAME           IN  VARCHAR2,
  284                           TOPIC_NAME           IN  VARCHAR2,
  285                           TOPIC_RECORD_FORMAT  IN  VARCHAR2,
  286                           REF_TABLE            IN  VARCHAR2,
  287                           VIEWS_CREATED        OUT INTEGER, 
  288                           APPLICATION_ID       OUT VARCHAR2,
  289                           VIEW_COUNT           IN  INTEGER DEFAULT 0,
  290                           FORCE_VIEW_COUNT     IN  BOOLEAN DEFAULT FALSE,
  291                           VIEW_PROPERTIES      IN  VARCHAR2 DEFAULT NULL
  292   ) IS
  293   BEGIN
  294 
  295    CREATE_VIEWS_PRIVATE ( ORA_KAFKA.VIEW_TYPE_APP,
  296                           CLUSTER_NAME,
  297                           GROUP_NAME,
  298                           TOPIC_NAME,
  299                           TOPIC_RECORD_FORMAT,
  300                           REF_TABLE,
  301                           VIEWS_CREATED,
  302                           APPLICATION_ID,
  303                           VIEW_COUNT,
  304                           FORCE_VIEW_COUNT,
  305                           VIEW_PROPERTIES);
  306     
  307   END;
  308 
  309 
  310   
  311 
  312 
  313 
  314 
  315 
  316 
  317 
  318 
  319 
  320 
  321 
  322 
  323 
  324 
  325 
  326 
  327 
  328 
  329 
  330 
  331 
  332 
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
  345 
  346 
  347 
  348 
  349 
  350 
  351 
  352 
  353 
  354 
  355 
  356 
  357 
  358 
  359 
  360 
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
  373 
  374 
  375   PROCEDURE CREATE_VIEWS_PRIVATE (
  376                           VIEW_TYPE            IN  VARCHAR2,
  377                           CLUSTER_NAME         IN  VARCHAR2,
  378                           GROUP_NAME           IN  VARCHAR2,
  379                           TOPIC_NAME           IN  VARCHAR2,
  380                           TOPIC_RECORD_FORMAT  IN  VARCHAR2,
  381                           REF_TABLE            IN  VARCHAR2,                          
  382                           VIEWS_CREATED        OUT INTEGER, 
  383                           APPLICATION_ID       OUT VARCHAR2,
  384                           VIEW_COUNT           IN  INTEGER DEFAULT 0,
  385                           FORCE_VIEW_COUNT     IN  BOOLEAN DEFAULT FALSE,
  386                           VIEW_PROPERTIES      IN  VARCHAR2 DEFAULT NULL
  387   )
  388   IS
  389     V_REF_TABLE VARCHAR2(4000);
  390     V_PARTITION_START NUMBER   := 0;
  391     V_BOOTSTRAP_SERVERS VARCHAR2(4000);    
  392     V_PARTITION_COUNT NUMBER;
  393     V_STMT0 VARCHAR2(4000);
  394     V_STMT1 VARCHAR2(4000);
  395     V_TOPIC_VIEW_NAME VARCHAR2(128);
  396     V_REF_TABLE_COUNT NUMBER := 0;
  397     V_PARTITIONS_PER_TABLE NUMBER;
  398     V_APPLICATION_EXIST NUMBER;
  399     V_CLUSTER_NAME VARCHAR2(30);
  400     V_GROUP_NAME VARCHAR2(30);
  401     V_TOPIC_NAME VARCHAR2(30); 
  402     V_TOPIC_RECORD_FORMAT VARCHAR2(30);
  403     V_VIEW_COUNT NUMBER := 0;
  404     V_FIELD_DELIM VARCHAR2(130); 
  405     V_RECORD_DELIM VARCHAR2(130); 
  406 
  407      
  408     
  409     DEFAULT_RECORD_DELIM VARCHAR2(4000) := '0X'
  410                            || DBMS_ASSERT.ENQUOTE_LITERAL('0A'); 
  411     
  412     DEFAULT_FIELD_DELIM_CSV VARCHAR2(4000) := '0X'
  413                            || DBMS_ASSERT.ENQUOTE_LITERAL('2C'); 
  414     
  415     DEFAULT_FIELD_DELIM_JSON VARCHAR2(4000) := '0X'
  416                            || DBMS_ASSERT.ENQUOTE_LITERAL('1F'); 
  417     PRAGMA AUTONOMOUS_TRANSACTION;
  418   BEGIN
  419     $IF $$ORAKAFKATRC $THEN      
  420      DBMS_OUTPUT.PUT_LINE('Enter procedure: CREATE_VIEWS....');     
  421     $END
  422 
  423     IF ( (VIEW_TYPE <> ORA_KAFKA.VIEW_TYPE_APP) AND 
  424          (VIEW_TYPE <> ORA_KAFKA.VIEW_TYPE_LOAD_TABLE) )
  425     THEN
  426        RAISE_APPLICATION_ERROR(-20000, 
  427          'Internal Error: view_type must be set to '
  428          || ORA_KAFKA.VIEW_TYPE_APP 
  429          || ' or ' || ORA_KAFKA.VIEW_TYPE_LOAD_TABLE); 
  430     END IF;
  431 
  432 
  433     
  434     
  435 
  436     V_CLUSTER_NAME := 
  437         ORA_KAFKA_UTL.CHECK_SQL_NAME_FRAGMENT('cluster_name',
  438                                                 CLUSTER_NAME, 
  439                                                 TRUE);
  440 
  441     
  442     
  443     
  444     
  445 
  446     V_GROUP_NAME := ORA_KAFKA_UTL.CHECK_SQL_NAME_FRAGMENT('group_name',
  447                                                             GROUP_NAME, 
  448                                                             FALSE);
  449 
  450     ORA_KAFKA_UTL.CHECK_TOPIC_NAME('topic_name',
  451                                     TOPIC_NAME);
  452 
  453     
  454     V_TOPIC_NAME := TOPIC_NAME;
  455 
  456     IF (REF_TABLE IS NOT NULL)
  457     THEN
  458       V_REF_TABLE := ORA_KAFKA_UTL.CHECK_SQL_OBJECT('ref_table',
  459                                                       REF_TABLE);
  460     END IF;
  461 
  462      
  463     V_BOOTSTRAP_SERVERS := ORA_KAFKA_UTL.GET_BOOTSTRAP_SERVERS(V_CLUSTER_NAME);
  464 
  465     
  466     
  467     V_PARTITION_COUNT := ORA_KAFKA_UTL.GET_PARTITION_COUNT(V_CLUSTER_NAME, 
  468                                                            TOPIC_NAME);
  469 
  470    
  471     
  472     
  473 
  474     V_TOPIC_RECORD_FORMAT := UPPER(TOPIC_RECORD_FORMAT);
  475 
  476     IF (V_TOPIC_RECORD_FORMAT IS NULL) OR
  477        ((V_TOPIC_RECORD_FORMAT <> TOPIC_FORMAT_CSV) AND 
  478         (V_TOPIC_RECORD_FORMAT <> TOPIC_FORMAT_JSON_VARCHAR2))
  479     THEN
  480        RAISE_APPLICATION_ERROR(-20000, 
  481          'TOPIC_RECORD_FORMAT must be set to ' || TOPIC_FORMAT_CSV || 
  482          ' or ' || TOPIC_FORMAT_JSON_VARCHAR2 || '.' 
  483          || ' User supplied value is ' || TOPIC_RECORD_FORMAT);
  484     END IF;
  485           
  486     IF (VIEW_COUNT < 0)
  487     THEN
  488        RAISE_APPLICATION_ERROR(-20000, 
  489          'VIEW_COUNT must be equal to or greater than 0.'
  490          || ' User supplied value is ' || VIEW_COUNT);
  491     END IF;
  492 
  493     IF (VIEW_COUNT > V_PARTITION_COUNT)
  494     THEN
  495        RAISE_APPLICATION_ERROR(-20000, 
  496          'VIEW_COUNT must be equal or less than '|| 
  497          'the partition count of the topic.' || ' User supplied value is ' || 
  498          VIEW_COUNT || 'The partition count is '|| V_PARTITION_COUNT);
  499     END IF;
  500 
  501     
  502 
  503     IF (VIEW_COUNT = 0)
  504     THEN
  505        V_VIEW_COUNT := V_PARTITION_COUNT;
  506     ELSE 
  507        V_VIEW_COUNT := VIEW_COUNT;
  508     END IF;
  509 
  510    
  511 
  512 
  513 
  514 
  515 
  516 
  517 
  518 
  519 
  520 
  521 
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
  534     $IF $$ORAKAFKATRC $THEN      
  535      DBMS_OUTPUT.PUT_LINE('view_properties:' || VIEW_PROPERTIES);
  536     $END
  537     
  538     
  539     
  540     
  541     
  542     
  543     
  544     
  545     
  546     IF (VIEW_PROPERTIES IS NOT NULL)
  547     THEN
  548       V_FIELD_DELIM := GET_HEX_VALUE_FROM_JSON(VIEW_PROPERTIES,'field_delim');
  549       IF (V_FIELD_DELIM IS NOT NULL) THEN
  550         V_FIELD_DELIM := '0X' || 
  551                           DBMS_ASSERT.ENQUOTE_LITERAL(V_FIELD_DELIM); 
  552       END IF;
  553 
  554       V_RECORD_DELIM := GET_HEX_VALUE_FROM_JSON(VIEW_PROPERTIES,'record_delim');
  555       IF (V_RECORD_DELIM IS NOT NULL) THEN
  556         V_RECORD_DELIM := '0X' || 
  557                           DBMS_ASSERT.ENQUOTE_LITERAL(V_RECORD_DELIM); 
  558       END IF;
  559     END IF;
  560 
  561 
  562     
  563     IF (V_TOPIC_RECORD_FORMAT = ORA_KAFKA.TOPIC_FORMAT_CSV) 
  564     THEN
  565       IF (V_FIELD_DELIM IS NULL ) THEN
  566         V_FIELD_DELIM := DEFAULT_FIELD_DELIM_CSV; 
  567       END IF;
  568 
  569       IF (V_RECORD_DELIM IS NULL ) THEN
  570         V_RECORD_DELIM := DEFAULT_RECORD_DELIM; 
  571       END IF;  
  572     ELSIF (V_TOPIC_RECORD_FORMAT = ORA_KAFKA.TOPIC_FORMAT_JSON_VARCHAR2)
  573     THEN
  574       IF (V_FIELD_DELIM IS NULL ) THEN
  575         V_FIELD_DELIM := DEFAULT_FIELD_DELIM_JSON;
  576       END IF;
  577 
  578       IF (V_RECORD_DELIM IS NULL ) THEN
  579         V_RECORD_DELIM := DEFAULT_RECORD_DELIM;
  580       END IF;
  581     END IF;
  582 
  583     
  584     
  585     $IF $$ORAKAFKATRC $THEN 
  586       DBMS_OUTPUT.PUT_LINE('field_delim for ext tab: ' 
  587                             || V_FIELD_DELIM );
  588       DBMS_OUTPUT.PUT_LINE('record_delim for ext tab: '
  589                             || V_RECORD_DELIM );
  590     $END
  591 
  592 
  593     IF (MOD(V_PARTITION_COUNT, V_VIEW_COUNT) <> 0)
  594     THEN
  595         IF (FORCE_VIEW_COUNT = FALSE)
  596         THEN
  597            RAISE_APPLICATION_ERROR(-20000, 'Cannot balance ' || 
  598              V_PARTITION_COUNT ||
  599              ' topic partitions among ' || 
  600              V_VIEW_COUNT || 
  601              ' views');
  602         END IF;
  603     END IF;
  604 
  605     V_STMT1 := 
  606       'SELECT count(*) FROM sys.user_tables WHERE table_name = :table_name';
  607 
  608     
  609     IF (V_TOPIC_RECORD_FORMAT = TOPIC_FORMAT_CSV)
  610     THEN
  611 
  612         EXECUTE IMMEDIATE V_STMT1 INTO V_REF_TABLE_COUNT USING V_REF_TABLE;
  613 
  614         IF (V_REF_TABLE_COUNT <> 1)
  615         THEN
  616            RAISE_APPLICATION_ERROR(-20000, 'Reference table ' || V_REF_TABLE || 
  617                               ' does not exist');
  618         END IF;
  619     END IF;
  620     
  621     SELECT COUNT(*) INTO V_APPLICATION_EXIST FROM ORA_KAFKA_APPLICATION 
  622         WHERE CLUSTER_NAME = V_CLUSTER_NAME AND
  623               GROUP_NAME = V_GROUP_NAME AND
  624               TOPIC_NAME = V_TOPIC_NAME;
  625     
  626     IF (V_APPLICATION_EXIST > 0) THEN
  627        RAISE_APPLICATION_ERROR(-20000, 'Kafka views already exist.  ' || 
  628          'Execute ORA_KAFKA.DROP_VIEWS(''' || V_CLUSTER_NAME ||''', ''' ||
  629          V_GROUP_NAME || ''', ''' || TOPIC_NAME || 
  630          ''') to remove existing views.');
  631     END IF;
  632 
  633     V_PARTITIONS_PER_TABLE := CEIL(V_PARTITION_COUNT / V_VIEW_COUNT);
  634 
  635     FOR V_VIEW_INDEX IN 0..(V_VIEW_COUNT - 1) LOOP
  636 
  637       ORA_KAFKA_UTL.CREATE_CGTP_VIEW(V_CLUSTER_NAME, 
  638                                       V_GROUP_NAME, 
  639                                       TOPIC_NAME,
  640                                       V_TOPIC_RECORD_FORMAT,
  641                                       V_VIEW_INDEX,
  642                                       V_PARTITION_START,
  643                                       V_PARTITIONS_PER_TABLE,
  644                                       0,
  645                                       V_REF_TABLE,
  646                                       V_BOOTSTRAP_SERVERS,
  647                                       V_FIELD_DELIM,
  648                                       V_RECORD_DELIM);
  649      
  650       V_PARTITION_START := V_PARTITION_START + V_PARTITIONS_PER_TABLE;
  651       IF (V_VIEW_COUNT - 1 - V_VIEW_INDEX) * 
  652          (FLOOR(V_PARTITION_COUNT / V_VIEW_COUNT)) = 
  653          (V_PARTITION_COUNT - V_PARTITION_START) 
  654       THEN
  655          V_PARTITIONS_PER_TABLE := FLOOR(V_PARTITION_COUNT / V_VIEW_COUNT);
  656       END IF;
  657     END LOOP;
  658     
  659     VIEWS_CREATED := V_VIEW_COUNT;
  660     APPLICATION_ID := UPPER('KV_' || V_CLUSTER_NAME || '_' || V_GROUP_NAME || 
  661                      '_' || ORA_KAFKA_UTL.SQL_TOPIC_NAME(TOPIC_NAME));
  662     
  663     
  664     
  665 
  666     ORA_KAFKA_UTL.CREATE_TOPIC_PARTITION_VIEW(V_CLUSTER_NAME,
  667                                               TOPIC_NAME,
  668                                               V_BOOTSTRAP_SERVERS);
  669 
  670     BEGIN
  671       INSERT INTO ORA_KAFKA_APPLICATION 
  672       VALUES 
  673           (V_CLUSTER_NAME, 
  674            V_GROUP_NAME,
  675            TOPIC_NAME,
  676            V_TOPIC_RECORD_FORMAT, 
  677            V_FIELD_DELIM, 
  678            V_RECORD_DELIM, 
  679            V_REF_TABLE,
  680            VIEWS_CREATED,
  681            0,
  682            V_PARTITION_COUNT,
  683            VIEW_TYPE);
  684 
  685       V_PARTITION_START := 0;
  686       V_PARTITIONS_PER_TABLE := CEIL(V_PARTITION_COUNT / V_VIEW_COUNT);
  687 
  688       FOR V_VIEW_INDEX IN 0..(V_VIEW_COUNT - 1) LOOP
  689         FOR V_PART_ID IN V_PARTITION_START .. V_PARTITION_START + 
  690                          V_PARTITIONS_PER_TABLE - 1 LOOP
  691           INSERT INTO ORA_KAFKA_PARTITION VALUES (V_CLUSTER_NAME, 
  692                                                    V_GROUP_NAME, 
  693                                                    TOPIC_NAME, 
  694                                                    V_PART_ID, 
  695                                                    V_VIEW_INDEX, 
  696                                                    0,
  697                                                    APPLICATION_ID || '_' || 
  698                                                      V_VIEW_INDEX
  699                                                    );
  700         END LOOP;
  701         V_PARTITION_START := V_PARTITION_START + V_PARTITIONS_PER_TABLE;
  702         IF (V_VIEW_COUNT - 1 - V_VIEW_INDEX) * 
  703             (FLOOR(V_PARTITION_COUNT / V_VIEW_COUNT)) = 
  704             (V_PARTITION_COUNT - V_PARTITION_START) THEN
  705            V_PARTITIONS_PER_TABLE := FLOOR(V_PARTITION_COUNT / V_VIEW_COUNT);
  706         END IF;
  707       END LOOP;
  708       COMMIT;
  709 
  710     EXCEPTION WHEN OTHERS THEN
  711       ROLLBACK;
  712       ORA_KAFKA_UTL.DROP_VIEWS_TABLES_LOCATIONS(V_CLUSTER_NAME, V_GROUP_NAME,
  713                                                 TOPIC_NAME);
  714       RAISE;
  715     END;
  716                                                                                                  
  717   END;
  718 
  719   
  720 
  721 
  722 
  723 
  724 
  725 
  726 
  727 
  728 
  729 
  730 
  731 
  732 
  733 
  734 
  735 
  736 
  737   PROCEDURE DROP_CLUSTER (
  738                           CLUSTER_NAME  IN VARCHAR2,
  739                           CASCADE       IN BOOLEAN DEFAULT TRUE
  740   )
  741   IS
  742     V_CLUSTER_EXIST INTEGER;
  743     V_LOCATION_DIR  VARCHAR2(128);
  744     V_CLUSTER_NAME  VARCHAR2(30);
  745     PRAGMA AUTONOMOUS_TRANSACTION;
  746   BEGIN
  747 
  748 
  749     
  750     
  751 
  752     V_CLUSTER_NAME := ORA_KAFKA_UTL.CHECK_SQL_NAME_FRAGMENT('cluster_name',
  753                                                               CLUSTER_NAME, 
  754                                                               TRUE);
  755 
  756     SELECT COUNT(*) INTO V_CLUSTER_EXIST FROM ORA_KAFKA_CLUSTER 
  757         WHERE CLUSTER_NAME = V_CLUSTER_NAME;
  758 
  759     IF (V_CLUSTER_EXIST = 0) THEN
  760        RAISE_APPLICATION_ERROR(-20000, 
  761          'Cluster ''' || V_CLUSTER_NAME || ''' not found.'); 
  762     END IF;
  763    
  764     V_LOCATION_DIR := ORA_KAFKA_UTL.GET_LOCATION_DIR(V_CLUSTER_NAME);
  765     IF (CASCADE) THEN
  766        FOR CUR IN (SELECT * FROM ORA_KAFKA_APPLICATION 
  767                    WHERE CLUSTER_NAME = V_CLUSTER_NAME)
  768        LOOP
  769           DROP_VIEWS(V_CLUSTER_NAME, CUR.GROUP_NAME, CUR.TOPIC_NAME);
  770        END LOOP;
  771     END IF;
  772 
  773     
  774     BEGIN
  775       DELETE FROM ORA_KAFKA_CLUSTER WHERE CLUSTER_NAME = V_CLUSTER_NAME;
  776       COMMIT;
  777 
  778     EXCEPTION WHEN OTHERS THEN
  779       IF SQLCODE = -2292 THEN
  780         
  781         RAISE_APPLICATION_ERROR(-20000, 
  782            'Cannot drop cluster ''' || CLUSTER_NAME || 
  783            '''.  Some topic views are created on this cluster.' || 
  784            '  Drop these views first or pass parameter CASCADE as TRUE.');
  785       ELSE
  786         RAISE;
  787       END IF;
  788     END;
  789 
  790 
  791     ORA_KAFKA_UTL.DROP_OBJECT_IF_EXIST(
  792         'view', 'KV_' || V_CLUSTER_NAME || '_TOPICS');
  793     ORA_KAFKA_UTL.DROP_OBJECT_IF_EXIST(
  794         'table', 'KX$' || V_CLUSTER_NAME || '_TOPICS');
  795     ORA_KAFKA_UTL.DELETE_LOCATION_FILE(V_LOCATION_DIR,
  796         'KX_' || V_CLUSTER_NAME || '_TOPICS.loc');
  797   END;
  798 
  799   
  800 
  801 
  802 
  803 
  804 
  805 
  806 
  807 
  808 
  809   PROCEDURE DROP_VIEWS(CLUSTER_NAME IN VARCHAR2,
  810                        GROUP_NAME   IN VARCHAR2,
  811                        TOPIC_NAME   IN VARCHAR2)
  812   IS
  813     V_LOCATION_DIR        VARCHAR2(128);
  814     V_TOPICAPPCOUNT       NUMBER := 0;
  815     V_CLUSTER_NAME        VARCHAR2(30);
  816     V_GROUP_NAME          VARCHAR2(30);
  817     V_TOPIC_NAME          VARCHAR2(30); 
  818     V_SQL_TOPIC_NAME      VARCHAR2(30);
  819 
  820     PRAGMA AUTONOMOUS_TRANSACTION;
  821   BEGIN
  822 
  823     
  824     
  825     V_CLUSTER_NAME := ORA_KAFKA_UTL.CHECK_SQL_NAME_FRAGMENT('cluster_name',
  826                                                              CLUSTER_NAME, 
  827                                                              TRUE);
  828 
  829     
  830     
  831     
  832     V_GROUP_NAME := ORA_KAFKA_UTL.CHECK_SQL_NAME_FRAGMENT('group_name',
  833                                                            GROUP_NAME, 
  834                                                            FALSE);
  835     ORA_KAFKA_UTL.CHECK_TOPIC_NAME('topic_name', 
  836                                     TOPIC_NAME);
  837 
  838     V_TOPIC_NAME := TOPIC_NAME;
  839 
  840     ORA_KAFKA_UTL.DROP_VIEWS_TABLES_LOCATIONS(V_CLUSTER_NAME,
  841                                               V_GROUP_NAME, 
  842                                               TOPIC_NAME);
  843 
  844     DELETE FROM ORA_KAFKA_PARTITION 
  845         WHERE CLUSTER_NAME = V_CLUSTER_NAME AND 
  846               GROUP_NAME = V_GROUP_NAME AND 
  847               TOPIC_NAME = V_TOPIC_NAME;
  848 
  849 
  850     DELETE FROM ORA_KAFKA_APPLICATION 
  851         WHERE CLUSTER_NAME = V_CLUSTER_NAME AND 
  852               GROUP_NAME = V_GROUP_NAME AND 
  853               TOPIC_NAME = V_TOPIC_NAME;
  854     COMMIT;
  855 
  856     
  857 
  858 
  859     SELECT COUNT(*) INTO V_TOPICAPPCOUNT 
  860     FROM ORA_KAFKA_APPLICATION 
  861     WHERE CLUSTER_NAME = V_CLUSTER_NAME
  862     AND   TOPIC_NAME = V_TOPIC_NAME;
  863 
  864     
  865 
  866 
  867 
  868     
  869     V_SQL_TOPIC_NAME := ORA_KAFKA_UTL.SQL_TOPIC_NAME(TOPIC_NAME);
  870     
  871     IF (V_TOPICAPPCOUNT = 0) THEN
  872       ORA_KAFKA_UTL.DROP_OBJECT_IF_EXIST('view', 
  873           UPPER('KV_' || V_CLUSTER_NAME || '_' || 
  874                  V_SQL_TOPIC_NAME || 
  875                 '_PARTITIONS'));
  876 
  877       ORA_KAFKA_UTL.DROP_OBJECT_IF_EXIST('table', 
  878           UPPER('KX$' || V_CLUSTER_NAME || '_' || 
  879                  V_SQL_TOPIC_NAME || 
  880                 '_PARTITIONS'));
  881 
  882       V_LOCATION_DIR := ORA_KAFKA_UTL.GET_LOCATION_DIR(CLUSTER_NAME);
  883       ORA_KAFKA_UTL.DELETE_LOCATION_FILE(V_LOCATION_DIR,
  884           UPPER('KX_' || V_CLUSTER_NAME || '_' || 
  885                  V_SQL_TOPIC_NAME || 
  886                 '_PARTITIONS') || '.loc');
  887     END IF;
  888 
  889   END;
  890 
  891   
  892 
  893 
  894 
  895 
  896 
  897 
  898 
  899 
  900 
  901 
  902 
  903 
  904 
  905 
  906 
  907 
  908 
  909 
  910 
  911 
  912 
  913 
  914 
  915 
  916 
  917 
  918 
  919 
  920 
  921 
  922 
  923 
  924 
  925 
  926 
  927 
  928 
  929 
  930 
  931 
  932 
  933 
  934 
  935 
  936 
  937 
  938 
  939 
  940   PROCEDURE INIT_OFFSET (
  941                          VIEW_NAME           IN VARCHAR2,
  942                          RECORD_COUNT        IN INTEGER,
  943                          WATER_MARK          IN VARCHAR2 
  944                                                 DEFAULT WATER_MARK_HIGH)
  945   IS
  946     TYPE                   PARTITIONSTYPE IS REF CURSOR;
  947     V_VIEW_NAME            VARCHAR2(4000);
  948     V_PARTITIONS_VIEW_NAME VARCHAR2(4000);
  949     V_PARTITIONS_STMT      VARCHAR2(4000);
  950     V_PARTITIONS_CUR       PARTITIONSTYPE;
  951     V_LOW_WATER_MARK       INTEGER;
  952     V_HIGH_WATER_MARK      INTEGER;
  953     V_OFFSET               INTEGER;
  954 
  955   BEGIN
  956 
  957     
  958 
  959     IF (RECORD_COUNT < 0) THEN
  960         RAISE_APPLICATION_ERROR(-20000, 
  961            'RECORD_COUNT must be 0 or greater.  User supplied value is ' ||
  962            RECORD_COUNT);
  963     END IF;
  964 
  965     IF ((WATER_MARK != WATER_MARK_HIGH) AND 
  966         (WATER_MARK != WATER_MARK_LOW)) THEN
  967         RAISE_APPLICATION_ERROR(-20000, 
  968            'WATER_MARK must be ORA_KAFKA.WATER_MARK_HIGH (' || 
  969            WATER_MARK_HIGH || ') or ORA_KAFKA.WATER_MARK_LOW (' ||
  970            WATER_MARK_LOW ||').  User supplied value is ' || WATER_MARK);
  971     END IF;
  972 
  973     V_VIEW_NAME := ORA_KAFKA_UTL.CHECK_SQL_OBJECT('view_name',
  974                                                     VIEW_NAME);
  975     
  976     ORA_KAFKA_UTL.VALIDATE_KAFKA_VIEW(V_VIEW_NAME); 
  977 
  978     
  979     FOR CUR IN (SELECT * FROM ORA_KAFKA_PARTITION 
  980                 WHERE VIEW_NAME = V_VIEW_NAME) LOOP
  981 
  982         
  983         V_PARTITIONS_VIEW_NAME := ORA_KAFKA_UTL.CHECK_SQL_OBJECT(
  984             'partitions_view_name',
  985             'KV_' || ORA_KAFKA_UTL.FORMAT_CTP_NAME(CUR.CLUSTER_NAME,
  986                                                     CUR.TOPIC_NAME));
  987         V_PARTITIONS_STMT := 
  988             'SELECT low_water_mark, high_water_mark FROM ' ||
  989             V_PARTITIONS_VIEW_NAME || ' WHERE partition_id = :partition_id';
  990 
  991         OPEN V_PARTITIONS_CUR FOR V_PARTITIONS_STMT USING CUR.PARTITION_ID;
  992 
  993         
  994         LOOP
  995             FETCH V_PARTITIONS_CUR INTO V_LOW_WATER_MARK, V_HIGH_WATER_MARK;
  996 
  997             EXIT WHEN V_PARTITIONS_CUR%NOTFOUND;
  998 
  999             
 1000             
 1001             IF (WATER_MARK = WATER_MARK_HIGH) THEN 
 1002                 V_OFFSET := V_HIGH_WATER_MARK - RECORD_COUNT;
 1003                 IF (V_OFFSET < V_LOW_WATER_MARK) THEN
 1004                     V_OFFSET := V_LOW_WATER_MARK;
 1005                 END IF;
 1006             ELSE
 1007                 V_OFFSET := V_LOW_WATER_MARK + RECORD_COUNT;
 1008                 IF (V_OFFSET > V_HIGH_WATER_MARK) THEN
 1009                     V_OFFSET := V_HIGH_WATER_MARK;
 1010                 END IF;
 1011             END IF;
 1012 
 1013             
 1014             UPDATE ORA_KAFKA_PARTITION SET COMMITTED_OFFSET = V_OFFSET
 1015                 WHERE VIEW_NAME = CUR.VIEW_NAME AND 
 1016                       PARTITION_ID = CUR.PARTITION_ID;
 1017             
 1018         END LOOP;
 1019     END LOOP;
 1020 
 1021   END;
 1022 
 1023   
 1024 
 1025 
 1026 
 1027 
 1028 
 1029 
 1030 
 1031 
 1032 
 1033 
 1034 
 1035 
 1036 
 1037 
 1038 
 1039 
 1040 
 1041 
 1042 
 1043 
 1044 
 1045 
 1046 
 1047 
 1048    PROCEDURE LOAD_TABLE (
 1049                         CLUSTER_NAME            IN VARCHAR2,
 1050                         GROUP_NAME              IN VARCHAR2,
 1051                         TOPIC_NAME              IN VARCHAR2,
 1052                         TOPIC_RECORD_FORMAT     IN VARCHAR2,
 1053                         TARGET_TABLE            IN VARCHAR2,
 1054                         RECORDS_LOADED         OUT INTEGER)
 1055    IS
 1056      V_VIEW_TYPE VARCHAR2(4000);
 1057      V_BOOTSTRAP_SERVERS VARCHAR2(4000);    
 1058      V_PARTITION_COUNT NUMBER;
 1059      V_VIEW_NAME VARCHAR2(128);
 1060      V_VIEW_NAME_PREFIX  VARCHAR2(128);
 1061      V_STMT0 VARCHAR2(4000);
 1062      V_SELECT_COLUMNS VARCHAR2(4000);
 1063      V_STARTED_TIME TIMESTAMP WITH TIME ZONE;
 1064      V_FINISHED_TIME TIMESTAMP  WITH TIME ZONE;
 1065      V_TOTAL_ROWS NUMBER := 0;
 1066      V_VIEWS_CREATED INTEGER;
 1067      V_TARGET_TABLE VARCHAR2(4000);
 1068      V_CLUSTER_NAME VARCHAR2(30);
 1069      V_GROUP_NAME   VARCHAR2(30);
 1070      V_TOPIC_NAME     VARCHAR2(30);     
 1071 
 1072    BEGIN
 1073 
 1074 
 1075      
 1076      
 1077      V_CLUSTER_NAME := ORA_KAFKA_UTL.CHECK_SQL_NAME_FRAGMENT('cluster_name',
 1078                                                                CLUSTER_NAME, 
 1079                                                                TRUE);
 1080 
 1081      
 1082      
 1083      
 1084      V_GROUP_NAME   := ORA_KAFKA_UTL.CHECK_SQL_NAME_FRAGMENT('group_name',
 1085                                                                GROUP_NAME, 
 1086                                                                FALSE);
 1087 
 1088      ORA_KAFKA_UTL.CHECK_TOPIC_NAME('topic_name', 
 1089                                      TOPIC_NAME);
 1090 
 1091      V_TARGET_TABLE := ORA_KAFKA_UTL.CHECK_SQL_OBJECT(
 1092                                                   'target_table',
 1093                                                    TARGET_TABLE);
 1094 
 1095      
 1096      V_TOPIC_NAME := TOPIC_NAME;
 1097 
 1098 
 1099     BEGIN
 1100      SELECT VIEW_TYPE INTO V_VIEW_TYPE
 1101      FROM ORA_KAFKA_APPLICATION
 1102      WHERE CLUSTER_NAME = V_CLUSTER_NAME AND
 1103            GROUP_NAME = V_GROUP_NAME AND
 1104            TOPIC_NAME = V_TOPIC_NAME;
 1105 
 1106      
 1107      
 1108      
 1109      IF (V_VIEW_TYPE <> ORA_KAFKA.VIEW_TYPE_LOAD_TABLE) THEN
 1110           RAISE_APPLICATION_ERROR(-20000,
 1111           'Kafka views exist for the specified cluster,group and topic;' ||
 1112           ' LOAD_TABLE operation not allowed for Kafka views' || 
 1113           ' not created by LOAD_TABLE procedure.'); 
 1114      END IF;
 1115                
 1116      EXCEPTION
 1117      WHEN NO_DATA_FOUND THEN
 1118        
 1119        
 1120        
 1121        
 1122        
 1123 
 1124        
 1125 
 1126        CREATE_VIEWS_PRIVATE(
 1127                     ORA_KAFKA.VIEW_TYPE_LOAD_TABLE,
 1128                     V_CLUSTER_NAME,
 1129                     V_GROUP_NAME,
 1130                     TOPIC_NAME,
 1131                     TOPIC_RECORD_FORMAT,
 1132                     V_TARGET_TABLE, 
 1133                     V_VIEWS_CREATED,
 1134                     V_VIEW_NAME_PREFIX,
 1135                     1,
 1136                     TRUE);
 1137 
 1138      END;
 1139       
 1140      
 1141      
 1142 
 1143      V_VIEW_NAME := UPPER('KV_' || V_CLUSTER_NAME || '_' || V_GROUP_NAME ||
 1144                           '_' || ORA_KAFKA_UTL.SQL_TOPIC_NAME(TOPIC_NAME) || '_0');
 1145  
 1146      NEXT_OFFSET(V_VIEW_NAME);
 1147 
 1148      BEGIN
 1149 
 1150        V_SELECT_COLUMNS := ORA_KAFKA_UTL.GET_LOAD_COLUMNS(V_TARGET_TABLE);
 1151 
 1152        
 1153        SAVEPOINT ORA_KAFKA_LOAD_TABLE_190909;
 1154 
 1155        V_STMT0 := 'INSERT INTO ' || V_TARGET_TABLE || 
 1156                    ' (' || V_SELECT_COLUMNS  || ') SELECT ' ||
 1157                    V_SELECT_COLUMNS || ' FROM ' ||  V_VIEW_NAME;
 1158        
 1159        V_STARTED_TIME := CURRENT_TIMESTAMP;
 1160        EXECUTE IMMEDIATE V_STMT0;
 1161        V_FINISHED_TIME := CURRENT_TIMESTAMP;
 1162        RECORDS_LOADED := SQL%ROWCOUNT;
 1163 
 1164        UPDATE_OFFSET(V_VIEW_NAME, V_TOTAL_ROWS);
 1165 
 1166      EXCEPTION WHEN OTHERS THEN
 1167        ROLLBACK TO ORA_KAFKA_LOAD_TABLE_190909;
 1168        RAISE;
 1169      END;
 1170      
 1171      INSERT INTO ORA_KAFKA_LOAD_METRICS VALUES
 1172          (V_CLUSTER_NAME, V_GROUP_NAME, V_TOPIC_NAME, V_TARGET_TABLE, 
 1173           RECORDS_LOADED, V_TOTAL_ROWS, V_STARTED_TIME, V_FINISHED_TIME);
 1174    END;
 1175 
 1176   
 1177 
 1178 
 1179 
 1180 
 1181 
 1182 
 1183 
 1184 
 1185   PROCEDURE NEXT_OFFSET(VIEW_NAME IN VARCHAR2)
 1186   IS
 1187     V_BCI_LFILE_NAME     VARCHAR2(4000);
 1188     V_VIEW_NAME          VARCHAR2(4000);
 1189     V_LFILE_PROPS        ORA_KAFKA_UTL.PROPERTIES_TYPE;
 1190 
 1191   BEGIN
 1192 
 1193     V_VIEW_NAME := ORA_KAFKA_UTL.CHECK_SQL_OBJECT('view_name',
 1194                                                     VIEW_NAME);
 1195     
 1196     ORA_KAFKA_UTL.VALIDATE_KAFKA_VIEW(V_VIEW_NAME); 
 1197 
 1198     FOR CUR IN (SELECT * FROM ORA_KAFKA_PARTITION 
 1199                 WHERE VIEW_NAME = V_VIEW_NAME) 
 1200     LOOP
 1201       V_BCI_LFILE_NAME := 
 1202         'KX_' || ORA_KAFKA_UTL.FORMAT_CGTP_NAME(CUR.CLUSTER_NAME, 
 1203                                                  CUR.GROUP_NAME, 
 1204                                                  CUR.TOPIC_NAME, 
 1205                                                  CUR.PARTITION_ID) 
 1206               || '.loc.pp.bci'; 
 1207 
 1208       BEGIN
 1209        V_LFILE_PROPS('ora_kafka_start_offset')    :=  CUR.COMMITTED_OFFSET;
 1210        ORA_KAFKA_UTL.PROPERTIES_TO_FILE(V_LFILE_PROPS, 
 1211                                         ORA_KAFKA_UTL.GET_LOCATION_DIR(CUR.CLUSTER_NAME), 
 1212                                         V_BCI_LFILE_NAME);
 1213 
 1214         EXCEPTION WHEN OTHERS THEN
 1215           
 1216           RAISE_APPLICATION_ERROR(-20000, 'Error processing ' || 
 1217             V_BCI_LFILE_NAME || ' in directory ' || 
 1218             ORA_KAFKA_UTL.GET_LOCATION_DIR(CUR.CLUSTER_NAME), TRUE);
 1219 
 1220       END;
 1221 
 1222     END LOOP;
 1223   END;
 1224 
 1225   
 1226 
 1227 
 1228 
 1229 
 1230 
 1231 
 1232 
 1233 
 1234 
 1235 
 1236 
 1237 
 1238 
 1239 
 1240 
 1241 
 1242 
 1243    PROCEDURE REGISTER_CLUSTER (
 1244      CLUSTER_NAME        IN VARCHAR2,
 1245      BOOTSTRAP_SERVERS   IN VARCHAR2,
 1246      DEFAULT_DIRECTORY   IN VARCHAR2,
 1247      LOCATION_DIRECTORY  IN VARCHAR2,
 1248      CLUSTER_CONF_DIRECTORY IN VARCHAR2,
 1249      CLUSTER_DESCRIPTION IN VARCHAR2 DEFAULT NULL
 1250    )
 1251    IS
 1252      V_STMT0               VARCHAR2(4000);
 1253      V_STMT1               VARCHAR2(4000);
 1254      V_KAFKACOMMAND        VARCHAR2(4000);
 1255      V_COUNT               NUMBER;
 1256 
 1257      V_DEFAULT_DIRECTORY   VARCHAR2(128);
 1258      V_LOCATION_DIRECTORY  VARCHAR2(128);
 1259      V_CLUSTER_CONF_DIRECTORY VARCHAR2(128);
 1260      V_CLUSTER_NAME        VARCHAR2(30);
 1261      V_ZOOKEEPER_URI       VARCHAR2(30):= NULL;
 1262 
 1263      PRAGMA AUTONOMOUS_TRANSACTION;
 1264 
 1265    BEGIN
 1266      
 1267 
 1268      V_CLUSTER_NAME := ORA_KAFKA_UTL.CHECK_SQL_NAME_FRAGMENT('cluster_name',
 1269                                                               CLUSTER_NAME, 
 1270                                                               TRUE);
 1271      IF LENGTH(V_CLUSTER_NAME) > 30 THEN
 1272          RAISE_APPLICATION_ERROR(-20000, 
 1273             'Cluster name length is restricted to 30 characters.');
 1274      END IF;
 1275 
 1276      ORA_KAFKA_UTL.CHECK_BOOTSTRAP_SERVERS(BOOTSTRAP_SERVERS);
 1277 
 1278      V_DEFAULT_DIRECTORY  := ORA_KAFKA_UTL.CHECK_DEFAULT_DIRECTORY(
 1279                                  DEFAULT_DIRECTORY);
 1280 
 1281      V_LOCATION_DIRECTORY := ORA_KAFKA_UTL.CHECK_LOCATION_DIRECTORY(
 1282                                  LOCATION_DIRECTORY);
 1283 
 1284      V_CLUSTER_CONF_DIRECTORY := ORA_KAFKA_UTL.CHECK_CLUSTER_CONF_DIRECTORY(
 1285 				 CLUSTER_CONF_DIRECTORY);
 1286 
 1287      
 1288 
 1289      V_STMT0 := 'SELECT count(*) FROM ora_kafka_cluster WHERE ' || 
 1290                 'cluster_name = :cluster_name';
 1291      
 1292      
 1293      
 1294 
 1295      EXECUTE IMMEDIATE V_STMT0 INTO V_COUNT USING V_CLUSTER_NAME; 
 1296      
 1297      IF V_COUNT > 0 THEN
 1298         RAISE_APPLICATION_ERROR(-20000, 'Duplicate cluster ''' || 
 1299            CLUSTER_NAME || ''' found.');
 1300      END IF;
 1301 
 1302      
 1303      V_STMT1 := 'INSERT INTO ora_kafka_cluster ' ||
 1304                 ' VALUES(:cluster_name, '        || 
 1305                 ' :zookeeper_uri, '              ||
 1306                 ' :bootstrap_servers, '          ||
 1307                 ' :default_directory, :location_directory, ' ||
 1308                 ' :cluster_conf_directory, :cluster_description)';
 1309 
 1310      EXECUTE IMMEDIATE V_STMT1 USING 
 1311           V_CLUSTER_NAME, 
 1312           V_ZOOKEEPER_URI,
 1313           BOOTSTRAP_SERVERS,
 1314           V_DEFAULT_DIRECTORY,
 1315           V_LOCATION_DIRECTORY,
 1316           V_CLUSTER_CONF_DIRECTORY,
 1317           CLUSTER_DESCRIPTION;
 1318      
 1319      
 1320      
 1321      COMMIT;     
 1322 
 1323      BEGIN
 1324        
 1325        
 1326        
 1327        
 1328        ORA_KAFKA_UTL.CREATE_LIST_TOPIC_VIEW(V_CLUSTER_NAME,
 1329                                             BOOTSTRAP_SERVERS);
 1330 
 1331        EXCEPTION WHEN OTHERS THEN
 1332          
 1333          DELETE FROM ORA_KAFKA_CLUSTER WHERE CLUSTER_NAME = V_CLUSTER_NAME;
 1334          COMMIT;
 1335          
 1336          RAISE;
 1337      END;
 1338    END;
 1339 
 1340   
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
 1352 
 1353 
 1354 
 1355 
 1356 
 1357 
 1358 
 1359 
 1360 
 1361 
 1362 
 1363 
 1364 
 1365 
 1366 
 1367 
 1368 
 1369 
 1370 
 1371 
 1372 
 1373 
 1374 
 1375 
 1376 
 1377 
 1378 
 1379 
 1380 
 1381 
 1382 
 1383 
 1384 
 1385 
 1386 
 1387 
 1388 
 1389 
 1390   PROCEDURE SEEK_OFFSET(
 1391                 VIEW_NAME        IN VARCHAR2, 
 1392                 OFFSET           IN INTEGER, 
 1393                 WINDOW_SIZE      IN INTEGER)
 1394   IS
 1395   V_CLUSTER_NAME     VARCHAR2(30);
 1396   V_GROUP_NAME       VARCHAR2(30);
 1397   V_TOPIC_NAME       VARCHAR2(30);
 1398   V_PARTITION_ID     INTEGER;
 1399   V_BCI_LFILE_NAME   VARCHAR2(4000);
 1400   V_VIEW_NAME        VARCHAR2(4000);
 1401   V_BCI_LFILE_PROPS  ORA_KAFKA_UTL.PROPERTIES_TYPE;
 1402 
 1403   BEGIN
 1404     V_VIEW_NAME := ORA_KAFKA_UTL.CHECK_SQL_OBJECT('view_name',
 1405                                                     VIEW_NAME);
 1406 
 1407     IF (OFFSET < 0) 
 1408     THEN
 1409         RAISE_APPLICATION_ERROR(-20000, 
 1410            'OFFSET must be greater than or equal to 0.' || 
 1411            '  User supplied value is ' || OFFSET || '.');
 1412     END IF;
 1413 
 1414     IF (WINDOW_SIZE < 0)
 1415     THEN
 1416         RAISE_APPLICATION_ERROR(-20000, 
 1417            'WINDOW_SIZE must be greater than or equal to 0.' || 
 1418            '  User supplied value is ' || WINDOW_SIZE || '.');
 1419     END IF;
 1420 
 1421     ORA_KAFKA_UTL.VALIDATE_KAFKA_VIEW(V_VIEW_NAME);
 1422     ORA_KAFKA_UTL.VALIDATE_SEEKABLE_VIEW(V_VIEW_NAME,
 1423                                           V_CLUSTER_NAME,
 1424                                           V_GROUP_NAME,
 1425                                           V_TOPIC_NAME,
 1426                                           V_PARTITION_ID);
 1427 
 1428     V_BCI_LFILE_NAME := 
 1429                   'KX_' || ORA_KAFKA_UTL.FORMAT_CGTP_NAME(
 1430                                  V_CLUSTER_NAME, 
 1431                                  V_GROUP_NAME, 
 1432                                  ORA_KAFKA_UTL.SQL_TOPIC_NAME(V_TOPIC_NAME), 
 1433                                  V_PARTITION_ID)  
 1434                         || '.loc.pp.bci';
 1435 
 1436     BEGIN
 1437 
 1438        V_BCI_LFILE_PROPS('ora_kafka_start_offset')     :=  OFFSET;
 1439        V_BCI_LFILE_PROPS('ora_kafka_seek_window_size') :=  WINDOW_SIZE;
 1440 
 1441        ORA_KAFKA_UTL.PROPERTIES_TO_FILE(V_BCI_LFILE_PROPS,
 1442                                         ORA_KAFKA_UTL.GET_LOCATION_DIR(V_CLUSTER_NAME),
 1443                                         V_BCI_LFILE_NAME);
 1444 
 1445 
 1446         EXCEPTION WHEN OTHERS THEN
 1447         
 1448         RAISE_APPLICATION_ERROR(-20000, 'Error processing ' || 
 1449           V_BCI_LFILE_NAME || ' in directory ' || 
 1450           ORA_KAFKA_UTL.GET_LOCATION_DIR(V_CLUSTER_NAME), TRUE);
 1451 
 1452     END;
 1453 
 1454   END;
 1455 
 1456   
 1457 
 1458 
 1459 
 1460 
 1461 
 1462 
 1463 
 1464 
 1465   PROCEDURE UPDATE_OFFSET(
 1466                           VIEW_NAME         IN VARCHAR2,
 1467                           PROCESSED_RECORDS OUT INTEGER)
 1468   IS
 1469     V_BCO_FILE_NAME         VARCHAR2(4000);
 1470     V_CONTENT               VARCHAR2(4000);
 1471     V_LAST_OFFSET           NUMBER;
 1472     V_LAST_COMMITTED_OFFSET NUMBER;
 1473     V_VIEW_NAME             VARCHAR2(4000);
 1474     V_BCO_LFILE_PROPS       ORA_KAFKA_UTL.PROPERTIES_TYPE;
 1475   BEGIN
 1476 
 1477     V_VIEW_NAME := ORA_KAFKA_UTL.CHECK_SQL_OBJECT('view_name',
 1478                                                     VIEW_NAME);
 1479     
 1480     ORA_KAFKA_UTL.VALIDATE_KAFKA_VIEW(V_VIEW_NAME);
 1481 
 1482     
 1483     
 1484     
 1485     
 1486 
 1487    PROCESSED_RECORDS := 0;
 1488    FOR CUR IN (SELECT * FROM ORA_KAFKA_PARTITION 
 1489                WHERE VIEW_NAME = V_VIEW_NAME) LOOP
 1490 
 1491      V_BCO_FILE_NAME :=  'KX_' ||
 1492         ORA_KAFKA_UTL.FORMAT_CGTP_NAME(CUR.CLUSTER_NAME, 
 1493                                         CUR.GROUP_NAME, 
 1494                                         CUR.TOPIC_NAME, 
 1495                                         CUR.PARTITION_ID) 
 1496                                         || '.loc.pp.bco';
 1497       BEGIN
 1498         V_BCO_LFILE_PROPS := ORA_KAFKA_UTL.PROPERTIES_FROM_FILE(
 1499                                    ORA_KAFKA_UTL.GET_LOCATION_DIR(CUR.CLUSTER_NAME), 
 1500                                    V_BCO_FILE_NAME);
 1501         V_LAST_OFFSET := TO_NUMBER(V_BCO_LFILE_PROPS('ora_kafka_last_offset'));
 1502         PROCESSED_RECORDS := 
 1503                 PROCESSED_RECORDS + 
 1504                  TO_NUMBER(V_BCO_LFILE_PROPS('ora_kafka_number_rows'));
 1505           
 1506 
 1507         EXCEPTION 
 1508         WHEN OTHERS THEN
 1509           
 1510           RAISE_APPLICATION_ERROR(-20000, 'Error processing ' || 
 1511                                    V_BCO_FILE_NAME  ||
 1512                                  ' in directory ' || 
 1513                                  ORA_KAFKA_UTL.GET_LOCATION_DIR(CUR.CLUSTER_NAME),
 1514                                  TRUE);
 1515 
 1516       END;
 1517       
 1518       
 1519       
 1520       IF (V_LAST_OFFSET >= 0)
 1521       THEN
 1522          UPDATE ORA_KAFKA_PARTITION SET COMMITTED_OFFSET = V_LAST_OFFSET + 1
 1523            WHERE VIEW_NAME = V_VIEW_NAME AND PARTITION_ID = CUR.PARTITION_ID;
 1524       END IF;
 1525      
 1526     END LOOP; 
 1527   END;
 1528 
 1529   
 1530 
 1531 
 1532 
 1533 
 1534 
 1535 
 1536 
 1537   PROCEDURE UPDATE_OFFSET(VIEW_NAME IN VARCHAR2)
 1538   IS
 1539     V_PROCESSED_RECORDS INTEGER;
 1540   BEGIN
 1541     
 1542     UPDATE_OFFSET(VIEW_NAME, V_PROCESSED_RECORDS);
 1543     DBMS_OUTPUT.PUT_LINE('Number of Kafka records processed = ' 
 1544                          || V_PROCESSED_RECORDS);
 1545   END;
 1546 
 1547   
 1548 
 1549 
 1550 
 1551 
 1552 
 1553 
 1554 
 1555 
 1556 
 1557 
 1558 
 1559 
 1560 
 1561 
 1562 
 1563 
 1564 
 1565 
 1566 
 1567 
 1568 
 1569 
 1570   PROCEDURE CHECK_STATUS(
 1571                           VIEW_NAME             IN VARCHAR2,
 1572                           STATUS                OUT INTEGER,
 1573                           USER_FRIENDLY_MESSAGE OUT VARCHAR2,
 1574                           EXCEPTION_MESSAGE     OUT VARCHAR2,
 1575                           FILE_INFO             OUT VARCHAR2)
 1576   IS
 1577     V_BCO_FILE_NAME         VARCHAR2(4000);
 1578     V_CONTENT               VARCHAR2(4000);
 1579     V_VIEW_NAME             VARCHAR2(4000);
 1580     V_STATUS                INTEGER;
 1581     V_BCO_LFILE_PROPS       ORA_KAFKA_UTL.PROPERTIES_TYPE;
 1582   BEGIN
 1583 
 1584     V_VIEW_NAME := ORA_KAFKA_UTL.CHECK_SQL_OBJECT('view_name',
 1585                                                     VIEW_NAME);
 1586     
 1587     ORA_KAFKA_UTL.VALIDATE_KAFKA_VIEW(V_VIEW_NAME);
 1588 
 1589     
 1590     STATUS := 0;
 1591 
 1592     
 1593     
 1594     
 1595 
 1596     FOR CUR IN (SELECT * FROM ORA_KAFKA_PARTITION 
 1597                 WHERE VIEW_NAME = V_VIEW_NAME) LOOP
 1598 
 1599       V_BCO_FILE_NAME :=  'KX_' ||
 1600         ORA_KAFKA_UTL.FORMAT_CGTP_NAME(CUR.CLUSTER_NAME, 
 1601                                        CUR.GROUP_NAME, 
 1602                                        CUR.TOPIC_NAME, 
 1603                                        CUR.PARTITION_ID) 
 1604                                        || '.loc.pp.bco';
 1605       BEGIN
 1606         V_BCO_LFILE_PROPS := 
 1607               ORA_KAFKA_UTL.PROPERTIES_FROM_FILE (
 1608                         ORA_KAFKA_UTL.GET_LOCATION_DIR(CUR.CLUSTER_NAME), 
 1609                         V_BCO_FILE_NAME
 1610                        );
 1611          V_STATUS :=  TO_NUMBER(V_BCO_LFILE_PROPS('ora_kafka_status'));
 1612 
 1613 
 1614         
 1615         IF V_STATUS != 0 THEN
 1616           STATUS := V_STATUS;
 1617           USER_FRIENDLY_MESSAGE := V_BCO_LFILE_PROPS('ora_kafka_user_message');
 1618           EXCEPTION_MESSAGE := 
 1619                      V_BCO_LFILE_PROPS('ora_kafka_exception_message');
 1620           FILE_INFO := V_BCO_LFILE_PROPS('ora_kafka_output_file_info');
 1621         END IF;
 1622 
 1623 
 1624         EXCEPTION WHEN OTHERS THEN
 1625           
 1626           RAISE_APPLICATION_ERROR(-20000, 'Error processing ' || 
 1627             V_BCO_FILE_NAME || ' in directory ' || 
 1628             ORA_KAFKA_UTL.GET_LOCATION_DIR(CUR.CLUSTER_NAME), TRUE);
 1629 
 1630       END;
 1631     
 1632     END LOOP; 
 1633   END;
 1634 
 1635 
 1636   
 1637  
 1638 
 1639 
 1640 
 1641 
 1642 
 1643 
 1644 
 1645 
 1646 
 1647 
 1648 
 1649 
 1650 
 1651 
 1652 
 1653 
 1654 
 1655 
 1656 
 1657 
 1658 
 1659 
 1660 
 1661 
 1662 
 1663 
 1664 
 1665 
 1666 
 1667 
 1668 
 1669 
 1670 
 1671 
 1672 
 1673 
 1674 
 1675   FUNCTION  GET_HEX_VALUE_FROM_JSON(P_JSON_STR   IN VARCHAR2,
 1676                                     P_JSON_FIELD IN VARCHAR2)
 1677   RETURN VARCHAR2
 1678   IS
 1679   VAL VARCHAR2(4000);
 1680   NVAL NVARCHAR2(200);
 1681   RVAL RAW(1000);
 1682   
 1683   NO_JSON_VALUE_EX EXCEPTION;
 1684   PRAGMA EXCEPTION_INIT(NO_JSON_VALUE_EX, -40462);
 1685   BEGIN
 1686 
 1687   IF (P_JSON_STR IS NULL) OR (P_JSON_FIELD IS NULL) THEN
 1688     RAISE_APPLICATION_ERROR( -20001, 'Null JSON string/field', TRUE );
 1689   END IF;
 1690 
 1691   
 1692 
 1693 
 1694 
 1695 
 1696 
 1697 
 1698 
 1699 
 1700 
 1701 
 1702 
 1703 
 1704 
 1705 
 1706 
 1707 
 1708 
 1709 
 1710 
 1711 
 1712 
 1713 
 1714 
 1715 
 1716 
 1717 
 1718 
 1719 
 1720 
 1721 
 1722 
 1723 
 1724 
 1725 
 1726   
 1727   
 1728   
 1729   
 1730    VAL := JSON_VALUE(P_JSON_STR,
 1731            '$.' ||P_JSON_FIELD RETURNING VARCHAR2 ASCII ERROR ON ERROR);
 1732    $IF $$ORAKAFKATRC $THEN      
 1733      DBMS_OUTPUT.PUT_LINE('json_ascii_value: ' || VAL);
 1734    $END
 1735 
 1736 
 1737    
 1738    
 1739 
 1740    
 1741 
 1742    
 1743    VAL := REPLACE(VAL, '\\', '\u005C');
 1744    $IF $$ORAKAFKATRC $THEN
 1745      DBMS_OUTPUT.PUT_LINE('replace \\: ' || VAL);
 1746    $END
 1747 
 1748    
 1749    VAL := REPLACE(VAL, '\/', '\u002F');
 1750    $IF $$ORAKAFKATRC $THEN
 1751      DBMS_OUTPUT.PUT_LINE('replace \/: ' || VAL);
 1752    $END
 1753 
 1754    
 1755    VAL := REPLACE(VAL, '\"', '\u0022');
 1756    $IF $$ORAKAFKATRC $THEN
 1757      DBMS_OUTPUT.PUT_LINE('replace \": ' || VAL);
 1758    $END
 1759 
 1760    
 1761    VAL := REPLACE(VAL, '\r', '\u000D');
 1762    $IF $$ORAKAFKATRC $THEN
 1763      DBMS_OUTPUT.PUT_LINE('replace \r: ' || VAL);
 1764    $END
 1765 
 1766    
 1767    VAL := REPLACE(VAL, '\n', '\u000A');
 1768    $IF $$ORAKAFKATRC $THEN
 1769      DBMS_OUTPUT.PUT_LINE('replace \n: ' || VAL);
 1770    $END  
 1771 
 1772    
 1773    VAL := REPLACE(VAL, '\b', '\u0008');
 1774    $IF $$ORAKAFKATRC $THEN
 1775      DBMS_OUTPUT.PUT_LINE('replace \b: ' || VAL);
 1776    $END
 1777 
 1778    
 1779    VAL := REPLACE(VAL, '\t', '\u0009');
 1780    $IF $$ORAKAFKATRC $THEN
 1781      DBMS_OUTPUT.PUT_LINE('replace \t: ' || VAL);
 1782    $END  
 1783 
 1784    
 1785    VAL := REPLACE(VAL, '\f', '\u000c');
 1786    $IF $$ORAKAFKATRC $THEN
 1787      DBMS_OUTPUT.PUT_LINE('replace \f: ' || VAL);
 1788    $END
 1789 
 1790    
 1791    
 1792    
 1793    VAL := REPLACE(VAL, '\u', '\');
 1794    $IF $$ORAKAFKATRC $THEN
 1795      DBMS_OUTPUT.PUT_LINE('replace \u: ' || VAL);
 1796    $END
 1797 
 1798     $IF $$ORAKAFKATRC $THEN      
 1799      
 1800      NVAL := UNISTR(VAL);
 1801      DBMS_OUTPUT.PUT_LINE('unistr nchar: ' || NVAL);
 1802 
 1803      
 1804      RVAL := SYS.UTL_I18N.STRING_TO_RAW(NVAL, 'AL32UTF8');
 1805      DBMS_OUTPUT.PUT_LINE('string_to_raw: ' || RVAL);
 1806      DBMS_OUTPUT.PUT_LINE('rawtohex: ' || RAWTOHEX(RVAL));
 1807     $END
 1808 
 1809    
 1810    RETURN RAWTOHEX(SYS.UTL_I18N.STRING_TO_RAW(UNISTR(VAL), 'AL32UTF8'));
 1811    
 1812    
 1813    
 1814    
 1815    
 1816    
 1817    
 1818    EXCEPTION 
 1819    WHEN NO_JSON_VALUE_EX THEN
 1820       
 1821       RETURN NULL;
 1822    WHEN OTHERS THEN
 1823      
 1824      DBMS_OUTPUT.PUT(SYS.DBMS_UTILITY.FORMAT_ERROR_STACK() );
 1825      RAISE;
 1826   END;
 1827  
 1828 
 1829 
 1830   
 1831   
 1832   
 1833 END ORA_KAFKA;

Unwrap More Code

Copyright © 2019 Manuel Bleichenbacher. All Rights Reserved.

