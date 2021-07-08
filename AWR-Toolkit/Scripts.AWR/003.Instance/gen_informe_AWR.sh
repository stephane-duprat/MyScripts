#!/bin/ksh
inst=$1 ## Instance name
fecha=$2 ## DD-MON-YY

for lin in `./gather_driver_from_AWR_1.4.1.sh -show | grep $inst | grep $fecha | tail -1 | awk '{ print $1";"$2";"$3";"$4";"$5";"$6";"$7 }'`
do
    inst_num=$(echo $lin | cut -f4 -d";")
    db_name=$(echo $lin | cut -f2 -d";")
    dbid=$(echo $lin | cut -f1 -d";")
    beginsnap=$(echo $lin | cut -f6 -d";")
    endsnap=$(echo $lin | cut -f7 -d";")
i=$(echo $beginsnap"-1" | bc -l)
j=$(echo $i"+1" | bc -l)
while true
do
echo -e "Generando informe AWR del "${fecha}" snapshots "${i}"-"${j}" ...\c"
sqlplus  / as sysdba << EOF > /dev/null
      define  inst_num     = ${inst_num};
      define  num_days     = 1;
      define  inst_name    = '${inst}';
      define  db_name      = '${db_name}';
      define  dbid         = ${dbid};
      define  begin_snap   = ${i};
      define  end_snap     = ${j};
      define  report_type  = 'text';
      define  report_name  = 'awrrpt_${fecha}_${inst}_${i}_${j}.txt'
      @@?/rdbms/admin/awrrpti
   exit
EOF
echo -e " [ OK ]"
i=$(echo $i"+1" | bc -l)
j=$(echo $i"+1" | bc -l)
if [ $i -eq ${endsnap} ]
then
    exit 0
fi
done
done

