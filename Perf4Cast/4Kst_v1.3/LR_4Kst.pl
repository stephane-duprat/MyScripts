#!/usr/bin/perl
# #####################################################################
# $Header: LR_4Kst.pl 11-feb-2010 sduprat_es Exp $
#
# LR_4Kst.pl
#
# Copyright (c) 2010, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     LR_4Kst.pl
#
#    DESCRIPTION
#     This perl script is the heart of the linear regression model 4Kst system.
#
#    NOTES
#
#    VERSION      MODIFIED        (MM/DD/YY)
#                 sduprat_es      11/02/10   - Creation and mastermind
#                 sduprat_es      18/02/10   - Output format for GNUPlot managed with 4KST_GNUPLOT_TERM parameter
#                                              Adjust GNUPlot display look and feel
#                 acarrasco_es    24/02/10   - Subdir management for all output files
#    1.2.6        sduprat_es      15/03/10   - Invoke LR_4Kst_Result.pl with metric standard deviation as 7th parameter
#    1.2.9        sduprat_es      25/05/10   - Include 4KST_TAG label in the graphs title.
#                                            - Include timestamp and script version as information on the graphs.
#    1.2.10      acarrasc_es     02/01/11   - 4KST_GNUPLOT_SIZE to gnuplot params
#    1.2.12      acarrasco_es, sduprat_es      10/02/11   - Singular points automatic detection
#    1.2.15      sduprat_es      21/02/11   - 4KST_CPU_COMPUTE_MODE parameter for the computation of the CPU utilization
#
# #####################################################################
#    Planned versions:
#
#    1.3.0                                  - Add a module for non linear regression: parabolic regression (y=a*x^2+b*x+c)
#                                             to adjust the forecast precision
#
# #####################################################################
use Switch;
my $ficini ;
my $filemetricprefix;

sub CalcMax
{
## Algoritmo de calculo del valor maximo de un conjunto de datos !!!
##
## Entrada: {Xi}=(X1,X2,...,Xn)
## Salida:  MAX ({Xi})
##
my $max;
my $n;
my $i;

@values = split (/;/ , $_[0]);
$n = @values;
$max = 0;

for ($i=0;$i<=($n-1);$i++)
{
   if ($values[$i] > $max)
   {
       $max = $values[$i];
   }
}
return $max;
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

sub CalcCorrCoef
{
## Algoritmo de calculo del coeficiente de correlacion de dos conjuntos {Xi},{Yi} (coeficiente "r") !!!
## La formula utilizada es la formula de Pearson (Pearson's correlation coefficient).
## Produce un resultado entre -1 y +1: si r = +1 o r = -1, existe una relacion linear exacta entre {Xi} y {Yi}
## por lo tanto r se tiene que aproximar lo mas posible a -1 o +1 !!!

## Entradas: {Xi}=(X1,X2,...,Xn) ; {Yi}=(Y1,Y2,...,Yn)
## Salida:  r = (1/n-1) * SUM [ ((Xi-CalcAvg({Xi}))/CalcStdDev({Xi})) * ((Yi-CalcAvg({Yi}))/CalcStdDev({Yi})) ]
##
my $avgX;
my $avgY;
my $n;
my $r;
my $sum;
my $StdDevX;
my $StdDevY;
my $i;

@valuesX = split(/;/, $_[0]);
@valuesY = split(/;/, $_[1]);
$n = @valuesX; ## Numero de elementos en los arrays !!!

##
## Primero calculamos las medias aritmeticas de {Xi} y {Yi} !!!
##
$avgX = CalcAvg ($_[0]);
$avgY = CalcAvg ($_[1]);
##
## Ahora calculamos las desviaciones estandares de {Xi} y {Yi} !!!
##
$StdDevX = CalcStdDev ($_[0]);
$StdDevY = CalcStdDev ($_[1]);
##
## Seguimos con el calculo de la suma ... !!!
##
$sum = 0;
for ($i=0;$i<=($n-1);$i++)
{
    $sum = $sum + ( (($valuesX[$i]-$avgX)/$StdDevX) * (($valuesY[$i]-$avgY)/$StdDevY)  )
}
##
## Terminamos el calculo !!!
##
$r = (1/($n-1)) * $sum ;
##
## Se muestran los resultados en pantalla !!!
##
print "===> Arithmetic mean X = $avgX\n";
print "===> Arithmetic mean Y = $avgY\n";
print "===> Standard deviation X = $StdDevX\n";
print "===> Standard deviation Y = $StdDevY\n";
##
## Devolucion del resultado !!!
##
return $r;
}

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

###########
## MAIN ###
###########
my $ScriptVersion="4Kst v1.2.15";
my $valoresX;
my $valoresY;
my $AvgX;
my $MaxX;
my $i;
my $Tag;
my $Project;

$numArgs = $#ARGV + 1;
my $fileprefix ;
if ($numArgs > 1 )	{ print "ERROR: to many arguments\nUSAGE: LR_4Kst.pl [project]\n"; exit -1; }
if ($numArgs == 1 )
{
    if ( $ARGV[0] =~ /-version/ )
    {
        print "LR_4Kst.pl version $ScriptVersion\n";
        exit -2;
    }
    else
    {
        $fileprefix = "LR_4Kst-$ARGV[0]"; $Project = $ARGV[0]
    }
}
else			{ $fileprefix = "LR_4Kst"; }
$ficini	= "$fileprefix.ini" ;

#my $ficini = "4Kst.ini";
#foreach $argnum (0 .. $#ARGV) {
#   print "$ARGV[$argnum]\n";
#}

## get project parameters
$basedir=GetParam("4KST_BASE_DIR");
$dirname=GetParam("4KST_DATA_DIR");
# if the filtered file is not set use the complete compostie file
$filename=GetParam("4KST_FIC_FILTER");
if ($filename =~/^$/) { $filename=GetParam("4KST_FIC_INPUT");}
$filename="$dirname/$filename";

$numcpu=GetParam("4KST_NUM_CPU");
$numio=GetParam("4KST_NUM_IO");
$Tag=$Project." - ".GetParam("4KST_TAG");

##
## Metricas de Forecast
##
$metrics=GetParam("4KST_METRICS_FOR_LR");
@metricas = split(/\,/,$metrics); 
$len = @metricas;

##
## Posiciones de Snap_id, Delta, y DBCPU en el fichero de entrada !!!
##
$pos_snap  = GetParam("4KST_POS_SNAP");
$pos_delta = GetParam("4KST_POS_DELTA");
$pos_dbcpu = GetParam("4KST_POS_DBCPU");
$gpterm    = GetParam("4KST_GNUPLOT_TERM");
$gpsize    = GetParam("4KST_GNUPLOT_SIZE");
$cpulimit  = GetParam("4KST_CPU_LIMIT");
$numsing   = GetParam("4KST_NUM_SINGULAR");
$CPUCompMode=GetParam("4KST_CPU_COMPUTE_MODE");

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
$LR = '/LR';
$dir=$dirname.$LR;
if (-e $dir){
echo;
}else{
      mkdir $dir;
}

##
## Relacion de parametros leidos en el fichero 4Kst.ini
##

print "**********************************************************\n";
print "* Lista de parametros leidos en el fichero 4Kst.ini      *\n";
print "**********************************************************\n";
print "\n";

print "Numero de CPUS => $numcpu\n";
print "Fichero de entrada => $filename\n";
print "Posicion de Snap_id => $pos_snap\n";
print "Posicion de Delta => $pos_delta\n";
print "Posicion de DBCPU => $pos_dbcpu\n";
print "CPU utilization computational mode => $CPUCompMode\n";
print "Metricas de Forecast:\n";
for ($i=0;$i <= ($len -1);$i++)		{ print "    Posicion $metricas[$i] => $headers[$metricas[$i]]\n"; }
print "\n";
###

for ($i=0;$i <= ($len -1);$i++)
{ print "*************************************************************************\n";
  print "*  Forecast basado en la metrica @headers[$metricas[$i]]                *\n";
  print "*************************************************************************\n";
  $sep=";";
  $numlin=0;
  $SumLambda=0;
  $SumSt=0;
  $SumStLambda=0;
  $LambdaMax=0;
  $CorrCoef = 0;
  $StdevX = 0;
  $valoresX = "";
  $valoresY = "";
  # define the basename for all outputfiles
  $filemetricprefix = "$dir/$fileprefix-@headers[$metricas[$i]]";
  ##
  ## Opens output source file for graphing
  ##
  open ( LR_DAT_FILE, "> $filemetricprefix.dat") or die "Can't open $filename : $!";
  ##
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
        ## Presentacion de los resultados en formato CSV !!!
        ##
        print "$snapid$sep$delta$sep$numcpu$sep$pctcpu$sep$metrica\n";
        ##
        ## Write to output file !!!
        ##
        $substrsnapid=substr($snapid,0,12);
        print LR_DAT_FILE "$metrica $pctcpu $substrsnapid\n";
        ##
        ## Carga de los arrays $valoresX y $valoresY para el calculo del coeficiente de correlacion (r) !!!
        ##
        $valoresX = "$valoresX;$metrica";
        $valoresY = "$valoresY;$pctcpu";
    }
    else ## Leemos la linea de Headers del fichero, donde vienen los nombre de las metricas !!!
    {
        chomp($line);
        @header = split(/\|/, $line);
    }
  } ## Fin WHILE
  close (LR_DAT_FILE);
  close (FILE);
  ##
  ## Calculo del coeficiente de correlacion !!!
  ##
  $valoresX = substr $valoresX, 1;
  $valoresY = substr $valoresY, 1;
  $StdevX = CalcStdDev ($valoresX);
  $CorrCoef = CalcCorrCoef ($valoresX, $valoresY);
  print "Pearson's correlation coeficient between DBCPU(%) and $headers[$metricas[$i]] : $CorrCoef\n";
  ##
  ## Calculo del valor medio y maximo de {Xi} !!!
  ##
  $AvgX = CalcAvg ($valoresX);
  $MaxX = CalcMax ($valoresX);


  ## Primero generamos la primera grafica, para generar el fichero .stats

  open ( LR_GP_FILE, "> $filemetricprefix.gp") or die "Can't open $filemetricprefix.gp : $!";
  print LR_GP_FILE "#!/usr/bin/gnuplot\n";
  print LR_GP_FILE "reset\n";
  print LR_GP_FILE "set terminal $gpterm $gpsize\n";
  print LR_GP_FILE "set style line 1 lt 1 lc rgb 'black' lw 1\n";
  print LR_GP_FILE "set style line 2 lt 2 lc rgb 'gray' lw 0.25\n";
  print LR_GP_FILE "set style line 3 pt 6 ps var lc rgb 'blue' lw 0.50\n";
  print LR_GP_FILE "set ylabel \"DB CPU (%)\" textcolor rgb 'blue'\n";
  print LR_GP_FILE "set xlabel \"@headers[$metricas[$i]]\" textcolor rgb 'blue'\n";
  print LR_GP_FILE "set title \"$Tag - 4Kst - Linear Regression by $headers[$metricas[$i]]\" textcolor rgb 'blue'\n";
  print LR_GP_FILE "set timestamp \"Generated on %d/%m/%y %H:%M by $ScriptVersion\"\n";
  print LR_GP_FILE "set mxtics\nset mytics\nset xtics\nset ytics\nset grid xtics ytics mxtics mytics ls 1, ls 2\n";
  print LR_GP_FILE "set key reverse Left bmargin\nset grid\nset style data linespoints\n";
  print LR_GP_FILE "f(x) = m*x + b\n";
  print LR_GP_FILE "fit f(x) '$filemetricprefix.dat' using 1:2 via m,b\n";
  print LR_GP_FILE "plot '$filemetricprefix.dat' using 1:2 title 'Raw Data'  with points, f(x) title 'Linear Regression (Pearson coef. = $CorrCoef)'\n";
  close (LR_GP_FILE);

  `chmod +x $filemetricprefix.gp`;  
  ##
  ## Ahora ejecutamos cada programa *.gp, para generar las primeras graficas !!!
  ##
  `$filemetricprefix.gp > $filemetricprefix.$gpterm 2>$filemetricprefix.stats`;
  ##
  ##
  ## Lanzamos el analisis residual : este, entre otras cosas, genera el fichero de puntos singulares !!!
  ##
  `$basedir/LR_4Kst_Residuals.pl $filemetricprefix.dat $filemetricprefix.stats $headers[$metricas[$i]] $gpterm $numsing`;
  ##
  ## Preparacion del fichero de puntos singulares !!!
  ##
  open ( LR_SING_FILE, "< $filemetricprefix\_singular.dat") or die "Can't open $filemetricprefix\_singular.dat : $!";
  open ( LR_SING_NEW_FILE, "> $filemetricprefix\_tmp.dat") or die "Can't open $filemetricprefix\_tmp.dat : $!";
  while (<LR_SING_FILE>)
  {
     chomp($_);
     @arr=split(/ /,$_);
     print LR_SING_NEW_FILE "@arr[4] @arr[5] 3 @arr[6]\n";
  }
  close (LR_SING_FILE);
  close (LR_SING_NEW_FILE);
  `mv $filemetricprefix\_tmp.dat $filemetricprefix\_singular.dat`;
  ##
  ##
  ## Opens GnuPlot file !!!
  ##
  open ( LR_GP_FILE, "> $filemetricprefix.gp") or die "Can't open $filemetricprefix.gp : $!";
  print LR_GP_FILE "#!/usr/bin/gnuplot\n";
  print LR_GP_FILE "reset\n";
  print LR_GP_FILE "set terminal $gpterm $gpsize\n";
  print LR_GP_FILE "set style line 1 lt 1 lc rgb 'black' lw 1\n";
  print LR_GP_FILE "set style line 2 lt 2 lc rgb 'gray' lw 0.25\n";
  print LR_GP_FILE "set style line 3 pt 6 ps var lc rgb 'blue' lw 0.50\n";
  print LR_GP_FILE "set ylabel \"DB CPU (%)\" textcolor rgb 'blue'\n";
  print LR_GP_FILE "set xlabel \"@headers[$metricas[$i]]\" textcolor rgb 'blue'\n";
  print LR_GP_FILE "set title \"$Tag - 4Kst - Linear Regression by $headers[$metricas[$i]]\" textcolor rgb 'blue'\n";
  print LR_GP_FILE "set timestamp \"Generated on %d/%m/%y %H:%M by $ScriptVersion\"\n";
  print LR_GP_FILE "set mxtics\nset mytics\nset xtics\nset ytics\nset grid xtics ytics mxtics mytics ls 1, ls 2\n";
  print LR_GP_FILE "set key reverse Left bmargin\nset grid\nset style data linespoints\n";
  print LR_GP_FILE "f(x) = m*x + b\n";
  print LR_GP_FILE "fit f(x) '$filemetricprefix.dat' using 1:2 via m,b\n";
  print LR_GP_FILE "plot '$filemetricprefix.dat' using 1:2 title 'Raw Data'  with points, f(x) title 'Linear Regression (Pearson coef. = $CorrCoef)', '$filemetricprefix\_singular.dat' u 1:2:3 notitle w p ls 3, '$filemetricprefix\_singular.dat' u (\$1):(1.1\*\$2):4 notitle w labels\n";
  close (LR_GP_FILE);
  `chmod +x $filemetricprefix.gp`;  
  `$filemetricprefix.gp > $filemetricprefix.$gpterm 2>$filemetricprefix.stats`;
  ##
  ## Y lanzamos el calculo de extrapolacion con los valores de r,m,b calculados !!!
  ##
  print "AvgX = $AvgX\n";
  print "MaxX = $MaxX\n";
  `$basedir/LR_4Kst_Result.pl $filemetricprefix.stats $CorrCoef $headers[$metricas[$i]] $cpulimit $AvgX $MaxX $StdevX`;
} ## Final del FOR !!!
