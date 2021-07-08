#!/bin/bash
# #####################################################################
# $Header: desc.sh 24-dic-2009 sduprat_es Exp $
#
# desc.sh (bash script)
#
# Copyright (c) 2010, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     desc.sh
#
#    DESCRIPTION
#     A bash script which displays the min/max/avg/cnt for each column
#     of the consolidated data file.
#
#    NOTES
#
#    MODIFIED        (MM/DD/YY)
#     sduprat_es      24/12/09   - Creation and mastermind
#     mellison_es     20/01/10   - implement "projects"
#     mellison_es     21/01/10   - add statistic
#     sduprat_es      17/05/10   - Screenprint input file name
#     sduprat_es      23/03/12   - Generate the date list file "lista_fechas.txt" and the corresponding softlink
#     sduprat_es      10/04/14   - Change numeric output formats to string to avoid overflow
#
# #####################################################################

# process arguments
if [ -z "$1" ]
then INI=MM_4Kst.ini
else INI=MM_4Kst-$1.ini
fi
if [ -z "$2" ]
then unset FIL
elif [ "$2" == "filter" ]
then FIL="true"
else  echo "ERROR: 2nd argument \"$2\" must be \"filter\" or blank."
     exit -1
fi
if [ ! -f "$INI" ]
then echo "ERROR: ini file \"$INI\" does not exists."
     exit -1
fi
# process project parameters
eval `awk 'BEGIN{FS="="}$1~/^4KST_DATA_DIR$/{print "DATA_DIR="$2"/"}' $INI`
if [ -z "$FIL" ]
then eval `awk 'BEGIN{FS="="}$1~/^4KST_FIC_INPUT$/{print "FIC_INPUT="$2}' $INI`
else eval `awk 'BEGIN{FS="="}$1~/^4KST_FIC_FILTER$/{print "FIC_INPUT="$2}' $INI`
fi
if [[ -n "$DATA_DIR" && ! -d "$DATA_DIR" ]]
then echo "ERROR: directory \"$DATA_DIR\" does not exists."
     exit -1
fi
fic=${DATA_DIR:="./"}${FIC_INPUT}
if [ ! -f "$fic" ]
then echo "ERROR: input file \"$fic\" does not exists."
     exit -1
else
     echo " "
     echo "Describing file: "$(ls -go $fic)
     echo " "
fi
# describe the consolidated data file
awk	'BEGIN{FS="|"}
	{if(NR==1)	{cnt=split($0,vnam,"|");}
	 else if(NR==2)	{split($0,vsum,"|");split($0,vmax,"|");split($0,vmin,"|");}
	 else		{for(i=1;i<=NF;i++){vsum[i]=vsum[i]+$i;if(vmax[i]<$i)vmax[i]=$i;if($i<vmin[i])vmin[i]=$i;} }
	}
	END{print"\nStatistic by field (max/min/avg)\n";
		printf"column %i-%s\t\t%s\t%s\n",0,vnam[1],vmax[1],vmin[1];
		for(i=2;i<=cnt;i++){printf"Elemento numero %i => %s\t\t%s\t%s\t%s\n",i-1,vnam[i],vmax[i],vmin[i],vsum[i]/(NR-1);}
	    print"Total fields "cnt;
	    print"Total rows "NR-1;
	}' $fic | tee ${DATA_DIR:="./"}${FIC_INPUT}.stats

##
## Generate the list of dates file and softlink !!!
##
cat $fic | grep -v "Snap_id" | awk -F"|" '{ print substr($1,1,8) }' | sort -u > ${DATA_DIR}lista_fechas.txt
rm ./lista_fechas_$1.txt 2>/dev/null
ln -s ${DATA_DIR}lista_fechas.txt ./lista_fechas_$1.txt
