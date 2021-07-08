#!/usr/bin/perl
# #####################################################################
# $Header: MM_4Kst.pl 24-dic-2009 sduprat_es Exp $
#
# MM_4Kst.pl
#
# Copyright (c) 2010, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     MM_4Kst.pl
#
#    DESCRIPTION
#     This perl script is the heart of the mathematical model 4Kst system.
#
#    NOTES
#
#    VERSION		MODIFIED        (MM/DD/YY)
#            		sduprat_es      24/12/09   - Creation and mastermind
#     			mellison_es     19/01/10   - implement the generation of spreadsheets and graphs automaticly	
#     			mellison_es     20/01/10   - implement the "project" functionality via .ini			
#     			mellison_es     21/01/10   - implement the io comparison 
#     			sduprat_es      25/01/10   - Substitute "switch" instruction by "if" - chmod +x against *.gp files		
#     			sduprat_es      28/01/10   - Supress last line of graphs source files (.dat) to enlarge the graph's scale	
#     			sduprat_es      11/02/10   - Rename program to MM_4Kst.pl for "Math Model Forecast"				
#     			sduprat_es      18/02/10   - Output format for GNUPlot managed with 4KST_GNUPLOT_TERM parameter			
#                                                    Adjust GNUPlot display look and feel				
#     1.2.3		acarrasc_es     24/02/10   - Subdir management for all output files	
#     1.2.4
#     1.2.5	        acarrasc_es     09/03/10   - meaning of each column generated 
#     1.2.6             sduprat_es      11/03/10   - Implement initial Lambda based on Standard Deviation - Standard Error
#     1.2.7             acarrasc_es     23/03/10   - redirect the output of each metric to its corresponding file
#     1.2.8             sduprat_es      17/05/10   - Use of the 4KST_ST_ADJUST_COEF parameter, to forecast with faster CPUs
#                                                  - Modify Response time formulas for I/O devices, with/without ErlangC
#                                                  - Adjust I/O forecast accuracy
#     1.2.8.1           sduprat_es      25/05/10   - Bug correction in the io-con Response Time computation 
#                                                  - Bug correction in the io-con and io-sin Queue Length computation
#     1.2.9             sduprat_es      25/05/10   - Include 4KST_TAG label in the graphs title.
#                                                  - Include timestamp and script version as information on the graphs.
#                                                  - In MED mode, forecast starts with the population average instead of the
#                                                  - sample average. Starting from Pop. Avg = Sample Avg + 1.96 Std Error, to 
#                                                  - work with the average value at a 95% confidence level.
#     1.2.10	        acarrasc_es     02/01/11   - 4KST_GNUPLOT_SIZE to gnuplot params 
#     1.2.12	        acarrasc_es     10/02/11   - Generating the singular points file which will read by *gp file to plot graphs
#     1.2.14            sduprat_es      14/02/11   - Introduce the tuning factor in the computation of the initial Lambda. 
#    						     The value of the tuning factor is read from 4Kst.ini as 4KST_TUNING_FACTOR parameter.
#     1.2.15            sduprat_es      21/02/11   - 4KST_CPU_COMPUTE_MODE parameter for the computation of the CPU utilization
#     1.3.0             sduprat_es      07/12/11   - Instance caging computation: computes the lowest NUM_CPUS value without degrading Response Time 
#                                                    and graphs all the caging iterations on the same graph.
#                                       11/01/12   - prints precision information on the graphs
#
#     1.3.1             sduprat_es      07/03/12   - Implements the validation graph functionality, for both CPU and I/O forecasts.
#     1.3.2             sduprat_es      09/04/13   - Add size in pixels parameter
#     1.3.2.1           sduprat_es      26/06/13   - Bug correction for I/O absolute error computation from AWR extraction
#     1.3.2.2           sduprat_es      12/12/13   - Bug correction for CPU absolute error computation from AWR extraction
#
#
# #####################################################################
#     Planned versions:
#
#     1.3.2                                        - Introduce the Load Balancing Factor for CPU forecasts
#                                                  - Compute CPU and IO forecasts precision with signed values instead of absolute values, and with 
#                                                    confidence level.
#
#
# #####################################################################
use Switch;
my $ficini ;
my $filemetricprefix;

sub GetParam
{
  ## Funcion de lectura de parametros en 4Kst.ini !!!
  $param = $_[0];

  open( FILE, "< $ficini" ) or die "Can't open $ficini : $!";
  @arr = ();
  while (<FILE>)
  {
    $line = $_;
    if ($line =~ /^$param=/) 
    {
        chomp($line);
        @arr = split(/=/, $line);
    }
  }
  return $arr[1];
}

sub ErlangC 
{ ## Funcion de calculo de ErlangC

  $queues = $_[0];
  $servers = $_[1];
  $service_time = $_[2];
  $system_arrival_rate = $_[3];
  $queue_arrival_rate   = $system_arrival_rate / $queues ;
  $queue_traffic        = $service_time * $queue_arrival_rate ;
  $rho                  = $queue_traffic / $servers ;
  $ErlangB              = $queue_traffic / ( 1 + $queue_traffic ) ;

# Jagerman's algorithm
$m=0;
$eb=0;
for ($m=2;$m<=$servers;$m++) {
     $eb = $ErlangB;
     $ErlangB = $eb * $queue_traffic / ( $m + $eb * $queue_traffic ) ;
}
  $EC = $ErlangB / ( 1 - $rho + $rho * $ErlangB ) ;
  return $EC;
}

sub compute 
{ ## the actual calculation to of 4kst
  $type = $_[0];
  $SERVICETIME = $_[1];
  $NUMSERV     = $_[2];
  $LAMBDA      = $_[3];
  $ERRPCT      = $_[4];

  $escrito=1;
  if ( $type !~ /cpu-con/ && $type !~ /cpu-sin/ && $type !~ /io-sin/ && $type !~ /io-con/ ) 
    {die "ERROR: program error at line $1; \"compute\" parameter \"$type\" is invalid";}
  $Uf=0;
  $cont=0;
  $forekst_limit=0;
  
  if ($ss_mode =~ /^slk$/) { open (FILE_SS,">$filemetricprefix-$type.slk") or die "Can't open $filemetricprefix-$type.slk : $1"; print FILE_SS "ID;PSCALC3\n"; }
  if ($graph_mode =~ /^gp$/) 
	{ open (FILE_GR,">$filemetricprefix-$type.dat") or die "Can't open $filemetricprefix-$type.dat : $1"; 
	  open (FILE_SING,">$filemetricprefix-$type.singular.dat") or die "Can't open $filemetricprefix-$type.singular.dat : $1"; }

  while ( $Uf <= 1 ) ## Si la utilizacion ferecasteada es mayor que 100%, paramos el forecast !!!
  { $Lambdaf = $LAMBDA * ( 1 + ( $cont * $incr ) );
    $DeltaWL = ( $cont * $incr ) * 100; ## Incremento de WL en porcentaje !!!

    ## Calculos con ErlangC !!!
    if ($type=~/cpu-con/)
    { 
      $forekst_limit=$cpulimit;
      $qt_limit = $cpuqtlimit;
      $Uf = ( $SERVICETIME * $Lambdaf ) / $NUMSERV;
      $UfPct = $Uf * 100;
      $ERLANGC = ErlangC (1,$NUMSERV,$Lambdaf,$SERVICETIME);		
      $Qtf = ( $ERLANGC * $SERVICETIME ) / ( $NUMSERV * ( 1 - $Uf ) ) ;
      $Rtf = $SERVICETIME + $Qtf;
      $Qf = $Lambdaf * $Qtf;
      if ($Rtf > 0)
      {
          $QtPctRt = ( $Qtf / $Rtf ) * 100; ## Queue Time como porcentaje de Response Time !!!
      }
      else
      {
         $QtPctRt = 0;
      }
    } 
    elsif ($type=~/io-con/)
    { 
      $forekst_limit=$iolimit;
      $qt_limit = $iolimit;
      $Uf = ( $SERVICETIME * $Lambdaf ) / $NUMSERV;
      $UfPct = $Uf * 100;
      $ERLANGC = ErlangC ($NUMSERV,1,$Lambdaf,$SERVICETIME);
      $Qtf = ( $ERLANGC * $SERVICETIME ) / ( 1 - $Uf ) ;
      $Rtf = $SERVICETIME + $Qtf;
      $Qf = ($Lambdaf/$NUMSERV) * $Qtf;
      $QtPctRt = ( $Qtf / $Rtf ) * 100; ## Queue Time como porcentaje de Response Time !!!
    } 
    elsif ($type=~/cpu-sin/)
    { 
      $forekst_limit=$cpulimit;
      $qt_limit = $cpuqtlimit;
      $Uf = ( $SERVICETIME * $Lambdaf ) / $NUMSERV;
      $UfPct = $Uf * 100;
      $Rtf = $SERVICETIME / ( 1 - ( $Uf**$NUMSERV ));
      $Qtf = $Rtf - $SERVICETIME;
      $Qf = $Lambdaf * $Qtf;
      $QtPctRt = ( $Qtf / $Rtf ) * 100; ## Queue Time como porcentaje de Response Time !!!
    } 
    elsif ($type=~/io-sin/)
    { 
      $forekst_limit=$iolimit;
      $qt_limit = $iolimit;
      $Uf = ( $SERVICETIME * $Lambdaf ) / $NUMSERV;
      $UfPct = $Uf * 100;
      $Rtf = $SERVICETIME / ( 1 - $Uf);		## Formula changed on 18/05/2010 by sduprat_es !!!
      $Qtf = $Rtf - $SERVICETIME;
      $Qf = ($Lambdaf/$NUMSERV) * $Qtf;
      $QtPctRt = ( $Qtf / $Rtf ) * 100; ## Queue Time como porcentaje de Response Time !!!
    }
    ##
    ## Presentacion de los resultados en formato CSV !!!
    ##
    print fich "$DeltaWL %$sep$Lambdaf$sep$UfPct$sep$Rtf$sep$Qtf$sep$Qf$sep$QtPctRt %\n";
    ## 
    ## Incrementamos Lambdaf
    ##
    $cont = $cont + 1;
    $DeltaWL100 = $DeltaWL/100 ;
    $UfPct100 = $UfPct/100 ;
    $QtPctRt100 = $QtPctRt/100 ;
    if ($ss_mode =~ /^slk$/) { print FILE_SS "C;X1;Y$cont;K$DeltaWL100\nC;X2;Y$cont;K$Lambdaf\nC;X3;Y$cont;K$UfPct100\nC;X4;Y$cont;K$Rtf\nC;X5;Y$cont;K$Qtf\nC;X6;Y$cont;K$Qf\nC;X7;Y$cont;K$QtPctRt100\n"; }
    #if ($ss_mode =~ /^slk$/) { print FILE_SS "C;X1;Y$cont;K\"$DeltaWL %\"\nC;X2;Y$cont;K$Lambdaf\nC;X3;Y$cont;K$UfPct\nC;X4;Y$cont;K$Rtf\nC;X5;Y$cont;K$Qtf\nC;X6;Y$cont;K$Qf\nC;X7;Y$cont;K\"$QtPctRt %\"\n"; }
    if (($graph_mode =~ /^gp$/ )&& ($Rtf > 0) ) 
	{ 
        if (($UfPct >= $forekst_limit || $QtPctRt >= $qt_limit) && ($escrito == 1))
        {
             $maxwl=$DeltaWL;
             $maxwlerr=($maxwl*$ERRPCT)/100;
             print FILE_SING "$DeltaWL $Rtf $maxwlerr\n";
             $cpu = sprintf("%.2f", $UfPct);
             $qt = sprintf("%.2f", $QtPctRt);
             $precision = sprintf("%.2f", $maxwlerr);
             if ($type=~/cpu-/) {$leyenda= "$DeltaWL% +/- $precision% increased workload at $cpu% CPU usage and $qt% Queue time";}
             elsif ($type=~/io-/) {$leyenda= "$DeltaWL% +/- $precision% increased workload at $cpu% IO usage";}
             $escrito=0;
         }
         print FILE_GR "$DeltaWL $Rtf\n";
}
  }
  if ($ss_mode    =~ /^slk$/) { print FILE_SS "E\n"; close (FILE) ; }
  if ($graph_mode =~ /^gp$/)  { close (FILE_GR) ; close (FILE_SING); }

}

sub CalcAvg
{
## Algoritmo de calculo de la media aritmetica de un conjunto de valores !!!
##
## Entrada: {Xi}=(X1,X2,...,Xn)
## Salida:  (1/n)*SUM(Xi)
##
my $avg;
my $n;
my $sum;
my $i;

@values = split (/;/ , $_[0]);
$n = @values; ## Numero de elementos en el array !!!
$sum = 0;

for ($i=0;$i<=($n-1);$i++)
{
    $sum = $sum + $values[$i];
}
$avg = $sum / $n;
return $avg;
}

sub CalcStdDev
{
## Algoritmo de calculo de la desviacion estandar de un conjunto de valores !!!

## Entrada: {Xi}=(X1,X2,...,Xn)
## Salida:  sqrt ( (1/(n-1)) * SUM[(Xi-CalcAvg({Xi})^2)] )
##
my $avg;
my $n;
my $sum;
my $StdDev;
my $i;

@values = split (/;/, $_[0]);
$n = @values; ## Numero de elementos en el array !!!

##
## Primero se calcula la media aritmetica del conjunto de valores !!!
##
$avg = CalcAvg ($_[0]);

##
## Ahora calculamos la suma SUM[(Xi-CalcAvg({Xi})^2)] !!!
##
$sum = 0;
for ($i=0;$i<=($n-1);$i++)
{
    $sum = $sum + ($values[$i]-$avg)**2;
}
##
## Ahora solo queda terminar el calculo de la desviacion estandar !!!
##
$StdDev = sqrt ( (1/($n-1)) * $sum );
return $StdDev;
}

###########
## MAIN ###
###########
my $ScriptVersion="4Kst v1.3.1";
my $StAdjustCoef;
my $StAdjustCoefIO;
my $ValoresLambda;
my $LambdaStdDev;
my $LambdaStdErr;
my $IoUPos;
my $Tag;
my $Project;
my $BestMetricForCPU;
my $BestMetricForIO;
my $BestCPUPrecision;
my $BestIOPrecision;

$numArgs = $#ARGV + 1;
my $fileprefix ;
if ($numArgs > 1 )	{ print "ERROR: to many arguments\nUSAGE: MM_4Kst.pl [project]\n"; exit -1; }
if ($numArgs == 1 )	
{ 
    if ( $ARGV[0] =~ /-version/ )
    {
        print "MM_4Kst.pl version $ScriptVersion\n";
        exit -2;
    }
    else
    {
        $fileprefix = "MM_4Kst-$ARGV[0]"; $Project = $ARGV[0] 
    }
}
else			{ $fileprefix = "MM_4Kst"; }
$ficini	= "$fileprefix.ini" ;

#my $ficini = "4Kst.ini";
#foreach $argnum (0 .. $#ARGV) {
#   print "$ARGV[$argnum]\n";
#}

## get project parameters
$dirname=GetParam("4KST_DATA_DIR");
# if the filtered file is not set use the complete compostie file
$filename=GetParam("4KST_FIC_FILTER");
if ($filename =~/^$/) { $filename=GetParam("4KST_FIC_INPUT");}
$filename="$dirname/$filename";

## get mode parameters
$ss_mode      = GetParam("4KST_SS_MODE");
$graph_mode   = GetParam("4KST_GRAPH_MODE");
$cpu_con_mode = GetParam("4KST_CPU_CON_MODE");
$cpu_sin_mode = GetParam("4KST_CPU_SIN_MODE");
$io_con_mode  = GetParam("4KST_IO_CON_MODE");
$io_sin_mode  = GetParam("4KST_IO_SIN_MODE");
$gpterm       = GetParam("4KST_GNUPLOT_TERM");
$gpsize       = GetParam("4KST_GNUPLOT_SIZE");
$cpulimit     = GetParam("4KST_CPU_LIMIT");
$iolimit      = GetParam("4KST_IO_LIMIT");
$cpuqtlimit   = GetParam("4KST_CPU_QT_LIMIT");
$TuningFactor = GetParam("4KST_TUNING_FACTOR");
$CPUCompMode=GetParam("4KST_CPU_COMPUTE_MODE");

$numcpu=GetParam("4KST_NUM_CPU");
$numio=GetParam("4KST_NUM_IO");
$StAdjustCoef=GetParam("4KST_ST_ADJUST_COEF");
$StAdjustCoefIO=GetParam("4KST_IO_ST_ADJUST_COEF");
$Tag=$Project." - ".GetParam("4KST_TAG");
$gppixel=GetParam("4KST_GNUPLOT_PIXELS");
if ($gppixel =~/^$/) { $gppixel = "800,600";}

##
## Metricas de Forecast
##
$metrics=GetParam("4KST_METRICS");
@metricas = split(/\,/,$metrics); 
$len = @metricas;

##
## Posiciones de Snap_id, Delta, y DBCPU en el fichero de entrada !!!
##
$pos_snap = GetParam("4KST_POS_SNAP");
$pos_delta = GetParam("4KST_POS_DELTA");
$pos_dbcpu = GetParam("4KST_POS_DBCPU");
$IoUPos=GetParam("4KST_IO_U_CONS_POS"); ## I/O devices generic utilisation position !!!

##
## Valor inicial de Service Time para los forecast (media ponderada o maximo) !!!
##
$InitialLambda = GetParam("4KST_INITIAL_LAMBDA");

##
## Incremento de Lambda en cada iteracion de forecast !!!
##
$incr = GetParam("4KST_INCR_LAMBDA");

##
## Read of instance caging parameters !!!
##
$CagingMode = GetParam("4KST_CAGING_MODE");
if ($CagingMode =~/^$/) { $CagingMode="FALSE";}
$CagingInterval = GetParam("4KST_CAGING_INTERVAL");
$CagingIncr = GetParam("4KST_CAGING_INCR");
$CagingWlTgt = GetParam("4KST_CAGING_WL_TARGET");
#
##
## Lectura de la linea de headers !!!
##
open( FILE, "< $filename" ) or die "Can't open  $filename : $!";
$line = <FILE>;
chomp($line);
@headers = split(/\|/, $line);
close FILE;
#
##
## Creacion de carpetas identificadoras del modelo ejecutado
##
if ( $CagingMode =~ /FALSE/)
{
    $MM = '/MM';
}
else
{
    $MM = '/CAGING';
}
$dir=$dirname.$MM;
if (-e $dir){
echo;
}else{
      mkdir $dir;
}


if ( $CagingMode =~ /FALSE/) ## Traditional forecasting, without caging iterations !!!
{
##
## Initialize Precision variables !!!
##
$BestMetricForCPU = "";
$BestMetricForIO = "";
$BestCPUPrecision = 999;
$BestIOPrecision = 999;
##
for ($i=0;$i <= ($len -1);$i++)
{ 
  $data = $dirname.$MM."/".@headers[$metricas[$i]]."_".$InitialLambda.".txt";
  open(fich," >> $data "); 
  $ficerror = $dirname.$MM."/".@headers[$metricas[$i]]."_".$InitialLambda.".err";
  open (ficerr, " >> $ficerror ");
  $ficvalidate = $dirname.$MM."/VALIDATION_".@headers[$metricas[$i]]."_".$InitialLambda.".val";
  $ficvalidateCPUgp = $dirname.$MM."/VALIDATION_CPU_".@headers[$metricas[$i]]."_".$InitialLambda.".gp";
  $ficvalidateCPUgif = $dirname.$MM."/VALIDATION_CPU_".@headers[$metricas[$i]]."_".$InitialLambda.".$gpterm";
  $ficvalidateIOgp = $dirname.$MM."/VALIDATION_IO_".@headers[$metricas[$i]]."_".$InitialLambda.".gp";
  $ficvalidateIOgif = $dirname.$MM."/VALIDATION_IO_".@headers[$metricas[$i]]."_".$InitialLambda.".$gpterm";

  ##
  ## Relacion de parametros leidos en el fichero 4Kst.ini
  ##

  print fich "**********************************************************\n";
  print fich "* Lista de parametros leidos en el fichero 4Kst.ini      *\n";
  print fich "**********************************************************\n";
  print fich "\n";

  print fich "Numero de CPUS => $numcpu\n";
  print fich "Numero de IO devices => $numio\n";
  print fich "Fichero de entrada => $filename\n";
  print fich "Posicion de Snap_id => $pos_snap\n";
  print fich "Posicion de Delta => $pos_delta\n";
  print fich "Posicion de DBCPU => $pos_dbcpu\n";
  print fich "Posicion de  IO Util => $IoUPos\n";
  print fich "Metricas de Forecast:\n";
  for ($j=0;$j <= ($len -1);$j++)         { print fich "    Posicion $metricas[$j] => @headers[$metricas[$j]]\n"; }
  print fich "Valor de Lambda inicial para Forecast = $InitialLambda\n";
  print fich "Valor de incremento de Lambda = $incr\n";
  print fich "Valor del coeficiente de ajuste del Service Time de CPU = $StAdjustCoef\n";
  print fich "Valor del coeficiente de ajuste del Service Time de I/O = $StAdjustCoefIO\n";
  print fich "CPU utilization computational mode => $CPUCompMode\n";
  print fich "\n";
  print fich "\n\n";
  ###
 
  print fich "***********************************************************************************************************************\n";
  print fich "*                               Forecast basado en la metrica @headers[$metricas[$i]]                                 *\n";
  print fich "*                                                -----                                                                *\n";
  print fich "* NOTA: El significado de cada columna es el siguiente:                                                               *\n";
  print fich "* ID_SNAP ; DELTA ; NUM_CPUS ; % USO CPU ; ID_METRICA ; ARRIVAL RATE ; SERVICE TIME CPU ; SERVICE TIME * ARRIVAL RATE CPU; SERVICE TIME IO ; SERVICE TIME * LAMBDA IO    *\n";
  print fich "***********************************************************************************************************************\n";
  print fich "\n\n";
  $sep=";";
  $numlin=0;
  $SumLambda=0;
  $SumSt=0;
  $SumStIo=0;
  $SumStLambda=0;
  $SumStIoLambda=0;
  $LambdaMax=0;
  $ValoresLambda = "";
  $LambdaStdDev = 0;
  $LambdaStdErr = 0;
  # define the basename for all outputfiles
  $filemetricprefix = "$dir/$fileprefix-@headers[$metricas[$i]]-$InitialLambda";

  open( FILE, "< $filename" ) or die "Can't open $filename : $!";
  while( <FILE> ) 
  {
    $line = $_;
    if ($line !~ /Snap_id/)
    {
        chomp($line);
        @arr = split(/\|/, $line);
        ##
        $snapid=$arr[$pos_snap];
        $delta=$arr[$pos_delta];
        $dbcpu=$arr[$pos_dbcpu];
        $metrica=@arr[$metricas[$i]];
        ##
        ## % de CPU utilizado por la instancia !!!
        ##
        $U = (($dbcpu / 1000000) / ($numcpu * $delta));
        $pctcpu = $U * 100 ;
        ##
        ## Arrival rate (lambda) !!!
        ##
        $lambda = ( $metrica / $delta );
        if ( $lambda == 0 ) { print "==>$snapid##$metrica--$delta\n"; }
        $ValoresLambda = "$ValoresLambda;$lambda";
        ##
        ## Service Time !!!
        ##
        $St = ( $U * $numcpu ) / $lambda ;
        ##
        ## Service Time * Lambda (utilizado para la media ponderada del Service time) !!!
        ##
        $StLambda = $St * $lambda ;
        ##
        ## I/O devices generic utilisation and other I/O specific metrics !!!
        ##
        $Uio = $arr[$IoUPos] / 100;
        $Stio = ( $Uio * $numio ) / $lambda;
        $StioLambda = $Stio * $lambda;
        ##
        ## Calculo de valores acumulados !!!
        ##
        $numlin = $numlin + 1;
        $SumSt = $SumSt + $St;
        $SumStIo = $SumStIo + $Stio;
        $SumLambda = $SumLambda + $lambda;
        $SumStLambda = $SumStLambda + $StLambda;
        $SumStIoLambda = $SumStIoLambda + $StioLambda;
        if ( $lambda > $LambdaMax )
        {
            $LambdaMax = $lambda;
        }
        ## 
        ## Presentacion de los resultados en formato CSV !!!
        ##
        print fich "$snapid$sep$delta$sep$numcpu$sep$pctcpu$sep$metrica$sep$lambda$sep$St$sep$StLambda$sep$Stio$sep$StioLambda\n";
        print ficerr "$snapid$sep$numcpu$sep$lambda$sep$U$sep$Uio\n";
    }
    else ## Leemos la linea de Headers del fichero, donde vienen los nombre de las metricas !!!
    {
        chomp($line);
        @header = split(/\|/, $line);
    }
  } ## Fin WHILE
  close ficerr;

  ##
  ## Calculo de valores acumulados !!!
  ##
  $StMedio = ( $SumSt / $numlin );
  $StMedioIo = ( $SumStIo / $numlin );
  $StMedioPond = ( $SumStLambda / $SumLambda );
  $StMedioPondIo = ( $SumStIoLambda / $SumLambda );
  $LambdaMedio = ( $SumLambda / $numlin );
  $ValoresLambda = substr $ValoresLambda, 1;
  $LambdaStdDev = CalcStdDev($ValoresLambda);
  $LambdaStdErr = $LambdaStdDev / sqrt ($numlin);

  ## 
  ## Calculo de la precision del Forecast: agregado por SDU el 22/02/2011
  ## Validation file generation: sduprat_es 07/03/2012
  ##
  my $SumErrCpu = 0;
  my $SumErrIo = 0;
  my $numsnap = 0;
  open (ficerr, " < $ficerror ") or die "Can't open $ficerror : $1";
  open (ficval, " >> $ficvalidate ") or die "Can't open $validate : $1";
  while( <ficerr> )
  {
      $line = $_;
      chomp($line);
      @arr = split(/;/, $line);
      ##
      ## Lectura del fichero
      ##
      $snapid=$arr[0];
      $numcpu=$arr[1];
      $lambda=$arr[2];
      $UCpuReal=$arr[3];
      $UIoReal=$arr[4];
      ##
      $UCpuForecast= ($lambda * $StMedioPond) / $numcpu ;
      $UIoForecast= ($lambda * $StMedioPondIo) / $numio ;
      ##
      ## Compute absolute value average error: should be substitued by signed average error +/- 1.96*Standard Error
      ##
      if ( $UCpuReal == 0 )
      {
         $UCpuReal=$UCpuForecast;
      }
      if ( $UIoReal == 0 )
      {
         $UIoReal=$UIoForecast;
      }
      ##
      ##
      ## Bug correction by sduprat_es, 12/12/2013: test if UCpuReal equals to zero (AWR extractions)
      ##
      if ( $UCpuReal > 0 )
      {
          $SignedErrorPctCpu = ( $UCpuForecast - $UCpuReal ) / $UCpuReal;
      }
      else
      {
          $SignedErrorPctCpu = 0;
      }
      ##
      ## Bug correction by sduprat_es, 26/06/2013: test if UioReal equals to zero (AWR extractions)
      ##
      if ( $UIoReal > 0 )
      {
         $SignedErrorPctIo  = ( $UIoForecast - $UIoReal ) / $UIoReal;
      }
      else
      {
         $SignedErrorPctIo  = 0;
      }
      $ErrorPctCpu = abs( $SignedErrorPctCpu );
      $ErrorPctIo = abs( $SignedErrorPctIo );
      ##
      $SumErrCpu = $SumErrCpu + $ErrorPctCpu;
      $SumErrIo = $SumErrIo + $ErrorPctIo;
      $numsnap = $numsnap + 1;
      ##
      ## Write the validation file !!!
      ## 
      print ficval "$snapid $SignedErrorPctCpu $SignedErrorPctIo\n";
  }
  close ficerr;
  close ficval;
  ## 
  ## Calculo del error medio en valor absoluto !!!
  ##
  $ErrorPctCpu = ($SumErrCpu / $numsnap) * 100; 
  $ErrorPctIo  = ($SumErrIo / $numsnap) * 100; 
  ##
  if ( $ErrorPctCpu < $BestCPUPrecision )
  {
      $BestCPUPrecision = $ErrorPctCpu;
      $BestMetricForCPU = @headers[$metricas[$i]];
  }
  if ( $ErrorPctIo < $BestIOPrecision )
  {
      $BestIOPrecision = $ErrorPctIo;
      $BestMetricForIO = @headers[$metricas[$i]];
  }
  ##
  ## Generate validation graphs, for both CPU and IO forecasts: added by sduprat_es 07/03/2012 !!!
  ##
  open (ficvalgp, " >> $ficvalidateCPUgp ") or die "Can't open $validateCPUgp : $1";
  print ficvalgp "#!/usr/bin/gnuplot\nreset\nset terminal $gpterm $gpsize size $gppixel\n";
  print ficvalgp "set style line 1 lt 1 lc rgb 'black' lw 1\n";
  print ficvalgp "set style line 2 lt 2 lc rgb 'gray' lw 0.25\n";
  print ficvalgp "set style line 3 pt 6 ps 2 lc rgb 'green' lw 1.5\n";
  print ficvalgp "set style line 4 lt 0 lc rgb 'black' lw 2\n";
  print ficvalgp "set style line 5 lt 0 lc rgb 'blue' lw 3\n";
  print ficvalgp "set ylabel \"CPU Utilization (Observed - Forecasted) %\" textcolor rgb 'blue'\n";
  print ficvalgp "set xlabel \"Snapshots\" textcolor rgb 'blue'\n";
  print ficvalgp "set title \"$Tag - 4Kst by @headers[$metricas[$i]] - CPU Validation graph\" textcolor rgb 'blue'\n";
  print ficvalgp "set timestamp \"Generated on %d/%m/%y %H:%M by $ScriptVersion\"\n";
  print ficvalgp "set mxtics\nset mytics\nset xtics\nset ytics\nset grid xtics ytics mxtics mytics ls 1, ls 2\n";
  print ficvalgp "set yrange [-100:100]\n";
  print ficvalgp "set key reverse Left bmargin\nset grid\nset style data histogram\nset style histogram clustered gap 2\n";
  print ficvalgp "plot \"$ficvalidate\" using (\$2*100) title \"Delta (%) observed vs forecasted CPU util. (Avg=$ErrorPctCpu)\"";
  close ficvalgp;

  open (ficvalgp, " >> $ficvalidateIOgp ") or die "Can't open $validateIOgp : $1";
  print ficvalgp "#!/usr/bin/gnuplot\nreset\nset terminal $gpterm $gpsize size $gppixel\n";
  print ficvalgp "set style line 1 lt 1 lc rgb 'black' lw 1\n";
  print ficvalgp "set style line 2 lt 2 lc rgb 'gray' lw 0.25\n";
  print ficvalgp "set style line 3 pt 6 ps 2 lc rgb 'green' lw 1.5\n";
  print ficvalgp "set style line 4 lt 0 lc rgb 'black' lw 2\n";
  print ficvalgp "set style line 5 lt 0 lc rgb 'blue' lw 3\n";
  print ficvalgp "set ylabel \"IO Utilization (Observed - Forecasted) %\" textcolor rgb 'blue'\n";
  print ficvalgp "set xlabel \"Snapshots\" textcolor rgb 'blue'\n";
  print ficvalgp "set title \"$Tag - 4Kst by @headers[$metricas[$i]] - I/O Validation graph\" textcolor rgb 'blue'\n";
  print ficvalgp "set timestamp \"Generated on %d/%m/%y %H:%M by $ScriptVersion\"\n";
  print ficvalgp "set mxtics\nset mytics\nset xtics\nset ytics\nset grid xtics ytics mxtics mytics ls 1, ls 2\n";
  print ficvalgp "set yrange [-100:100]\n";
  print ficvalgp "set key reverse Left bmargin\nset grid\nset style data histogram\nset style histogram clustered gap 2\n";
  print ficvalgp "plot \"$ficvalidate\" using (\$3*100) title \"Delta (%) observed vs forecasted IO util. (Avg=$ErrorPctIo)\"";
  close ficvalgp;

  `chmod +x $ficvalidateCPUgp`;
  `\"$ficvalidateCPUgp\" > \"$ficvalidateCPUgif\"`;
  `chmod +x $ficvalidateIOgp`;
  `\"$ficvalidateIOgp\" > \"$ficvalidateIOgif\"`;

  ## End Generate validation graph
  ## 
  ## Presentacion de resultados acumulados
  ##
  print fich "\n\n";
  print fich "*****************************************************************************************************\n";
  print fich "*       Resultados estadisticos bases del Forecasting - metrica @headers[$metricas[$i]]             *\n";
  print fich "*****************************************************************************************************\n";
  print fich "\n\n";
  print fich "Service Time CPU (medio)           = $StMedio\n";
  print fich "Service Time CPU (media ponderada) = $StMedioPond\n";
  print fich "Service Time I/O (medio)           = $StMedioIo\n";
  print fich "Service Time I/O (media ponderada) = $StMedioPondIo\n";
  print fich "Arrival rate (media muestra)   = $LambdaMedio\n";
  print fich "Arrival rate (Standard Error)  = $LambdaStdErr\n";
  print fich "Arrival rate (media poblacion) = $LambdaMedio +/- $LambdaStdErr al nivel de confianza 68%\n";
  $num = 1.96 * $LambdaStdErr;
  print fich "Arrival rate (media poblacion) = $LambdaMedio +/- $num al nivel de confianza 90%\n";
  print fich "Arrival rate (max)             = $LambdaMax\n";
  print fich "Arrival Rate Medio StdDev      = $LambdaStdDev\n\n";
  print fich "Arrival Rate = $LambdaMedio +/- $LambdaStdDev al nivel de confianza 68%\n";
  $num = 1.96 * $LambdaStdDev;
  print fich "Arrival Rate = $LambdaMedio +/- $num al nivel de confianza 90%\n";
  print fich "CPU Forecast Average Precision = +/- $ErrorPctCpu %\n";
  print fich "IO Forecast Average Precision = +/- $ErrorPctIo %\n";
  close FILE;

  $Stf=$StMedioPond*$StAdjustCoef; ## Final Service Time for CPU forecasts
  $StfIo=$StMedioPondIo*$StAdjustCoefIO; ## Final Service Time for I/O forecasts
  if ( $InitialLambda =~ /MED/ )
  { $LambdaIni = $LambdaMedio + 1.96 * $LambdaStdErr; }## Modif by SDU on 26/05/2010: starting the forecast with the population
                                                       ## average value at 95% confidence level !!!
  elsif ($InitialLambda =~ /MAX/ )
  { $LambdaIni = $LambdaMax;   } ## Empezamos el Forecast con el valor maximo de Lambda !!!
  elsif ( $InitialLambda =~ /STDEV/ )
  { $LambdaIni = $LambdaMedio + 1.96 * $LambdaStdDev; } ## Empezamos el Forecast con el valor medio de Lambda
                                                        ## al cual sumamos 1.96*StdDev. Porque estadisticamente,
                                                        ## 90 % de los valores de Lambda estan entre $LambdaMedio +/- 1.96*StdDev
                                                        ## lo que significa que 95% de los valores de Lambda son menores o iguales
                                                        ## a $LambdaMedio + 1.96*StdDev !!!
  else
  { ## Si caemos aqui, es que hay un error en el fichero INI para el parametro 4KST_INITIAL_LAMBDA !!!
    print "Error en el valor del parametro 4KST_INITIAL_LAMBDA\n";
    exit -1;
  }
  ##
  ## Tuning factor: decrease Lambda initial value
  ##
  $LambdaIni = $LambdaIni * $TuningFactor;
  ##
  ##
  ## Aqui empiezan los Forecast !!!
  ##
  print "@headers[$metricas[$i]] - Forecasting with Initial Lambda ($InitialLambda mode) = $LambdaIni\n";
  print "@headers[$metricas[$i]] - Forecasting with CPU Service Time Adjustment Coef. = $StAdjustCoef\n";
  print "@headers[$metricas[$i]] - Forecasting with I/O Service Time Adjustment Coef. = $StAdjustCoefIO\n";
  print "@headers[$metricas[$i]] - Forecasting with Tuning Factor Adjustment Coef. = $TuningFactor\n";
  print fich "@headers[$metricas[$i]] - Forecasting with Initial Lambda ($InitialLambda mode) = $LambdaIni\n";
  print fich "@headers[$metricas[$i]] - Forecasting with CPU Service Time Adjustment Coef. = $StAdjustCoef\n";
  print fich "@headers[$metricas[$i]] - Forecasting with I/O Service Time Adjustment Coef. = $StAdjustCoefIO\n";
  print fich "@headers[$metricas[$i]] - Forecasting with Tuning Factor Adjustment Coef. = $TuningFactor\n";
  ##
  if ( $cpu_sin_mode !~ /^$/ )
  { ##
    ## Ahora empezamos el Forecasting con el modelo matematico sencillo (sin ErlangC) !!!
    ##
    ## La idea es hacer crecer el valor de Lambda (Lambdaf) poco a poco, manteniendo constante St (Stf), y calcular
    ## la utilizacion (Uf), el tiempo de respuesta (Rtf), Queue Time (Qtf), y Queue Length (Qf) !!!
    ##
    print fich "\n\n";
    print fich "**************************************************************************************************************************\n";
    print fich "*                                Forecasting Modelo Matematico Sencillo (sin ErlangC)                                    *\n";
    print fich "*                                                -----                                                                   *\n";
    print fich "* NOTA: El significado de cada columna es el siguiente:                                                                  *\n";
    print fich "* INCREMENTO DEL WORKLOAD (%) ; ARRIVAL RATE ; USO CPU (%) ; RESPONSE TIME ; QUEUE TIME ; QUEUE LENGTH ; QUEUE TIME (%)  *\n";
    print fich "**************************************************************************************************************************\n";
    print fich "\n\n";
    compute("cpu-sin",$Stf,$numcpu,$LambdaIni,$ErrorPctCpu);
  }
  if ( $io_sin_mode !~ /^$/ )
  { ##
    ## Ahora empezamos el Forecasting con el modelo matematico sencillo (sin ErlangC) !!!
    ##
    ## La idea es hacer crecer el valor de Lambda (Lambdaf) poco a poco, manteniendo constante St (StfIo), y calcular
    ## la utilizacion (UfIo), el tiempo de respuesta (RtfIo), Queue Time (QtfIo), y Queue Length (QfIo) !!!
    ##
    print fich "\n\n";
    print fich "**************************************************************************************************************************\n";
    print fich "*                                Forecasting Modelo Matematico Sencillo (sin ErlangC)                                    *\n";
    print fich "*                                                -----                                                                   *\n";
    print fich "* NOTA: El significado de cada columna es el siguiente:                                                                  *\n";
    print fich "* INCREMENTO DEL WORKLOAD (%) ; ARRIVAL RATE ; USO I/O (%) ; RESPONSE TIME ; QUEUE TIME ; QUEUE LENGTH ; QUEUE TIME (%)  *\n";
    print fich "**************************************************************************************************************************\n";
    print fich "\n\n";
    compute("io-sin",$StfIo,$numio,$LambdaIni,$ErrorPctIo);
  }
  if ( $cpu_con_mode !~ /^$/ )
  { ##
    ## Ahora empezamos el Forecasting con el modelo matematico esencial (con ErlangC) !!!
    ##
    print fich "\n\n";
    print fich "**************************************************************************************************************************\n";
    print fich "*                                Forecasting Modelo Matematico Esencial (con ErlangC)                                    *\n";
    print fich "*                                                -----                                                                   *\n";
    print fich "* NOTA: El significado de cada columna es el siguiente:                                                                  *\n";
    print fich "* INCREMENTO DEL WORKLOAD (%) ; ARRIVAL RATE ; USO CPU (%) ; RESPONSE TIME ; QUEUE TIME ; QUEUE LENGTH ; QUEUE TIME (%)  *\n";
    print fich "**************************************************************************************************************************\n";
    print fich "\n\n";
    compute("cpu-con",$Stf,$numcpu,$LambdaIni,$ErrorPctCpu);
  }
  if ( $io_con_mode !~ /^$/ )
  { ##
    ## Ahora empezamos el Forecasting con el modelo matematico esencial (con ErlangC) !!!
    ##
    print fich "\n\n";
    print fich "**************************************************************************************************************************\n";
    print fich "*                                Forecasting Modelo Matematico Esencial (con ErlangC)                                    *\n";
    print fich "*                                                -----                                                                   *\n";
    print fich "* NOTA: El significado de cada columna es el siguiente:                                                                  *\n";
    print fich "* INCREMENTO DEL WORKLOAD (%) ; ARRIVAL RATE ; USO I/O (%) ; RESPONSE TIME ; QUEUE TIME ; QUEUE LENGTH ; QUEUE TIME (%)  *\n";
    print fich "**************************************************************************************************************************\n";
    print fich "\n\n";
    compute("io-con",$StfIo,$numio,$LambdaIni,$ErrorPctIo);
  }
  close fich;
  ###
  ### if graph mode was selected, generate gnuplot
  $maxwlDown = $maxwl - $maxwlerr;
  $maxwlUp   = $maxwl + $maxwlerr;
  if ($graph_mode =~ /^gp$/ && ($cpu_con_mode !~/^$/ || $cpu_sin_mode !~/^$/ || $io_con_mode !~/^$/  || $io_sin_mode !~/^$/))
  { open (FILE_GR,">$filemetricprefix.gp") or die "Can't open $filemetricprefix.gp : $1";
    print FILE_GR "#!/usr/bin/gnuplot\nreset\nset terminal $gpterm $gpsize size $gppixel\n";
    print FILE_GR "set style line 1 lt 1 lc rgb 'black' lw 1\n";
    print FILE_GR "set style line 2 lt 2 lc rgb 'gray' lw 0.25\n";
    print FILE_GR "set style line 3 pt 6 ps 2 lc rgb 'green' lw 1.5\n";
    print FILE_GR "set style line 4 lt 0 lc rgb 'black' lw 2\n";
    print FILE_GR "set style line 5 lt 0 lc rgb 'blue' lw 3\n";
    print FILE_GR "set xlabel \"Increased Workload (%)\" textcolor rgb 'blue'\n";
    print FILE_GR "set ylabel \"Response Time (sec)\" textcolor rgb 'blue'\n";
    print FILE_GR "set title \"$Tag - 4Kst by @headers[$metricas[$i]]\" textcolor rgb 'blue'\n";
    print FILE_GR "set timestamp \"Generated on %d/%m/%y %H:%M by $ScriptVersion\"\n";
    print FILE_GR "set mxtics\nset mytics\nset xtics\nset ytics\nset grid xtics ytics mxtics mytics ls 1, ls 2\n";
    print FILE_GR "set key reverse Left bmargin\nset grid\nset style data linespoints\n";
    print FILE_GR "set arrow from $maxwl, graph 0 to $maxwl, graph 1 nohead ls 4\n";
    print FILE_GR "set arrow from $maxwlDown, graph 0 to $maxwlDown, graph 1 nohead ls 4\n";
    print FILE_GR "set arrow from $maxwlUp, graph 0 to $maxwlUp, graph 1 nohead ls 4\n";
    print FILE_GR "plot ";
    $hasfile="false";
    if ( $cpu_sin_mode !~ /^$/ )
      { $hasfile="true";
	print FILE_GR "\"<sed '\$d' $filemetricprefix-cpu-sin.dat\" using 1:2 title \"Response Time (s/WU): $InitialLambda extrapolation, cpu based\"";
      }
    if ( $cpu_con_mode !~ /^$/ )
      { if ( $hasfile =~ /true/ ) {print FILE_GR ","; }
	$hasfile="true";
	print FILE_GR  "\"<sed '\$d' $filemetricprefix-cpu-con.dat\" using 1:2 title \"Response Time (s/WU) (ErlangC): $InitialLambda extrapolation, cpu based\", \"$filemetricprefix-$type.singular.dat\" u 1:2:3 title \"$leyenda\" with xerrorbars ls 5, \"$filemetricprefix-$type.singular.dat\" u 1:2 w p ls 3 notitle";
      }
    if ( $io_sin_mode !~ /^$/ )
      { if ( $hasfile =~ /true/ ) {print FILE_GR ","; }
	$hasfile="true";
	print FILE_GR  "\"<sed '\$d' $filemetricprefix-io-sin.dat\" using 1:2 title \"Response Time (s/WU): $InitialLambda extrapolation, io based\"";
      }
    if ( $io_con_mode !~ /^$/ )
      { if ( $hasfile =~ /true/ ) {print FILE_GR ","; }
	$hasfile="true";
	print FILE_GR  "\"<sed '\$d' $filemetricprefix-io-con.dat\" using 1:2 title \"Response Time (s/WU) (ErlangC): $InitialLambda extrapolation, io based\", \"$filemetricprefix-$type.singular.dat\" u 1:2:3 title \"$leyenda\" with xerrorbars ls 5, \"$filemetricprefix-$type.singular.dat\" u 1:2 w p ls 3 notitle";
      }
    close (FILE_GR);
    `chmod +x $filemetricprefix.gp`;
    `\"$filemetricprefix.gp\" > \"$filemetricprefix.$gpterm\"`;
  }
} ## Final del FOR !!!
   ##
   ## Print best metric for CPU and IO, with its average precision !!!
   ##
       print "\n\nBest metric for CPU forecasts: $BestMetricForCPU (Average Precision : +/- $BestCPUPrecision %)\n";
       print "Best metric for I/O forecasts: $BestMetricForIO (Average Precision : +/- $BestIOPrecision %)\n\n";
   ##
} ## End if ( $CagingMode =~ /FALSE/)
else ## 4KST_CAGING_MODE = TRUE: caging iterations mode !!!
{
@ci = split(/\,/,$CagingInterval);
my $NUMCPU = @ci[0]; ## start with initial number of CPUs !!!
my $CagingLoopNum = 1;
my @CagingGaphFile;
my @CagingResults;
my @CagingResultsCPU;
while ( $NUMCPU <= @ci[1] )
{

for ($i=0;$i <= ($len -1);$i++)
{ 
  $data = $dirname.$MM."/CPU".$NUMCPU."_".@headers[$metricas[$i]]."_".$InitialLambda.".txt";
  open(fich," >> $data "); 
  $ficerror = $dirname.$MM."/CPU".$NUMCPU."_".@headers[$metricas[$i]]."_".$InitialLambda.".err";
  open (ficerr, " >> $ficerror ");

  ##
  ## Relacion de parametros leidos en el fichero 4Kst.ini
  ##

  print fich "**********************************************************\n";
  print fich "* Lista de parametros leidos en el fichero 4Kst.ini      *\n";
  print fich "**********************************************************\n";
  print fich "\n";

  print fich "4KST_CAGING_INTERVAL => $CagingInterval\n";
  print fich "4KST_CAGING_INCR => $CagingIncr\n";
  print fich "4KST_CAGING_WL_TARGET => $CagingWlTgt\n";
  print fich "Numero de CPUS (caging factor) => $NUMCPU\n";
  print fich "Numero de IO devices => $numio\n";
  print fich "Fichero de entrada => $filename\n";
  print fich "Posicion de Snap_id => $pos_snap\n";
  print fich "Posicion de Delta => $pos_delta\n";
  print fich "Posicion de DBCPU => $pos_dbcpu\n";
  print fich "Posicion de  IO Util => $IoUPos\n";
  print fich "Metricas de Forecast:\n";
  for ($j=0;$j <= ($len -1);$j++)         { print fich "    Posicion $metricas[$j] => @headers[$metricas[$j]]\n"; }
  print fich "Valor de Lambda inicial para Forecast = $InitialLambda\n";
  print fich "Valor de incremento de Lambda = $incr\n";
  print fich "Valor del coeficiente de ajuste del Service Time de CPU = $StAdjustCoef\n";
  print fich "Valor del coeficiente de ajuste del Service Time de I/O = $StAdjustCoefIO\n";
  print fich "CPU utilization computational mode => $CPUCompMode\n";
  print fich "\n";
  print fich "\n\n";
  ###
 
  print fich "***********************************************************************************************************************\n";
  print fich "*                               Forecast basado en la metrica @headers[$metricas[$i]]                                 *\n";
  print fich "*                                                -----                                                                *\n";
  print fich "* NOTA: El significado de cada columna es el siguiente:                                                               *\n";
  print fich "* ID_SNAP ; DELTA ; NUM_CPUS ; % USO CPU ; ID_METRICA ; ARRIVAL RATE ; SERVICE TIME CPU ; SERVICE TIME * ARRIVAL RATE CPU; SERVICE TIME IO ; SERVICE TIME * LAMBDA IO    *\n";
  print fich "***********************************************************************************************************************\n";
  print fich "\n\n";
  $sep=";";
  $numlin=0;
  $SumLambda=0;
  $SumSt=0;
  $SumStIo=0;
  $SumStLambda=0;
  $SumStIoLambda=0;
  $LambdaMax=0;
  $ValoresLambda = "";
  $LambdaStdDev = 0;
  $LambdaStdErr = 0;
  # define the basename for all outputfiles
  $filemetricprefix = $dir."/CPU".$NUMCPU."_".$fileprefix."-".@headers[$metricas[$i]]."-".$InitialLambda;

  open( FILE, "< $filename" ) or die "Can't open $filename : $!";
  while( <FILE> ) 
  {
    $line = $_;
    if ($line !~ /Snap_id/)
    {
        chomp($line);
        @arr = split(/\|/, $line);
        ##
        $snapid=$arr[$pos_snap];
        $delta=$arr[$pos_delta];
        $dbcpu=$arr[$pos_dbcpu];
        $metrica=@arr[$metricas[$i]];
        ##
        ## % de CPU utilizado por la instancia !!!
        ##
        $U = (($dbcpu / 1000000) / ($NUMCPU * $delta));
        $pctcpu = $U * 100 ;
        ##
        ## Arrival rate (lambda) !!!
        ##
        $lambda = ( $metrica / $delta );
        if ( $lambda == 0 ) { print "==>$snapid##$metrica--$delta\n"; }
        $ValoresLambda = "$ValoresLambda;$lambda";
        ##
        ## Service Time !!!
        ##
        $St = ( $U * $NUMCPU ) / $lambda ;
        ##
        ## Service Time * Lambda (utilizado para la media ponderada del Service time) !!!
        ##
        $StLambda = $St * $lambda ;
        ##
        ## I/O devices generic utilisation and other I/O specific metrics !!!
        ##
        $Uio = $arr[$IoUPos] / 100;
        $Stio = ( $Uio * $numio ) / $lambda;
        $StioLambda = $Stio * $lambda;
        ##
        ## Calculo de valores acumulados !!!
        ##
        $numlin = $numlin + 1;
        $SumSt = $SumSt + $St;
        $SumStIo = $SumStIo + $Stio;
        $SumLambda = $SumLambda + $lambda;
        $SumStLambda = $SumStLambda + $StLambda;
        $SumStIoLambda = $SumStIoLambda + $StioLambda;
        if ( $lambda > $LambdaMax )
        {
            $LambdaMax = $lambda;
        }
        ## 
        ## Presentacion de los resultados en formato CSV !!!
        ##
        print fich "$snapid$sep$delta$sep$numcpu$sep$pctcpu$sep$metrica$sep$lambda$sep$St$sep$StLambda$sep$Stio$sep$StioLambda\n";
        print ficerr "$snapid$sep$NUMCPU$sep$lambda$sep$U$sep$Uio\n"
    }
    else ## Leemos la linea de Headers del fichero, donde vienen los nombre de las metricas !!!
    {
        chomp($line);
        @header = split(/\|/, $line);
    }
  } ## Fin WHILE
  close ficerr;

  ##
  ## Calculo de valores acumulados !!!
  ##
  $StMedio = ( $SumSt / $numlin );
  $StMedioIo = ( $SumStIo / $numlin );
  $StMedioPond = ( $SumStLambda / $SumLambda );
  $StMedioPondIo = ( $SumStIoLambda / $SumLambda );
  $LambdaMedio = ( $SumLambda / $numlin );
  $ValoresLambda = substr $ValoresLambda, 1;
  $LambdaStdDev = CalcStdDev($ValoresLambda);
  $LambdaStdErr = $LambdaStdDev / sqrt ($numlin);

  ## 
  ## Calculo de la precision del Forecast: agregado por SDU el 22/02/2011
  ##
  my $SumErrCpu = 0;
  my $SumErrIo = 0;
  my $numsnap = 0;
  open (ficerr, " < $ficerror ") or die "Can't open $ficerror : $1";
  while( <ficerr> )
  {
      $line = $_;
      chomp($line);
      @arr = split(/;/, $line);
      ##
      ## Lectura del fichero
      ##
      $snapid=$arr[0];
      $numcpu=$arr[1];
      $lambda=$arr[2];
      $UCpuReal=$arr[3];
      $UIoReal=$arr[4];
      ##
      $UCpuForecast= ($lambda * $StMedioPond) / $numcpu ;
      $UIoForecast= ($lambda * $StMedioPondIo) / $numio ;
      ##
      ## Compute absolute value average error: should be substitued by signed average error +/- 1.96*Standard Error
      ##
      if ( $UCpuReal == 0 )
      {
         $UCpuReal=$UCpuForecast;
      }
      if ( $UIoReal == 0 )
      {
         $UIoReal=$UIoForecast;
      }
      ##
      $ErrorPctCpu = abs(( $UCpuForecast - $UCpuReal ) / $UCpuReal);
      if ( $UIoReal != 0 )
      {
           $ErrorPctIo = abs(( $UIoForecast - $UIoReal ) / $UIoReal);
      }
      ##
      $SumErrCpu = $SumErrCpu + $ErrorPctCpu;
      $SumErrIo = $SumErrIo + $ErrorPctIo;
      $numsnap = $numsnap + 1;
  }
  close ficerr;
  ## 
  ## Calculo del error medio en valor absoluto !!!
  ##
  $ErrorPctCpu = ($SumErrCpu / $numsnap) * 100; 
  $ErrorPctIo  = ($SumErrIo / $numsnap) * 100; 
  ##
  ## 
  ## Presentacion de resultados acumulados
  ##
  print fich "\n\n";
  print fich "*****************************************************************************************************\n";
  print fich "*       Resultados estadisticos bases del Forecasting - metrica @headers[$metricas[$i]]             *\n";
  print fich "*****************************************************************************************************\n";
  print fich "\n\n";
  print fich "Service Time CPU (medio)           = $StMedio\n";
  print fich "Service Time CPU (media ponderada) = $StMedioPond\n";
  print fich "Service Time I/O (medio)           = $StMedioIo\n";
  print fich "Service Time I/O (media ponderada) = $StMedioPondIo\n";
  print fich "Arrival rate (media muestra)   = $LambdaMedio\n";
  print fich "Arrival rate (Standard Error)  = $LambdaStdErr\n";
  print fich "Arrival rate (media poblacion) = $LambdaMedio +/- $LambdaStdErr al nivel de confianza 68%\n";
  $num = 1.96 * $LambdaStdErr;
  print fich "Arrival rate (media poblacion) = $LambdaMedio +/- $num al nivel de confianza 90%\n";
  print fich "Arrival rate (max)             = $LambdaMax\n";
  print fich "Arrival Rate Medio StdDev      = $LambdaStdDev\n\n";
  print fich "Arrival Rate = $LambdaMedio +/- $LambdaStdDev al nivel de confianza 68%\n";
  $num = 1.96 * $LambdaStdDev;
  print fich "Arrival Rate = $LambdaMedio +/- $num al nivel de confianza 90%\n";
  print fich "CPU Forecast Average Precision = +/- $ErrorPctCpu %\n";
  print fich "IO Forecast Average Precision = +/- $ErrorPctIo %\n";
  close FILE;

  $Stf=$StMedioPond*$StAdjustCoef; ## Final Service Time for CPU forecasts
  $StfIo=$StMedioPondIo*$StAdjustCoefIO; ## Final Service Time for I/O forecasts
  if ( $InitialLambda =~ /MED/ )
  { $LambdaIni = $LambdaMedio + 1.96 * $LambdaStdErr; }## Modif by SDU on 26/05/2010: starting the forecast with the population
                                                       ## average value at 95% confidence level !!!
  elsif ($InitialLambda =~ /MAX/ )
  { $LambdaIni = $LambdaMax;   } ## Empezamos el Forecast con el valor maximo de Lambda !!!
  elsif ( $InitialLambda =~ /STDEV/ )
  { $LambdaIni = $LambdaMedio + 1.96 * $LambdaStdDev; } ## Empezamos el Forecast con el valor medio de Lambda
                                                        ## al cual sumamos 1.96*StdDev. Porque estadisticamente,
                                                        ## 90 % de los valores de Lambda estan entre $LambdaMedio +/- 1.96*StdDev
                                                        ## lo que significa que 95% de los valores de Lambda son menores o iguales
                                                        ## a $LambdaMedio + 1.96*StdDev !!!
  else
  { ## Si caemos aqui, es que hay un error en el fichero INI para el parametro 4KST_INITIAL_LAMBDA !!!
    print "Error en el valor del parametro 4KST_INITIAL_LAMBDA\n";
    exit -1;
  }
  ##
  ## Tuning factor: decrease Lambda initial value
  ##
  $LambdaIni = $LambdaIni * $TuningFactor;
  ##
  ##
  ## Aqui empiezan los Forecast !!!
  ##
  print "@headers[$metricas[$i]] - Forecasting with Initial Lambda ($InitialLambda mode) = $LambdaIni\n";
  print "@headers[$metricas[$i]] - Forecasting with CPU Service Time Adjustment Coef. = $StAdjustCoef\n";
  print "@headers[$metricas[$i]] - Forecasting with I/O Service Time Adjustment Coef. = $StAdjustCoefIO\n";
  print "@headers[$metricas[$i]] - Forecasting with Tuning Factor Adjustment Coef. = $TuningFactor\n";
  print fich "@headers[$metricas[$i]] - Forecasting with Initial Lambda ($InitialLambda mode) = $LambdaIni\n";
  print fich "@headers[$metricas[$i]] - Forecasting with CPU Service Time Adjustment Coef. = $StAdjustCoef\n";
  print fich "@headers[$metricas[$i]] - Forecasting with I/O Service Time Adjustment Coef. = $StAdjustCoefIO\n";
  print fich "@headers[$metricas[$i]] - Forecasting with Tuning Factor Adjustment Coef. = $TuningFactor\n";
  ##
  if ( $cpu_sin_mode !~ /^$/ )
  { ##
    ## Ahora empezamos el Forecasting con el modelo matematico sencillo (sin ErlangC) !!!
    ##
    ## La idea es hacer crecer el valor de Lambda (Lambdaf) poco a poco, manteniendo constante St (Stf), y calcular
    ## la utilizacion (Uf), el tiempo de respuesta (Rtf), Queue Time (Qtf), y Queue Length (Qf) !!!
    ##
    print fich "\n\n";
    print fich "**************************************************************************************************************************\n";
    print fich "*                                Forecasting Modelo Matematico Sencillo (sin ErlangC)                                    *\n";
    print fich "*                                                -----                                                                   *\n";
    print fich "* NOTA: El significado de cada columna es el siguiente:                                                                  *\n";
    print fich "* INCREMENTO DEL WORKLOAD (%) ; ARRIVAL RATE ; USO CPU (%) ; RESPONSE TIME ; QUEUE TIME ; QUEUE LENGTH ; QUEUE TIME (%)  *\n";
    print fich "**************************************************************************************************************************\n";
    print fich "\n\n";
    compute("cpu-sin",$Stf,$NUMCPU,$LambdaIni,$ErrorPctCpu);
  }
  if ( $cpu_con_mode !~ /^$/ )
  { ##
    ## Ahora empezamos el Forecasting con el modelo matematico esencial (con ErlangC) !!!
    ##
    print fich "\n\n";
    print fich "**************************************************************************************************************************\n";
    print fich "*                                Forecasting Modelo Matematico Esencial (con ErlangC)                                    *\n";
    print fich "*                                                -----                                                                   *\n";
    print fich "* NOTA: El significado de cada columna es el siguiente:                                                                  *\n";
    print fich "* INCREMENTO DEL WORKLOAD (%) ; ARRIVAL RATE ; USO CPU (%) ; RESPONSE TIME ; QUEUE TIME ; QUEUE LENGTH ; QUEUE TIME (%)  *\n";
    print fich "**************************************************************************************************************************\n";
    print fich "\n\n";
    compute("cpu-con",$Stf,$NUMCPU,$LambdaIni,$ErrorPctCpu);
  }
  close fich;
  ###
  ### Stores the caging result in an array !!!
  ###
  if ($maxwl >= $CagingWlTgt)
  {
     if (@CagingResults[$i] <= $CagingWlTgt)
     {
         @CagingResults[$i] = $maxwl;
         @CagingResultsCPU[$i] = $NUMCPU;
     }
  }
  ###
  ###
  ### if graph mode was selected, generate gnuplot
  ### A single caging graph for all the caging iterations !!!
  ###
  @CagingGraphFile[$i] = $dir."/CAGINGGRAPH_".$fileprefix."-".@headers[$metricas[$i]]."-".$InitialLambda;
  if ($graph_mode =~ /^gp$/ && ($cpu_con_mode !~/^$/ || $cpu_sin_mode !~/^$/))
  { 
    open (FILE_GR,">>@CagingGraphFile[$i].gp") or die "Can't open @CagingGraphFile[$i].gp : $1";
    if ( $CagingLoopNum == 1 )
    {
    print FILE_GR "#!/usr/bin/gnuplot\nreset\nset terminal $gpterm $gpsize size $gppixel\n";
    print FILE_GR "set style line 1 lt 1 lc rgb 'black' lw 1\n";
    print FILE_GR "set style line 2 lt 2 lc rgb 'gray' lw 0.25\n";
    print FILE_GR "set style line 3 pt 6 ps 2 lc rgb 'green' lw 1.5\n";
    print FILE_GR "set style line 4 lt 0 lc rgb 'black' lw 2\n";
    print FILE_GR "set xlabel \"Increased Workload (%)\" textcolor rgb 'blue'\n";
    print FILE_GR "set ylabel \"Response Time (sec)\" textcolor rgb 'blue'\n";
    print FILE_GR "set title \"$Tag - 4Kst by @headers[$metricas[$i]] - caging iterations\" textcolor rgb 'blue'\n";
    print FILE_GR "set timestamp \"Generated on %d/%m/%y %H:%M by $ScriptVersion with caging option\"\n";
    print FILE_GR "set mxtics\nset mytics\nset xtics\nset ytics\nset grid xtics ytics mxtics mytics ls 1, ls 2\n";
    print FILE_GR "set key reverse Left bmargin\nset grid\nset style data linespoints\n";
    print FILE_GR "set arrow from $maxwl, graph 0 to $maxwl, graph 1 nohead ls 4\n";
    print FILE_GR "plot ";
    }
    $hasfile="false";
    if ( $cpu_sin_mode !~ /^$/ )
      { $hasfile="true";
        if ( $CagingLoopNum == 1 )
        {
	    print FILE_GR "\"<sed '\$d' $filemetricprefix-cpu-sin.dat\" using 1:2 title \"Response Time (s/WU): $InitialLambda extrapolation, caging $NUMCPU cpus\"";
        }
        else
        {
            print FILE_GR ",\"<sed '\$d' $filemetricprefix-cpu-sin.dat\" using 1:2 title \"Response Time (s/WU): $InitialLambda extrapolation, caging $NUMCPU cpus\"";
        }
      }
    if ( $cpu_con_mode !~ /^$/ )
      { if ( $hasfile =~ /true/ ) {print FILE_GR ","; }
	$hasfile="true";
        if ( $CagingLoopNum == 1 )
        {
	    print FILE_GR  "\"<sed '\$d' $filemetricprefix-cpu-con.dat\" using 1:2 title \"Response Time (s/WU) (ErlangC): $InitialLambda extrapolation,caging $NUMCPU cpus\"";
        }
        else
        {
            print FILE_GR  ",\"<sed '\$d' $filemetricprefix-cpu-con.dat\" using 1:2 title \"Response Time (s/WU) (ErlangC): $InitialLambda extrapolation,caging $NUMCPU cpus\"";
        }
      }
    close (FILE_GR);
  }
} ## Final del FOR !!!
$NUMCPU = $NUMCPU + $CagingIncr; ## Increments NUMCPU by CagingIncr !!!
$CagingLoopNum = $CagingLoopNum + 1;
} ## End of WHILE $NUMCPUS <= $ci[2] !!!

## Graphs generation, executing the generated Graph Files !!!

print "\n\nGraph files generation:\n";
for ($i=0;$i <= ($len -1);$i++)
{
    print "Now plotting @CagingGraphFile[$i].$gpterm file ... \n";
    print "    Caging optimal CPUs: @CagingResultsCPU[$i] (Actual CPUs $numcpu)\n";
    print "    Caging workload increment: @CagingResults[$i] (Target $CagingWlTgt)\n\n";
    `chmod +x @CagingGraphFile[$i].gp`;
    `\"@CagingGraphFile[$i].gp\" > \"@CagingGraphFile[$i].$gpterm\"`;
}
print "\n\nCaging done.\n\n";

} ## End 4KST_CAGING_MODE = TRUE !!!
