ORACLE_SID="REPAWR"                       # ------ Must set
ORACLE_HOME="/media/Data/u02/product/11.2.0/client_1"  # ------ Must set
LD_LIBRARY_PATH="$ORACLE_HOME/lib"
PATH=$PATH:$ORACLE_HOME/bin

export ORACLE_SID ORACLE_HOME LD_LIBRARY_PATH PATH

ora_access="sys/W3lc0m31#@'(DESCRIPTION= (ADDRESS_LIST =(ADDRESS = (PROTOCOL = TCP)(HOST = 130.162.96.237)(PORT = 1521)))(CONNECT_DATA =(SERVICE_NAME = PRDBI.586556309.oraclecloud.internal)))' as sysdba"                 # ------ Must set
export ora_access

## WORK=/media/sf_DGPE/2013.06.03.Revision.entorno.TIC/04.Conecta/work
WORK=/media/sf_AWR.Toolkit/Scripts.AWR/003.Instance/work
## WORK=/media/sf_BancoCaminos/94.Incidencias/2013.06.10.Crash/work
export WORK

DSQL=/media/sf_AWR.Toolkit/Scripts.AWR/003.Instance/OCTS.SQL
export DSQL
