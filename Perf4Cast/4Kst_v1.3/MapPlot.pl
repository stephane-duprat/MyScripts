#!/usr/bin/perl
# #####################################################################
# $Header: MapPlot.pl 20-Jan-2012 sduprat_es Exp $
#
# MapPlot.pl
#
# Copyright (c) 2012, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     MapPlot.pl
#
#    DESCRIPTION
#     This perl script allows to quick plot columns of the consolidated forecast input flat file, to generate both
#     the activity surface and the activity map of the database between two dates.
#     This script produces GIF files. GnuPlot version 4.2 or superior is required.
#
#
#    NOTES
#
#    VERSION		MODIFIED        (MM/DD/YY)
#      1.0     		sduprat_es      20/01/12   - Creation and mastermind
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
my $PosZ;
my $X;
my $PrevX;
my $Y;
my $Z;
my $Project;

if ($numArgs > 4 )	{ print "ERROR: to many arguments\nUSAGE: MapPlot.pl [project] [YYYYMMDD] [YYYYMMDD] [Z-metric]\n"; exit -1; }
if ($numArgs == 4 )	{ $fileprefix = "MM_4Kst-$ARGV[0]"; $Project = "$ARGV[0]" ; $fecha1 = "$ARGV[1]"; $fecha2 = $ARGV[2]; $PosZ = $ARGV[3] ; }
else			{ print "ERROR: to few arguments\nUSAGE: MapPlot.pl [project] [YYYYMMDD] [YYYYMMDD] [Z-metric]\n"; exit -1; }
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
$MM = '/MapPlot';
$dir=$dirname.$MM;
if (-e $dir)
{
      if (-e $dir.@headers[$PosZ]) { echo; } else { mkdir $dir."/".@headers[$PosZ] }
}
else
{
      mkdir $dir;
      mkdir $dir."/".@headers[$PosZ];
}
$dir=$dir."/".@headers[$PosZ];

  $PosX = 0;
  $PosY = 0;
  print "Now plotting ...\n";
  print "   X axis (Position $PosX) => @headers[$PosX] (YYYYMMDD)\n";
  print "   Y axis (Position $PosY) => @headers[$PosY] (HH24:MI)\n";
  print "   Z axis (Position $PosZ) => @headers[$PosZ]\n\n";
  $filemetricprefix = $dir."/"."MP.".$fecha1."_".$fecha2."_".@headers[$PosZ];
  $data = $filemetricprefix.".dat";
  open(fich," > $data ") or die "Can't open $data : $!"; 
  
  open( FILE, "< $filename" ) or die "Can't open $filename : $!";
  $PrevX = $fecha1;
  while( <FILE> ) 
  {
    $line = $_;
    if ($line !~ /Snap_id/)
    {
        chomp($line);
        @arr = split(/\|/, $line);
        ##
        $X=substr($arr[$PosX],0,8);
        $Y=substr($arr[$PosY],8,4);
        $Z=$arr[$PosZ];
        ##
        ##
        if ( ($X >= $fecha1) && ($X <= $fecha2) )
        {
            if ( $X !~ /$PrevX/ )
            {
                print fich "\n"; ## Blank lines upon $X ruptures, preparing pm3d plotting !!!
            }
            print fich "$X $Y $Z\n";
            $PrevX = $X;
        }
    }
  } ## Fin WHILE

  close FILE;

  close fich;

  print "Data generated in file $data\n";
  print "Map graph generated in file $filemetricprefix.MAP.gif\n";
  print "3D surface graph generated in file $filemetricprefix.3D.gif\n\n";
  ###
  open (FILE_GR,">$filemetricprefix.3D.gp") or die "Can't open $filemetricprefix.3D.gp : $1";
  print FILE_GR "#!/usr/local/bin/gnuplot\nreset\nset terminal $gpterm $gpsize size $gppixel\n";
  print FILE_GR "set autoscale\n";
  print FILE_GR "set style line 1 lt 1 lc rgb 'black' lw 1\n";
  print FILE_GR "set style line 2 lt 2 lc rgb 'gray' lw 0.25\n";
  print FILE_GR "set xlabel \"Days\" textcolor rgb 'blue'\n";
  print FILE_GR "set ylabel \"Hours\" textcolor rgb 'blue'\n";
  print FILE_GR "set zlabel \"@headers[$PosZ]\" textcolor rgb 'red' rotate by 90\n";
  print FILE_GR "set timestamp \"Generated on %d/%m/%y %H:%M by 4Kst v1.3.0 (MapPlot module)\"\n";
  print FILE_GR "set title \"$grtitle - @headers[$PosZ] activity surface between $fecha1 and $fecha2\" textcolor rgb 'blue'\n";
  print FILE_GR "set xdata time\nset timefmt \"%Y%m%d\"\nset format x \"%d/%m\"\n";
  print FILE_GR "set grid xtics ytics mxtics mytics ztics mztics ls 1, ls 2\n";
  print FILE_GR "set isosample 100,100\n";
  print FILE_GR "set pm3d\n";
  print FILE_GR "set yrange [0000:2400]\n";
  print FILE_GR "set view 45,30\n";
  print FILE_GR "set palette defined (-3 \"black\", -2 \"gray\" , 0 \"white\", 1 \"yellow\", 2 \"red\", 3 \"blue\")\n";
  print FILE_GR "splot \"$data\" using 1:2:3 with pm3d notitle";
  close (FILE_GR);
  `chmod +x $filemetricprefix.3D.gp`;
  `\"$filemetricprefix.3D.gp\" > \"$filemetricprefix.3D.$gpterm\"`;

  open (FILE_GR,">$filemetricprefix.MAP.gp") or die "Can't open $filemetricprefix.MAP.gp : $1";
  print FILE_GR "#!/usr/local/bin/gnuplot\nreset\nset terminal $gpterm $gpsize size $gppixel\n";
  print FILE_GR "set autoscale\n";
  print FILE_GR "set style line 1 lt 1 lc rgb 'black' lw 1\n";
  print FILE_GR "set style line 2 lt 2 lc rgb 'gray' lw 0.25\n";
  print FILE_GR "set xlabel \"Days\" textcolor rgb 'blue'\n";
  print FILE_GR "set ylabel \"Hours\" textcolor rgb 'blue'\n";
  print FILE_GR "set zlabel \"@headers[$PosZ]\" textcolor rgb 'red' rotate by 90\n";
  print FILE_GR "set timestamp \"Generated on %d/%m/%y %H:%M by 4Kst v1.3.0 (MapPlot module)\"\n";
  print FILE_GR "set title \"$grtitle - @headers[$PosZ] activity map between $fecha1 and $fecha2\" textcolor rgb 'blue'\n";
  print FILE_GR "set xdata time\nset timefmt \"%Y%m%d\"\nset format x \"%d/%m\"\n";
  print FILE_GR "set grid xtics ytics mxtics mytics ztics mztics ls 1, ls 2\n";
  print FILE_GR "set isosample 100,100\n";
  print FILE_GR "set pm3d map\n";
  print FILE_GR "set yrange [0000:2400]\n";
  print FILE_GR "set palette defined (-3 \"black\", -2 \"gray\" , 0 \"white\", 1 \"yellow\", 2 \"red\", 3 \"blue\")\n";
  print FILE_GR "splot \"$data\" using 1:2:3 with pm3d notitle";
  close (FILE_GR);
  `chmod +x $filemetricprefix.MAP.gp`;
  `\"$filemetricprefix.MAP.gp\" > \"$filemetricprefix.MAP.$gpterm\"`;
