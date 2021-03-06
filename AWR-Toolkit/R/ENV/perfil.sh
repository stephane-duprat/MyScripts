#!/bin/ksh

## Definicion de variables de entorno !!!

## R executable

EXER="/usr/bin/R --no-save"

## Directories

RAIZ=/media/Data/Documentation/Oracle/AWR.Toolkit/R
DENV=$RAIZ/ENV
DAWR=$RAIZ/AWR
DLOG=$RAIZ/LOG
DPNG=$RAIZ/PNG
DSED=$RAIZ/SED
DTMP=$RAIZ/TMP


## Database conexion variables !!!

ubdd="system"         ## BBDD user
passbdd="Oracle11"         ## BBDD password
sbdd="11gR2primary"   ## BBDD host
pbdd="1521"           ## BBDD port
sid="ORA11GR2"        ## BBDD SID
tnsalias="REPAWR"      ## Alias en el fichero tnsnames local ($TNS_ADMIN)

## JDBC library !!!

ljdbc=/media/Data/u02/product/11.2.0/client_1/jdbc/lib/ojdbc6.jar
LD_LIBRARY_PATH=/media/Data/u02/product/11.2.0/client_1/lib
export LD_LIBRARY_PATH
