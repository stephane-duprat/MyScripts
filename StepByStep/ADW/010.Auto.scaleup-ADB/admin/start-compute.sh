#!/bin/bash

### Script de arranque de un compute
### $1 = nombre del compute

name=$1
DATE=`date +%Y%m%d%H%M%S`
ocid=$(grep $name /home/opc/admin/list-compute.txt | awk -F";" '{ print $3 }')
targettype=$(grep $name /home/opc/admin/list-compute.txt | awk -F";" '{ print $2 }')
ficlog=/home/opc/admin/log/${DATE}.start_compute.${name}.log

if [ ${targettype} == "NODE" ]
then
    /home/opc/bin/oci db node start --db-node-id ${ocid} --defaults-file /home/opc/.oci/mydefaults.txt 1>${ficlog} 2>&1
elif [ ${targettype} == "ADW" ]
then
    /home/opc/bin/oci db autonomous-data-warehouse start --autonomous-data-warehouse-id ${ocid} --defaults-file /home/opc/.oci/mydefaults.txt 1>${ficlog} 2>&1
elif [ ${targettype} == "ATP" ]
then
    /home/opc/bin/oci db autonomous-database start --autonomous-database-id ${ocid} --defaults-file /home/opc/.oci/mydefaults.txt 1>${ficlog} 2>&1

fi


exit 0
