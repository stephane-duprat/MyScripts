#!/bin/bash
# #####################################################################
# $Header: filter.sh 24-dic-2009 sduprat_es Exp $
#
# filter.sh (bash script)
#
# Copyright (c) 2009, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     filter.sh
#
#    DESCRIPTION
#     A bash script which displays the min/max/avg/cnt for each column
#     of the consolidated data file.
#
#    NOTES
#
#    MODIFIED        (MM/DD/YY)
#     mellison_es     21/01/10   - Creation
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
eval `awk 'BEGIN{FS="="}$1~/^4KST_DATA_DIR$/{print "DATA_DIR="$2"/"}'  $INI`
eval `awk 'BEGIN{FS="="}$1~/^4KST_FIC_INPUT$/{print "FIC_INPUT="$2}'   $INI`
eval `awk 'BEGIN{FS="="}$1~/^4KST_FIC_FILTER$/{print "FIC_FILTER="$2}' $INI`
eval `awk 'BEGIN{FS="="}$1~/^4KST_FIC_FILTER_VAL$/{print "FIC_FILTER_VAL="$2}' $INI`
if [[ -n "$DATA_DIR" && ! -d "$DATA_DIR" ]]
then echo "ERROR: directory \"$DATA_DIR\" does not exists."
     exit -1
fi
fic_filter=${DATA_DIR:="./"}${FIC_FILTER}
fic=${DATA_DIR:="./"}${FIC_INPUT}
if [ ! -f "$fic" ]
then echo "ERROR: input file \"$fic\" does not exists."
     exit -1
fi
# describe the consolidated data file
awk	'BEGIN{FS="|";fil=split("'$FIC_FILTER_VAL'",vfil,",");}
	$1~/^Snap_id$/{print $0}
	{ for(i=1;i<=fil;i++) {sb=substr($1,9,2) ; if (match(sb,vfil[i])) print $0;} }
	' $fic | tee $fic_filter
echo $FIC_FILTER_VAL
	#$1~/22....\./{print $0}
	#$1~/23....\./{print $0}
#
