#!/bin/ksh

## DBTIME analisis with R !!!

. ../ENV/perfil.sh


echo "Host => "$sbdd
echo "Port => "$pbdd
echo "User => "$ubdd
echo "SID => "$sid

B1=$1
B2=$2
B3=$3
base0=$(echo $(basename $0) | sed '1,$ s/\.sh//')

SQL=./SQL/${base0}.sql
FICSED=$DSED/${base0}.sed
TMPSQL=$DTMP/${base0}.sql

## Generacion del fichero SED

echo "s/BV1/"${B1}"/g" > ${FICSED}
echo "s/BV2/"${B2}"/g" >> ${FICSED}
echo "s/BV3/"${B3}"/g" >> ${FICSED}

## Generacion del fichero SQL

sed -f ${FICSED} ${SQL} > ${TMPSQL}

$EXER << EOF

library(RJDBC)
drv <- JDBC("oracle.jdbc.driver.OracleDriver", "$ljdbc")
conn <- dbConnect(drv,"jdbc:oracle:thin:@$sbdd:$pbdd:$sid","$ubdd","$passbdd")
SQLtext <- paste(readLines("$TMPSQL"), collapse=" ")
sqldata<-dbGetQuery(conn, SQLtext)
summary(sqldata)
sqldata

q()

EOF

exit 0
