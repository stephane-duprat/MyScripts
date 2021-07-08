#!/bin/bash

### Arranca todos los computes listados en el fichero list-compute.txt

for name in `cat /home/opc/admin/list-compute.txt | awk -F";" '{ print $1 }'`
do
    /home/opc/admin/start-compute.sh $name
done

exit 0
