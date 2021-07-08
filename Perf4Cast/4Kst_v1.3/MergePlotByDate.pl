#!/usr/bin/perl
# #####################################################################
# $Header: MergePlotByDate.pl 02-Feb-2012 sduprat_es Exp $
#
# MergePlot.pl
#
# Copyright (c) 2012, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     MergePlotByDate.pl
#
#    DESCRIPTION
#     This perl script allows to quick plot columns of the consolidated forecast input flat file, merging various dates on the same single graph.
#     Caution: columns with very distinct scale won't give a useful graph, as some columns will be crunched by others. 
#     This script produces a GIF file. GnuPlot version 4.2 or superior is required.
#
#
#    NOTES
#
#       Usage: MergePlot.pl <project> date1,...,dateN X-axis Y-axis
#              Dates are passed as a comma separated list, without blanks.
#
#
#    VERSION		MODIFIED        (MM/DD/YY)
#      1.0     		sduprat_es      02/02/12   - Creation and mastermind
#      1.1              sduprat_es      13/03/13   - Add size in pixels parameter
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

###########
## MAIN ###
###########
$numArgs = $#ARGV + 1;
my $fileprefix ;
my $fecha;
my $PosX;
my $PosY;
my $X;
my $Y;
my $PlotString;
my $Project;

if ($numArgs == 4 )	{ $fileprefix = "MM_4Kst-$ARGV[0]"; $Project = "$ARGV[0]" ; $fecha = "$ARGV[1]"; $PosX = $ARGV[2]; $PosY = $ARGV[3] ; }
else			{ print "ERROR: to few arguments\nUSAGE: MergePlotByDate.pl [project] [YYYYMMDD,...,YYYYMMDD] [X-metric] [Y-metric]\n"; exit -1; }
$ficini	= "$fileprefix.ini" ;

## get project parameters
$dirname=GetParam("4KST_DATA_DIR");
# if the filtered file is not set use the complete compostie file
$filename=GetParam("4KST_FIC_FILTER");
if ($filename =~/^$/) { $filename=GetParam("4KST_FIC_INPUT");}
$filename="$dirname/$filename";
$gpterm=GetParam("4KST_GNUPLOT_TERM");
$gpsize=GetParam("4KST_GNUPLOT_SIZE");
##
$gppixel=GetParam("4KST_GNUPLOT_PIXELS");
if ($gppixel =~/^$/) { $gppixel = "800,600";}
##
$grtitle=$Project." - ".GetParam("4KST_TAG");
##
## Lectura de la linea de headers !!!
##
open( FILE, "< $filename" ) or die "Can't open  $filename : $!";
$line = <FILE>;
chomp($line);
@headers = split(/\|/, $line);
close FILE;
#
# Lectura de las fechas !!!
#
@Fechas = split(/,/, $fecha);
$numFechas = @Fechas; ## Numero de elementos en el array !!!
#
##
## Creacion de carpetas identificadoras del modelo ejecutado
##
$MM = '/MergePlotByDate';
$dir=$dirname.$MM;
if (-e $dir)
{
      echo;
}
else
{
      mkdir $dir;
}

  print "Now plotting ...\n";
  print "   Dates => $fecha\n";
  print "   X axis (Position $PosX) => @headers[$PosX]\n";
  print "   Y axis (Position $PosY) => @headers[$PosY]\n";
  $filemetricprefix = $dir."/"."QP.ByDate.".@headers[$PosY];
  $PlotString = "plot ";
  $filegpprefix = $filemetricprefix;

  for ($i=0;$i<=($numFechas - 1);$i++)
  {
      print "   Fecha$i => $Fechas[$i]\n";
      $data = $filemetricprefix."_".$Fechas[$i].".dat";
      $filegpprefix = $filegpprefix."_"."$Fechas[$i]";
      open(fich," > $data ") or die "Can't open $data : $!"; 
  
      open( FILE, "< $filename" ) or die "Can't open $filename : $!";
      while( <FILE> ) 
      {
        $line = $_;
        if ($line !~ /Snap_id/)
        {
            chomp($line);
            @arr = split(/\|/, $line);
            ##
            $X=substr($arr[$PosX],8,4);
            $Y=$arr[$PosY];
            ##
            if ( $arr[$PosX] =~ /^@Fechas[$i]/ )
            {
                print fich "$X $Y\n";
            }
        }
      } ## Fin WHILE <FILE>

      close FILE;

      close fich;
      print "Data generated in file $data\n";
      $PlotString = $PlotString."\"$data\" using 1:2 title \"$grtitle - @headers[$PosY] on @Fechas[$i]\",";
  }

  $len = length($PlotString);
  $PlotString = substr($PlotString,0,$len-1);
  ###
  open (FILE_GR,">$filegpprefix.gp") or die "Can't open $filegpprefix.gp : $1";
  print FILE_GR "#!/usr/bin/gnuplot\nreset\nset terminal $gpterm $gpsize size $gppixel\n";
  print FILE_GR "set style line 1 lt 1 lc rgb 'black' lw 1\n";
  print FILE_GR "set style line 2 lt 2 lc rgb 'gray' lw 0.25\n";
  print FILE_GR "set xlabel \"@headers[$PosX]\" textcolor rgb 'blue'\n";
  print FILE_GR "set ylabel \"@headers[$PosY]\" textcolor rgb 'blue'\n";
  print FILE_GR "set title \"$grtitle - Compared dates - @headers[$PosY] by @headers[$PosX]\" textcolor rgb 'blue'\n";
  print FILE_GR "set xdata time\nset timefmt \"%H%M\"\nset format x \"%H:%M\"\n";
  print FILE_GR "set mxtics\nset mytics\nset xtics\nset ytics\nset grid xtics ytics mxtics mytics ls 1, ls 2\n";
  print FILE_GR "set key reverse Left bmargin\nset grid\nset style data linespoints\n";
  print FILE_GR $PlotString;
  close (FILE_GR);
  `chmod +x $filegpprefix.gp`;
  `\"$filegpprefix.gp\" > \"$filegpprefix.$gpterm\"`;
