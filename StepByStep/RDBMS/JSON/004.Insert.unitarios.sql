col js format a500
set long 1000000 lines 500
set TRIMOUT ON HEADING OFF FEEDBACK OFF ECHO OFF VERIFY OFF SPACE 0 PAGESIZE 0 TERMOUT OFF TRIMSPOOL OFF
spool onemillon.insert.sql
select 'insert into SALES_JSON_CHECK_INSERT (ID,SALES_JSON) values (sys_guid(),''' ||
SALES_JSON || ''');' || chr(10) || 'commit;' js from SALES_JSON_CHECK;
spool off

for fic in `ls -1 insert_*.sh`
do
    echo "ORACLE_HOME=/home/opc/instantclient_18_3" > tt
    echo "LD_LIBRARY_PATH=/home/opc/instantclient_18_3" >> tt
    echo "TNS_ADMIN=\$ORACLE_HOME/network/admin" >> tt
    echo "PATH=\$ORACLE_HOME:\$PATH:\$HOME/.local/bin:\$HOME/bin" >> tt
    echo "export PATH ORACLE_HOME LD_LIBRARY_PATH TNS_ADMIN" >> tt
    echo "sqlplus -s sh/sh@JSONPDB << EOF" >> tt
    cat $fic >> tt
    echo "EOF" >> tt
    echo "exit 0" >> tt
    mv tt $fic
done


COMMIT SINCRONO: 650 commit/s

COMMIT ASINCRONO: 1000 commit/s


