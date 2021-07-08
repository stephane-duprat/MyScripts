#!/bin/bash

### Script de arranque de un compute
### $1 = nombre del compute

name=$1
numcpu=$2
DATE=`date +%Y%m%d%H`
ocid=$(grep $name /home/oracle/tuneCJ/Automatizacion/AutCpu/list-compute.txt  | awk -F";" '{ print $3 }')
targettype=$(grep $name /home/oracle/tuneCJ/Automatizacion/AutCpu/list-compute.txt | awk -F";" '{ print $2 }')
ficlog=/home/oracle/tuneCJ/Automatizacion/AutCpu/log/${DATE}.scale-cpu-adb.${name}.log

if [ ${targettype} == "ADW" ]
then
    /usr/local/bin/oci db autonomous-data-warehouse update --autonomous-data-warehouse-id ${ocid} --cpu-core-count $numcpu --defaults-file /home/oracle/.ocibbdd/mydefaults.txt --config-file /home/oracle/.ocibbdd/config 1>>${ficlog} 2>&1
elif [ ${targettype} == "ATP" ]
then
    /usr/local/bin/oci db autonomous-database update --autonomous-database-id ${ocid} --cpu-core-count $numcpu --defaults-file /home/oracle/.ocibbdd/mydefaults.txt  --config-file /home/oracle/.ocibbdd/config  1>>${ficlog} 2>&1
else
  echo "Not an ADB"
fi

exit 0
