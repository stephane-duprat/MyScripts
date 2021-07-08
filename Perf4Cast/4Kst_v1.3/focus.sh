#!/bin/bash
# #####################################################################
# $Header: desc.sh 24-dic-2009 sduprat_es Exp $
#
# focus.sh (bash script)
#
# Copyright (c) 2010, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     desc.sh
#
#    DESCRIPTION
#     A bash script which displays the detail of a snapshot in the consolidated source data file
#     This script has been written to help with the Linear Regression's singularity analisis.
#
#    NOTES
#           Invocation: focus.sh <project> <snap_id>
#           Example   : focus.sh INIC 20100126220001.300
#
#    MODIFIED        (MM/DD/YY)
#     sduprat_es      23/02/10   - Creation and mastermind
#     sduprat_es      18/10/10   - Screenprint input datafile name.
#
# #####################################################################

# process arguments
if [ -z "$1" ]
then INI=MM_4Kst.ini
else INI=MM_4Kst-$1.ini
fi
if [ -z "$2" ]
then 
    echo "ERROR: 2nd argument \"$2\" must be \"filter\" or blank."
    exit -1
else
     snapid=$2
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
echo "Focusing on data file "$fic
echo "Values of fields for line with Snap Id = "$snapid
# describe the line identified by snapid in the consolidated data file
awk -v v_snap=$snapid	'BEGIN{FS="|"}
	{if(NR==1)	{cnt=split($0,vnam,"|");}
	 else		{if (match($0,v_snap)) {cnt=split($0,vfield,"|");} }
	}
	END{ for(i=1;i<=cnt;i++){printf"Elemento Num %i\t%-20s\t\t\t%s\n",i-1,vnam[i],vfield[i];}
	}' $fic 
