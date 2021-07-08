#!/bin/bash

### Script de calculo del numero de OCPU de un ADB !!!
### $1 = nombre del ADB !!!

name=$1
DATE=`date +%Y%m%d%H%M%S`
ocid=$(grep $name /home/opc/admin/list-compute.txt | awk -F";" '{ print $3 }')
targettype=$(grep $name /home/opc/admin/list-compute.txt | awk -F";" '{ print $2 }')
ficlog=/home/opc/admin/log/${DATE}.getOCPU-adb.${name}.log

if [ ${targettype} == "ADW" ]
then
    /home/opc/bin/oci db autonomous-data-warehouse get --autonomous-data-warehouse-id ${ocid} --defaults-file /home/opc/.oci/mydefaults.txt 1>${ficlog} 2>&1
elif [ ${targettype} == "ATP" ]
then
    /home/opc/bin/oci db autonomous-database get --autonomous-database-id ${ocid} --defaults-file /home/opc/.oci/mydefaults.txt 1>${ficlog} 2>&1

fi

echo $name " : " $(grep "cpu-core-count" ${ficlog} | awk '{ print $NF }' | sed '1,$ s/"//g' | sed '1,$ s/,//')

exit 0
