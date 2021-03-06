#!/usr/bin/perl
# #####################################################################
# $Header: IntegrityCheck.pl 05-Mar-2013 sduprat_es Exp $
#
# IntegrityCheck.pl
#
# Copyright (c) 2013, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     IntegrityCheck.pl
#
#    DESCRIPTION
#
#       Integrity check of the 3 files generated by Gather_driver script: wl_cpu.dat, wl_io.dat, wl_app.dat
#       This script should be launched before starting the consolidation process
#
#    NOTES
#
#    VERSION		MODIFIED        (MM/DD/YY)
#    1.3.0   		sduprat_es      05/03/13   - Creation and mastermind
# #####################################################################
use Switch;
use POSIX;

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
my $SnapID;
my $SnapIDtmp;
my $num;
my $FicIO;
my $FicCPU;
my $FicAPP;
my $FlagIO;
my $FlagAPP;
my $FicLOG;
$|=1; ## Value distinct from zero for that variable enables print auto-flush !!!

if ($numArgs > 1 )	{ print "ERROR: to many arguments\nUSAGE: IntegrityCheck.pl [project]\n"; exit -1; }
if ($numArgs == 1 )	{ $fileprefix = "MM_4Kst-$ARGV[0]"; }
else			{ print "ERROR: to few arguments\nUSAGE: IntegrityCheck.pl [project]\n"; exit -1; }
$ficini	= "$fileprefix.ini" ;

## get project parameters
$dirname=GetParam("4KST_DATA_DIR");

$FicCPU = "$dirname/wl_cpu.dat";
$FicIO = "$dirname/wl_io.dat";
$FicAPP = "$dirname/wl_app.dat";
$FicLOG = "$dirname/IntegrityCheck.log";

##
## Open the 3 files: all of them MUST be in the working directory !!!
##
open( FICCPU, "< $FicCPU" ) or die "Can't open  $FicCPU : $!";
my @num = <FICCPU>;
close FICCPU;
my $numsnap = @num; ## Gets the number of lines in the FICCPU file !!!
open( FICIO, "< $FicIO" ) or die "Can't open  $FicIO : $!";
open( FICAPP, "< $FicAPP" ) or die "Can't open  $FicAPP : $!";
open( FICLOG, "> $FicLOG" ) or die "Can't open  $FicLOG : $!";

close FICIO;
close FICAPP;

print "Working directory is $dirname \n";
print FICLOG "Working directory is $dirname \n";
print "Checking fileset file master file: $FicCPU ... \n";
print FICLOG "Checking fileset master file: $FicCPU ... \n";
print "Checking fileset file 2: $FicAPP ... \n";
print FICLOG "Checking fileset file 2: $FicAPP ... \n";
print "Checking fileset file 3: $FicIO ... \n";
print FICLOG "Checking fileset file 3: $FicIO ... \n";

## FICCPU is used as the Master file

## Check that all snaps in the master files are also in FICIO and FICAPP: 

open( FICCPU, "< $FicCPU" ) or die "Can't open  $FicCPU : $!";
$num = 0;
  while( <FICCPU> ) 
  {
    $line = $_;
    chomp($line);
    @arr = split(/,/, $line);
    $SnapID = $arr [0];
    $FlagIO = 0;
    $FlagAPP = 0;
    ##
    open( FICIO, "< $FicIO" ) or die "Can't open  $FicIO : $!";
    while ( <FICIO> )
    {
        $lineio = $_;
        chomp($lineio);
        @arrio = split(/,/, $lineio);
        $SnapIDtmp = $arrio [0];
        if ( $SnapIDtmp =~ /$SnapID/ )
        {
           ## Found the same Snap in the IO file: exiting the loop
           $FlagIO = 1;
           last;
        }
    }
    close FICIO;
    if ( $FlagIO = 0)
    {
        ## Snapshot not found in FICIO file: report a warning !!!
        print FICLOG "\nSnapshot $SnapID was not found in file $FicIO and will be ignored by the consolidation\n";
    }
    ##
    ##
    open( FICAPP, "< $FicAPP" ) or die "Can't open  $FicAPP : $!";
    while ( <FICAPP> )
    {
        $lineapp = $_;
        chomp($lineapp);
        @arrapp = split(/,/, $lineapp);
        $SnapIDtmp = $arrapp [0];
        if ( $SnapIDtmp =~ /$SnapID/ )
        {
           ## Found the same Snap in the APP file: exiting the loop
           $FlagAPP = 1;
           last;
        }
    }
    close FICAPP;
    if ( $FlagAPP = 0)
    {
        ## Snapshot not found in FICAPP file: report a warning !!!
        print FICLOG "\nSnapshot $SnapID was not found in file $FicAPP and will be ignored by the consolidation\n";
    }
    ##
    $num = $num + 1;
    print "\rFileset integrity checking: $num/$numsnap ( ".ceil(($num/$numsnap)*100)."% )";
  } ## Fin WHILE

  close FICCPU;

## App file integrity check !!!

print FICLOG "\n\nApp file integrity checking (structure) ... \n";
close FICLOG;
print "\n\nApp file integrity checking (structure) ... \n";
`cat $FicAPP | awk -F"," '{ if ( NF != 3 ) { print "Fatal error: line "NR" is inconsistent ("NF" fields)" }}' | tee -a $FicLOG`;
`cat $FicAPP | grep good | tee -a $FicLOG`;


open( FICLOG, ">> $FicLOG" ) or die "Can't open  $FicLOG : $!";
print FICLOG "App file integrity checking (metrics by snapshots) ... \n ";
close FICLOG;
print "App file integrity checking (metrics by snapshots) ... \n ";
`for snap in \`cat $FicCPU | awk -F"," '{ print $1 }'\`; do     echo \$snap" "\$(grep \$snap $FicAPP | wc -l); done | awk '{ print \$2 }' | sort -u  | tee -a $FicLOG`;

##
  print "Integrity check terminated\n";
  print "Review Log file $FicLOG\n";
  `cat $FicLOG`;
