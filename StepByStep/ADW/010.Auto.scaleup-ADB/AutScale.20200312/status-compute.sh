#!/bin/bash

### Script de arranque de un compute
### $1 = nombre del compute

name=$1
DATE=`date +%Y%m%d%H%M%S`
ocid=$(grep $name /home/oracle/tuneCJ/Automatizacion/AutCpu/list-compute.txt | awk -F";" '{ print $3 }')
targettype=$(grep $name /home/oracle/tuneCJ/Automatizacion/AutCpu/list-compute.txt | awk -F";" '{ print $2 }')
ficlog=/home/oracle/tuneCJ/Automatizacion/AutCpu/log/${DATE}.status_compute.${name}.log 

## Borramos los fucheros de estado generados anteriormente.
fichogrm=/home/oracle/tuneCJ/Automatizacion/AutCpu/log/*.status_compute.${name}.log
rm ${fichogrm}

if [ ${targettype} == "NODE" ]
then
    /usr/local/bin/oci db node get --db-node-id ${ocid} --defaults-file /home/oracle/.ocibbdd/mydefaults.txt --config-file /home/oracle/.ocibbdd/config 1>${ficlog} 2>&1
elif [ ${targettype} == "ADW" ]
then
    /usr/local/bin/oci db autonomous-data-warehouse get --autonomous-data-warehouse-id ${ocid} --defaults-file /home/oracle/.ocibbdd/mydefaults.txt --config-file /home/oracle/.ocibbdd/config 1>${ficlog} 2>&1
elif [ ${targettype} == "ATP" ]
then
    /usr/local/bin/oci db autonomous-database get --autonomous-database-id ${ocid} --defaults-file /home/oracle/.ocibbdd/mydefaults.txt --config-file /home/oracle/.ocibbdd/config 1>${ficlog} 2>&1

fi

echo $name " : " $(grep "lifecycle-state" ${ficlog} | awk '{ print $NF }' | sed '1,$ s/"//g' | sed '1,$ s/,//')

exit 0
