#!/bin/ksh

## DBTIME analisis with R !!!

. ../ENV/perfil.sh


echo "Host => "$sbdd
echo "Port => "$pbdd
echo "User => "$ubdd
echo "SID => "$sid
echo "TNS alias => "$tnsalias

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


sink("$DLOG/$base0.$2.$1.log", append=FALSE, split=TRUE)  ## Generate a logfile with the output !!!
png("$DPNG/$base0.$2.$1.png")  ## Generate the graph in a subdirectory !!!

library(ROracle)
drv <- dbDriver("Oracle")
conn <- dbConnect(drv, username = "$ubdd", password = "$passbdd" , dbname = "$tnsalias")
SQLtext <- paste(readLines("$TMPSQL"), collapse=" ")
sqldata<-dbGetQuery(conn, SQLtext)
summary(sqldata)
sqldata

## 
## Plot service time and wait time as a Bar Graph !!!
##

barplot(t(sqldata[,7:8]), names.arg=sqldata\$HORA, xlab=paste("Hours of day ", as.Date("$1","%Y%m%d"),sep=""), main="DB Time distribution (%)", ylab="Database time", col=c("green", "red"), legend=c("Service time(%)","Wait time(%)"))

dbDisconnect(conn)
q()

EOF

exit 0
