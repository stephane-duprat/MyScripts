#!/bin/bash
# #####################################################################
# $Header: conso 24-dic-2009 sduprat_es Exp $
#
# conso (bash script)
#
# Copyright (c) 2009, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     conso
#
#    DESCRIPTION
#     A bash script which creates the consolidated data file.
#
#    NOTES
#
#    MODIFIED        (MM/DD/YY)
#     sduprat_es      31/12/09   - Creation and mastermind
#     mellison_es     20/01/10   - implement the "project" functionality via .ini
#     sduprat_es      11/02/10   - Bug in title line: eliminate "(" and ")" characters
#     sduprat_es      17/05/10   - Screenprint output file name.
#     sduprat_es      18/05/10   - Consolidate Pre-processed I/O file: PreProcessIO.pl MUST have been executed before this step.
#     sduprat_es      01/01/11   - Bug: if snap_id is not in the wl_io.dat, force I/O utilization to 0
#     sduprat_es,acarrasc_es	25/02/11	- Calculate instancecpu from SAR colected CPU utilization
#                                                 instead of using inaccurate "CPU Used by this session" 9i metric
#     sduprat_es      03/03/11	 - Only write the lines in the caracterization file, if wl_io.dat, wl_cpu.dat , wl_app.dat 
#					  contain the snapshot
#
# #####################################################################

# process arguments
if [ -z "$1" ]
then INI=MM_4Kst.ini
else INI=MM_4Kst-$1.ini
fi
if [ ! -f "$INI" ]
then echo "ERROR: ini file \"$INI\" does not exists."
     exit -1
fi
# process project parameters
eval `awk 'BEGIN{FS="="}$1~/^4KST_DATA_DIR$/{print "DATA_DIR="$2"/"}' $INI`
eval `awk 'BEGIN{FS="="}$1~/^4KST_FIC_INPUT$/{print "FIC_INPUT="$2}' $INI`
eval `awk 'BEGIN{FS="="}$1~/^4KST_CPU_COMPUTE_MODE$/{print "CPU_USED="$2}' $INI`
eval `awk 'BEGIN{FS="="}$1~/^4KST_NUM_CPU$/{print "NUM_CPU="$2}' $INI`
if [[ -n "$DATA_DIR" && ! -d "$DATA_DIR" ]]
then echo "ERROR: directory \"$DATA_DIR\" does not exists."
     exit
fi
# create the consolidated data file
TMP=/tmp/$$.tmp
OUT=${DATA_DIR:="./"}${FIC_INPUT:="consolidado.txt"}
FICIO_ORG=${DATA_DIR}wl_io.dat
FICCPU_ORG=${DATA_DIR}wl_cpu.dat
FICAPP_ORG=${DATA_DIR}wl_app.dat
FICIO=${FICIO_ORG}2
FICCPU=${FICCPU_ORG}2
FICAPP=${FICAPP_ORG}2
CPUUSED=${CPU_USED:="DB"}
NUMCPU=${NUM_CPU}

if [ ! -f "$FICIO_ORG" ]
then echo "ERROR: io input file \"FICIO_ORG\" does not exists."
     exit
elif [ ! -f "$FICCPU_ORG" ]
then echo "ERROR: cpu input file \"FICCPU_ORG\" does not exists."
     exit
elif [ ! -f "$FICAPP_ORG" ]
then echo "ERROR: app input file \"FICAPP_ORG\" does not exists."
     exit
fi


## Tratamiento previo de ficheros, para quitar los espacios !!!
for fic in FICIO FICCPU FICAPP
do
    eval F1=\$\{${fic}_ORG\}
    eval F2=\$\{${fic}\}
    if [ "$fic" == "FICIO" ]
    then awk 'BEGIN{FS=","}{print $1","$2","$3","$4}' $F1|sed '1,$ s/ //g' > $F2
    else sed '1,$ s/ //g' $F1 > $F2
    fi
#    mv t $fic
done

## Linea de titulo !!!
for snap in `cat $FICCPU | cut -f1 -d"," | sort -u | head -1`
do
    titulo="Snap_id|Tiempo (s)|CPUUsr|CPUSys|CPUIdle"
    
    for linea in `grep $snap $FICIO`
    do
        dev=$(echo $linea | cut -f2 -d",")
        titulo=$titulo"|"$dev"UtilPct"
    done
    
## Tratamiento metricas de base de datos !!!
    for linea in `grep $snap $FICAPP`
    do
        event=$(echo $linea | cut -f2 -d"," | sed '1,$ s/(//' | sed '1,$ s/)//')
        titulo=$titulo"|"$event
    done
    if  [ $CPUUSED == "SYS" ] 
    then 
	titulo=$titulo"|instancecpu"
    fi
    ## Aqui calculamos DELTA por si acaso estamos en modo SYS !!!
    DELTA=$(echo $snap | cut -f2 -d".")
done
echo $titulo > $OUT
totlin=$(wc -l $FICCPU | awk '{ print $1 }')
contador=0

echo -e "Analizando ficheros de entrada ("$totlin" entradas) \c"

for snap in `cat $FICCPU | cut -f1 -d"," | sort -u`
do
    lin=$snap"|"$(echo $snap | cut -f2 -d".")
    ## Tratamiento CPU !!!
    for linea in `grep $snap $FICCPU`
    do
        cpu_usr=$(echo $linea | cut -f2 -d",")
        cpu_sys=$(echo $linea | cut -f3 -d",")
        cpu_idl=$(echo $linea | cut -f4 -d",")
        lin=$lin"|"${cpu_usr}"|"${cpu_sys}"|"${cpu_idl}
    done
    
    ## Tratamiento I/O !!!
    ## Assumes that the original I/O file has been pre-processed with PreProcessIO.pl. Will fail otherwise.
    ##
    entrado=1
    for linea in `grep $snap $FICIO`
    do
        dev=$(echo $linea | cut -f2 -d",")
        util=$(echo $linea | cut -f3 -d",")
        lin=$lin"|"${util}
	entrado=0
    done
    ## Si no he entrado en en FOR anterior, es que el SNAP NO estaba en el fichero de I/O, por lo tanto
    ## pego una utilizacion de I/O a cero. Sino se desplazarian las metricas siguientes una posicion hacia la 
    ## izquierda !!!

    if [ $entrado -eq 1 ] 
    then 
        lin=$lin"|0" 
    fi


    ## Tratamiento metricas de base de datos !!! 
    entrado=1
    for linea in `grep $snap $FICAPP`
    do
        event=$(echo $linea | cut -f2 -d",")
        metric=$(echo $linea | cut -f3 -d",")
        lin=$lin"|"${metric}
	entrado=0
    done
    
    ## Aqui se agrega el DBCPU calculado en microsegundos en funcion del cpu_usr y el num_cpus
    if  [ $CPUUSED == "SYS" ]
    then
        lin=$lin"|"$(echo "scale=0; ("$DELTA"*"$NUM_CPU"*"${cpu_usr}"*1000000)/100"|bc -l)
    fi


    ## Solo se pinta la linea final si el SNAP se encontro en el fichero FICAPP !!!
    if [ $entrado -eq 0 ] 
    then 
        echo $lin >> $TMP
    fi

    contador=$(echo $contador+1 | bc -l | awk '{ printf "%4d" , $1 }')
    echo -e "$contador\b\b\b\b\c"
done
echo

cat $TMP >> $OUT
echo "Fichero "$OUT" generado."
rm $TMP 2>/dev/null

exit 0
