#!/bin/sh
# #####################################################################
# $Header: scale-adb.sh 08-Apr-2019 sduprat_es $
#
# scale-adb.sh <adb-name>
#
# Copyright (c) 2019, Oracle Pre-Sales (Spain).  All rights reserved.
#
#    NAME
#     scale-adb.sh
#
#    DESCRIPTION
#      Monitors and scale up and down an autonomous database !!!
#
#    NOTES
#     Dependencies:
#        list-compute.txt: a file listing ADB, which format must be:
#  bench-adw;ADW;ocid1.autonomousdatabase.oc1.eu-frankfurt-1.abtheljsm4ovlhbomyxq7v4t5k4pqhdukmotlysbz4r5e3zpuyk5opbkwmtq
#  bench-atp;ATP;ocid1.autonomousdatabase.oc1.eu-frankfurt-1.abtheljsl47zsgj2l273bxpbkgtmxlz77fnxlru6x7bi23kyhrrsqatwbalq
#
#        status-compute.sh: gets status of ADB from oci-cli
#        scale-cpu-adb.sh : scales ADB up or down        
#        monitor.adw.sql: SQL query monitoring ADB
#
#
#    VERSION            MODIFIED        (MM/DD/YY)
#                       sduprat_es      04/08/19   - Creation and mastermind
# 
# #####################################################################

ORACLE_HOME=/usr/lib/oracle/18.5/client64/bin
LD_LIBRARY_PATH=/usr/lib/oracle/18.5/client64/lib
PATH=$ORACLE_HOME:$PATH
TNS_ADMIN=/home/oracle/wallet_sprodb


export ORACLE_HOME LD_LIBRARY_PATH PATH
name=$1
homedir=/home/oracle/tuneCJ/Automatizacion/AutCpu
logdir=${homedir}/log
ficlog=${logdir}/$$.log
StringConnect="admin/xxxxxxx"
sleepinterval=60 
spininterval=30
cpumax=85  ### CPU usage max threshold (scale-up threshold)
cpumin=15  ### CPU usage min percent (scale-down threshold)
rqcoef=2   ### Coef to compute runqueue threshold !!!
cpuceil=10  ### Maximum number of CPUs allowed !!!
cpufloor=2 ### Minimum number of ocpus allowed !!!
cpuupinc=1 ### CPU increment when scaling up !!!
cpudowninc=1 ### CPU increment when scaling down !!!
upcount=0  ### Number of consecutive UP results !!!
downcount=0 ### Number of consecutive DOWN results !!!
uplimit=3  ### Number of consecutive UP results triggering scale-up !!!
downlimit=3 ### Number of consecutive DOWN results triggering scale-down !!!

#Iniciamos el fchero de los para que de error
echo  >$ficlog

ScaleAdb()
{
name=$1
updown=$2
cpucount=$3
runqueue=$4
cpupct=$5

if [ $updown == "UP" ]
then ## Scale up !!!
   newcpu=$( echo $cpucount"+"$cpuupinc | bc -l)
   if [ "$newcpu" -gt "$cpuceil" ]
   then
     newcpu=$cpuceil
   fi
else ### Scale down !!!
   newcpu=$( echo $cpucount"-"$cpudowninc | bc -l)
   if [ "$newcpu" -lt "$cpufloor" ]
   then
     newcpu=$cpufloor
   fi
fi
echo "Now Scaling "$updown" to "$newcpu" OCPUs"
${homedir}/scale-cpu-adb.sh ${name} $newcpu
}

GetStatus()
{
name=$1
status=$(${homedir}/status-compute.sh ${name} | awk '{ print $NF }')
echo "status is "$status
if [ ${status} == "AVAILABLE" ]
then
    return 1
else
    return 0
fi
}

poll()
{
adb=$1
rqcoef=$2
GetStatus $adb
status=$?
if [ "${status}" -eq "1" ]
then
   echo "start /home/oracle/tuneCJ/Automatizacion/AutCpu/monitor.adw.sql" | $ORACLE_HOME/sqlplus -s ${StringConnect} > $ficlog
   sleep 2
   cpucount=$(grep "CPUCOUNT=" $ficlog | cut -f3 -d";" | awk -F "=" '{ print $NF }')
   runqueue=$(grep "RUNQUEUE=" $ficlog| cut -f2 -d";"| awk -F "=" '{ print $NF }')
   cpupct=$(grep "CPUPCT=" $ficlog | cut -f1 -d";"| awk -F "=" '{ print $NF }')

   echo "CPUCOUNT="$cpucount
   echo "RUNQUEUE="$runqueue
   echo "CPUPCT="$cpupct

   rqmax=$(echo $cpucount"*"$rqcoef | bc -l)
   echo "Max RQ allowed="$rqmax

   if [ "$cpupct" -gt "$cpumax" -o "$runqueue" -gt "$rqmax" ]
   then
      if [ "$cpucount" -eq "$cpuceil" ]
      then
          echo "Max allowed CPUs reached ("$cpuceil")"
          return 0 ### Return 0 for "OK" !!!
      else
          return 1 ### Return 1 for UP !!!
      fi
   else 
      if [ "$cpupct" -lt "$cpumin" ]
      then
         ### Potentially scale down, unless num cpus equals cpufloor !!!
         if [ "$cpucount" -eq "$cpufloor" ]
         then
            echo "Min allowed CPUs reached ("$cpufloor")"
            return 0 ### Return 0 for "OK" !!!
         else
            return 2 ### Return 2 for "DOWN" !!!
         fi
      else
         return 0 ### Return 0 for "OK" !!!
      fi
   fi
else ### Not available: STOPPED or SCALING !!!
   return 0 ### Return 0 for "OK" !!!
fi
}

while true
do
   poll $name $rqcoef
   res=$?
    cpucount=$(grep "CPUCOUNT=" $ficlog | cut -f3 -d";" | awk -F "=" '{ print $NF }')
    runqueue=$(grep "RUNQUEUE=" $ficlog| cut -f2 -d";"| awk -F "=" '{ print $NF }')
    cpupct=$(grep "CPUPCT=" $ficlog | cut -f1 -d";"| awk -F "=" '{ print $NF }')
   echo "Poll result="$res
   if [ "$res" -eq "1" ]
   then
      upcount=$(echo $upcount"+"1 | bc -l)
      echo "--> Claiming for scale-up "$upcount"/"$uplimit
      downcount=0
      if [ "$upcount" -lt "$uplimit" ]
      then
          echo "Going to sleep "$spininterval" seconds before next check"
          sleep ${spininterval}
      fi
   elif [ "$res" -eq "2" ]
   then
      downcount=$(echo $downcount"+"1 | bc -l)
      echo "--> Claiming for scale-down "$downcount"/"$downlimit
      upcount=0
      if [ "$downcount" -lt "$downlimit" ]
      then
          echo "Going to sleep "$spininterval" seconds before next check"
          sleep ${spininterval}
      fi
   else
      downcount=0
      upcount=0
      echo "Everything fine, going to sleep "$sleepinterval" seconds"
      sleep ${sleepinterval}
   fi  
   ##
   if [ "$upcount" -eq "$uplimit" ]
   then
      ### I got $upcount consecutive times UP => Scale-up !!!
      echo "Starting scale-up"

      ScaleAdb $name "UP" $cpucount $runqueue $cpupct
      upcount=0
      downcount=0
   elif [ "$downcount" -eq "$downlimit" ]
   then
      ### I got $downcount consecutive times DOWN => scale-down !!!  
      echo "Starting scale-down"

      ScaleAdb $name "DOWN" $cpucount $runqueue $cpupct
      upcount=0
      downcount=0
   else
      ### Nothing to do !!!
      echo " "
   fi
done

exit 0
