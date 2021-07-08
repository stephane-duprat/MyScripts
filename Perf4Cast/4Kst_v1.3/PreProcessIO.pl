#!/usr/bin/perl
# #####################################################################
# $Header: PreProcessIO.pl 18-May-2010 sduprat_es Exp $
#
# PreProcessIO.pl
#
# Copyright (c) 2010, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     PreProcessIO.pl
#
#    DESCRIPTION
#     This perl script allows to preprocess the I/O raw data of the wl_io.dat file.
#     The execution of this script is required before forecasting I/O.
#     It calculates the average or the maximum utilisation of the I/O devices, depending on the value of
#     the 4KST_IOPREPROCESS_MODE parameter.
#     The original wl_io.dat file is then substituted by a new summarized file: SNAP_ID,Average/Max devices utilisation
#
#    NOTES
#
#    VERSION		MODIFIED        (MM/DD/YY)
#            		sduprat_es      18/05/10   - Creation and mastermind
#    1.2.15             sduprat_es      02/03/11   - Average utilization computation: divide by the number of devices as read in the INI
#                                                    file instead of the number of snapshots lines as captured by "sar -d". To simulate
#                                                    real balancing between all devices (like ASM).
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
my $ioppmode;
my $ioUPos;
my $FicIO;
my $U;
my $SumU;
my $MaxU;
my $SnapID;
my $PrevSnapID;
my $num;
my $AvgU;

if ($numArgs > 1 )	{ print "ERROR: to many arguments\nUSAGE: PreProcessIO.pl [project]\n"; exit -1; }
if ($numArgs == 1 )	{ $fileprefix = "MM_4Kst-$ARGV[0]"; }
else			{ print "ERROR: to few arguments\nUSAGE: PreProcessIO.pl [project]\n"; exit -1; }
$ficini	= "$fileprefix.ini" ;

## get project parameters
$dirname=GetParam("4KST_DATA_DIR");
# if the filtered file is not set use the complete compostie file
$filename=GetParam("4KST_FIC_FILTER");
if ($filename =~/^$/) { $filename=GetParam("4KST_FIC_INPUT");}
$filename="$dirname/$filename";

## I/O Preprocess mode = MAX or AVG
$ioppmode       = GetParam("4KST_IOPREPROCESS_MODE");

## Device utilisation position in the original wl_io.dat file
$ioUPos       = GetParam("4KST_IO_U_POS");

## Num devices
$numIO = GetParam("4KST_NUM_IO");

$FicIO = "$dirname/wl_io.dat";
$FicIOPpr = "$FicIO.ppr";

## Rename the original wl_io.dat file !!!
`mv $FicIO $FicIOPpr`;

##
## Open the files
##
open( FICOUT, "> $FicIO" ) or die "Can't open  $FicIO : $!";
open( FILE, "< $FicIOPpr" ) or die "Can't open  $FicIOPpr : $!";

## Initialize variables !!!
$U = 0;
$SumU = 0;
$MaxU = 0;
$num = 0;
$AvgU = 0;
$SnapID = "ZZ";
$PrevSnapID = "ZZ";

  while( <FILE> ) 
  {
    $line = $_;
    chomp($line);
    @arr = split(/,/, $line);
    @arr2 = split(/ /, $arr[0]);
    $SnapID = $arr2 [0];
    if ($SnapID !~ /$PrevSnapID/)
    {
       if ( $num > 0 ) 
       {
           $AvgU = $SumU / $numIO;
           if ( $ioppmode =~ /AVG/ )
           {
               print FICOUT "$PrevSnapID,IO AVG,$AvgU\n";
           }
           else
           {
               print FICOUT "$PrevSnapID,IO MAX,$MaxU\n";
           }
           $MaxU = 0;
           $num = 0;
           $SumU = 0;
           $PrevSnapID = $SnapID;
       }
       else
       {
           $PrevSnapID = $SnapID;
       }
    }
    $U = $arr [$ioUPos];
    $SumU = $SumU + $U;
    if ( $U > $MaxU )
    {
       $MaxU = $U;
    }
    $num = $num + 1;
    ##
  } ## Fin WHILE

  close FILE;

  close FICOUT;

  print "I/O raw data pre-processed in file $FicIO\n";
