#!/bin/bash
# #####################################################################
# $Header: R.linearity.at.a.glance.sh 14-May-2012 sduprat_es Exp $
#
# R.linearity.at.a.glance.sh (bash script)
#
# Copyright (c) 2012, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     R.linearity.at.a.glance.sh
#
#    DESCRIPTION
#     A bash script which displays the linearity study between all the metrics collected in a project
#     NB: this script invokes R for the linearity calculations.
#
#    USAGE: R.linearity.at.a.glance.sh <PROJECT> <DEPENDENT METRIC>
#
#    NOTES
#
#         If not provided on the command line, $2 defaults to "DBCPU"
#
#    MODIFIED        (MM/DD/YY)
#     sduprat_es      14/05/12   - Creation and mastermind
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
if [[ -n "$DATA_DIR" && ! -d "$DATA_DIR" ]]
then echo "ERROR: directory \"$DATA_DIR\" does not exists."
     exit -1
fi
fic=${DATA_DIR:="./"}${FIC_INPUT}
if [ ! -f "$fic" ]
then echo "ERROR: input file \"$fic\" does not exists."
     exit -1
fi

if [ -z "$2" ]
then METRIC="DBCPU"
else METRIC=$2
fi

ficout=${DATA_DIR}R.linearity.regression.txt

echo "Linear regression for metric "$METRIC >> $ficout
echo " " >> $ficout

R --no-save << EOF
rawData <- read.table(file="$fic", header=TRUE, sep="|")
lab=names(rawData)
for ( i in 2:length(lab)) { write.table(cor(rawData\$$METRIC, rawData[i]),file="${DATA_DIR}R.linearity.regression.txt", append=TRUE) }
q()

EOF

echo "*****************************************************************************" >> $ficout

echo " "
echo "Generated: "$ficout
exit 0
