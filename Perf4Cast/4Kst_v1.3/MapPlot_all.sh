#!/bin/bash
# #####################################################################
# $Header: MapPlot_all.sh 06-JUN-13 sduprat_es Exp $
#
# MapPlot_all.sh (bash script)
#
# Copyright (c) 2013, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     MapPlot_all.sh
#
#    DESCRIPTION
#       Invokes MapPlot.pl for the project passed on the command line, for all metrics
#
#    USAGE: MapPlot_all.sh <PROJECT>
#
#    NOTES
#
#        
#
#    MODIFIED        (MM/DD/YY)
#     sduprat_es      06/06/13   - Creation and mastermind
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

for metric in `./desc.sh $1 | grep "Elemento numero" | awk '{ print $3 }'`
do
     ./MapPlot.pl $1 $(head -1 lista_fechas_$1.txt) $(tail -1 lista_fechas_$1.txt) $metric
done

exit 0
