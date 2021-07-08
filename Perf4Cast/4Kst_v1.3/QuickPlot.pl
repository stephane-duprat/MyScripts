#!/usr/bin/perl
# #####################################################################
# $Header: QuickPlot.pl 17-May-2010 sduprat_es Exp $
#
# QuickPlot.pl
#
# Copyright (c) 2010, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     QuickPlot.pl
#
#    DESCRIPTION
#     This perl script allows to quick plot columns of the consolidated forecast input flat file
#     This script produces a GIF file. GnuPlot version 4.2 or superior is required.
#
#
#    NOTES
#
#    VERSION		MODIFIED        (MM/DD/YY)
#      1.0     		sduprat_es      17/05/10   - Creation and mastermind
#      1.1              sduprat_es	26/10/10   - Include GetParam("4KST_TAG") in Graph title
#      1.2              sduprat_es	19/01/11   - Modified date format on X axis
#      1.2.10           acarrasc_es     02/01/11   - 4KST_GNUPLOT_SIZE to gnuplot params
#      1.2.15           sduprat_es      03/03/11   - Distribute the output files in "Quickplot/<Y-metric>" sub-directories
#      1.2.16           sduprat_es      10/10/11   - (Machine,Instance) TAG ("4KST_TAG") in graph legend
#      1.2.17           sduprat_es      13/03/13   - Add size in pixels parameter
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
my $Project;

if ($numArgs > 4 )	{ print "ERROR: to many arguments\nUSAGE: QuickPlot.pl [project] [YYYYMMDD] [X-metric] [Y-metric]\n"; exit -1; }
if ($numArgs == 4 )	{ $fileprefix = "MM_4Kst-$ARGV[0]"; $Project = "$ARGV[0]" ; $fecha = "$ARGV[1]"; $PosX = $ARGV[2]; $PosY = $ARGV[3] ; }
else			{ print "ERROR: to few arguments\nUSAGE: QuickPlot.pl [project] [YYYYMMDD] [X-metric] [Y-metric]\n"; exit -1; }
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
##
## Creacion de carpetas identificadoras del modelo ejecutado
##
$MM = '/QuickPlot';
$dir=$dirname.$MM;
if (-e $dir)
{
      if (-e $dir.@headers[$PosY]) { echo; } else { mkdir $dir."/".@headers[$PosY] }
}
else
{
      mkdir $dir;
      mkdir $dir."/".@headers[$PosY];
}
$dir=$dir."/".@headers[$PosY];

  print "Now plotting ...\n";
  print "   X axis (Position $PosX) => @headers[$PosX]\n";
  print "   Y axis (Position $PosY) => @headers[$PosY]\n\n";
  $filemetricprefix = $dir."/"."QP.".$fecha."_".@headers[$PosX]."_".@headers[$PosY];
  $data = $filemetricprefix.".dat";
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
        $X=substr($arr[$PosX],0,12);
        $Y=$arr[$PosY];
        ##
        if ( $arr[$PosX] =~ /^$fecha/ )
        {
            print fich "$X $Y\n";
        }
    }
  } ## Fin WHILE

  close FILE;

  close fich;

  print "Data generated in file $data\n";
  print "Graph generated in file $filemetricprefix.gif\n\n";

  ###
  open (FILE_GR,">$filemetricprefix.gp") or die "Can't open $filemetricprefix.gp : $1";
  print FILE_GR "#!/usr/bin/gnuplot\nreset\nset terminal $gpterm $gpsize size $gppixel\n";
  print FILE_GR "set style line 1 lt 1 lc rgb 'black' lw 1\n";
  print FILE_GR "set style line 2 lt 2 lc rgb 'gray' lw 0.25\n";
  print FILE_GR "set xlabel \"@headers[$PosX]\" textcolor rgb 'blue'\n";
  print FILE_GR "set ylabel \"@headers[$PosY]\" textcolor rgb 'blue'\n";
  print FILE_GR "set title \"$grtitle - @headers[$PosY] by @headers[$PosX] on date $fecha\" textcolor rgb 'blue'\n";
  print FILE_GR "set xdata time\nset timefmt \"%Y%m%d%H%M\"\nset format x \"%H:%M\"\n";
  print FILE_GR "set mxtics\nset mytics\nset xtics\nset ytics\nset grid xtics ytics mxtics mytics ls 1, ls 2\n";
  print FILE_GR "set key reverse Left bmargin\nset grid\nset style data linespoints\n";
  print FILE_GR "plot \"$data\" using 1:2 title \"$grtitle - @headers[$PosY] by @headers[$PosX]\"";
  close (FILE_GR);
  `chmod +x $filemetricprefix.gp`;
  `\"$filemetricprefix.gp\" > \"$filemetricprefix.$gpterm\"`;
