#!/usr/bin/perl
# #####################################################################
# $Header: conso.pl 04-Mar-2011 sduprat_es Exp $
#
# conso.pl
#
# Copyright (c) 2011, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     conso.pl
#
#    DESCRIPTION
#     A perl script which creates the consolidated data file. Replaces the former "conso.sh" script, for performance purposes.
#
#    NOTES
#
#    VERSION		MODIFIED        (MM/DD/YY)
#            		sduprat_es      04/03/11   - Creation and mastermind
#                       sduprat_es      23/11/11   - Compute DBCPU from Sar Colected CPU User, if 4KST_CPU_COMPUTE_MODE = SYS in the INI file !!!
#                       sduprat_es      19/12/11   - Introduce computed metrics: DBCPUPCT = (100*DBCPU)/(1000000*NUMCPUS*DELTA)
#     1.3.1             sduprat_es      22/02/12   - Extracts IOWait from wl_cpu.dat, if captured by sar     
#     1.3.2             sduprat_es      14/06/12   - Dynamic tempfile name, to allow simultaneous executions for distinct projects
#     1.3.3             sduprat_es      08/04/13   - Introduce Sampling to process Exadata OSW files (4KST_SAMPLING_FACTOR)
#     1.3.4             sduprat_es      12/06/13   - Computes AAS out of DBtime
# #####################################################################
#     Planned versions:
#
#
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
my $fileprefix;
my $dirwork;
my $filename;
my $cpucompmode;
my $numcpu;
my $tmpfile;
my $fic_cpu;
my $fic_io;
my $fic_app;
my $snapidcpu;
my $t;
my $snapidio;
my $snapidapp;
my $cpuusr;
my $cpusys;
my $cpuidl;
my $cpuiow;
my $titulo;
my $CpuTitle;
my $IoTitle;
my $AppTitle;
my $device;
my $Uio;
my $HasIo;
my $HasApp;
my $buffer;
my $metrica;
my $metric_value;
my $cnt;
my $ComputedDBCpu;
my $DBCPUAsPct;


if ($numArgs > 1 )	{ print "ERROR: to many arguments\nUSAGE: conso.pl [project]\n"; exit -1; }
if ($numArgs == 1 )	{ $fileprefix = "MM_4Kst-$ARGV[0]"; }
else			{ print "ERROR: to few arguments\nUSAGE: conso.pl [project]\n"; exit -1; }
$ficini	= "$fileprefix.ini" ;

##
## Get project parameters !!!
##

$dirwork=GetParam("4KST_DATA_DIR");

# if the filtered file is not set use the complete compostie file
$filename=GetParam("4KST_FIC_FILTER");
if ($filename =~/^$/) { $filename=GetParam("4KST_FIC_INPUT");}
$filename="$dirwork/$filename";

$cpucompmode=GetParam("4KST_CPU_COMPUTE_MODE");
$numcpu=GetParam("4KST_NUM_CPU");

## Read the sampling factor in the INI file: added by sduprat_es (08/04/2013)
##
$sampling_factor=GetParam("4KST_SAMPLING_FACTOR");
if ($sampling_factor =~/^$/) { $sampling_factor = 1; }

# create the consolidated data file
$fic_cpu="$dirwork/wl_cpu.dat";
$fic_io="$dirwork/wl_io.dat";
$fic_app="$dirwork/wl_app.dat";
$tmpfile="/tmp/$ARGV[0].tmp";  ## Changed by SDU on 14/06/2012: dynamic tempfile name, to allow simultaneous executions for distinct projects !!!

##
## Open the files
##
open( FICCPU, "$fic_cpu" ) or die "Can't open  $fic_cpu : $!";
my @num = <FICCPU>;
close FICCPU;
my $numsnap = @num; ## Gets the number of lines in the FICCPU file !!!

print "Consolidating with Sampling Factor = $sampling_factor\n";
open( FICCPU, "< $fic_cpu" ) or die "Can't open  $fic_cpu : $!";
open( FICTMP, "> $tmpfile" ) or die "Can't open  $tmpfile : $!";
open( FILE, "> $filename" ) or die "Can't open  $filename : $!";

$CpuTitle=0;
$IoTitle=0;
$AppTitle=0;
$cnt = 0;
$|=1; ## Value distinct from zero for that variable enables print auto-flush !!!

  while( <FICCPU> ) ## FICCPU is the master file, both FICIO and FICAPP files are accessed by nested loops !!!
  {
  if ( $cnt % $sampling_factor == 0 )
   {
    $line = $_;
    chomp($line);
    @arr = split(/,/, $line);
    $snapidcpu = @arr [0];
    @arr2 = split(/\./, $snapidcpu);
    $tim = @arr2 [1];
    $cpuusr = @arr [1];
    $cpusys = @arr [2];
    $cpuidl = @arr [3];
    $cpuiow = @arr [4]; ## Can be NULL if not present into wl_cpu.dat, because it has not been captured by sar

    if ( $CpuTitle == 0 ) 
    {
        if ( $cpucompmode =~ /SYS/ )
        {
            $titulo = "Snap_id|Tiempo|CPUUsr|CPUSys|CPUIdle|CPUIoWait|ComputedCPU";
        }
        else
        {
            $titulo = "Snap_id|Tiempo|CPUUsr|CPUSys|CPUIdle|CPUIoWait";
        }
        $CpuTitle=1;
    }
    if ( $cpucompmode =~ /SYS/ )
    {
        $ComputedDBCpu = ($tim * $numcpu * $cpuusr * 1000000)/100 ;
        $buffer = "$snapidcpu|$tim|$cpuusr|$cpusys|$cpuidl|$cpuiow|$ComputedDBCpu";
    }
    else
    {
        $buffer = "$snapidcpu|$tim|$cpuusr|$cpusys|$cpuidl|$cpuiow";
    }

    ##
    ## For each snap_id read in the FICCPU file, process the FICIO file !!!
    ##
    open( FICIO, "< $fic_io" ) or die "Can't open  $fic_io : $!";
    $HasIo = 0;
    while ( <FICIO> )
    {
       $line2 = $_;
       chomp($line2);
       @arr2 = split(/,/, $line2);
       $snapidio = @arr2 [0];
       $device   = @arr2 [1];
       $device   =~ s/ //g;
       $Uio      = @arr2 [2]; 
       if ( $snapidio =~ /$snapidcpu/ )
       {
           $HasIo = 1;
           $buffer = $buffer."|$Uio";
           if ( $IoTitle == 0 )
           {
                $titulo = $titulo."|$device"."UtilPct";
                $IoTitle=1;
           }
           last; ## Exiting the loop if $snapidcpu encountered in the IO file !!!
       }
    }
    if ( $HasIo == 0 )
    {
        $buffer = $buffer."|0"; ## If no IO stat for that snap_id, force IO utilization to zero !!!
    }
    close FICIO;
    ##
    ## End process FICIO file !!!
    ##
    ##
    ## For each snap_id read in the FICCPU file, process the FICAPP file !!!
    ##
    open( FICAPP, "< $fic_app" ) or die "Can't open  $fic_app : $!";
    $HasApp=0;
    while ( <FICAPP> )
    {
       $line3 = $_;
       chomp($line3);
       @arr3 = split(/,/, $line3);
       $snapidapp = @arr3 [0];
       ##
       ## If $snapidcpu is encountered in the APP file, then format the rest of the line with metrics values !!!
       ##
       if ( $snapidapp =~ /$snapidcpu/ ) 
       {
           $HasApp=1;
           $metrica = @arr3 [1];
           $metrica =~ s/ //g;
           $metrica =~ s/\(//g;
           $metrica =~ s/\)//g;
           $metric_value = @arr3 [2];
           $metric_value =~ s/ //g;
           $buffer=$buffer."|".$metric_value;
           if ( $AppTitle == 0 )
           {
                $titulo = $titulo."|".$metrica;
           }
           ##
           ## Compute DBCPU as a percentage of available CPU power: computed metric DBCPUAsPct
           ##
           if ( $metrica =~ /DBCPU/ )
           {
               ## DBCPUAsPct = (100*DBCPU)/(1000000*NUMCPUS*DELTA)
               ##
               $DBCPUAsPct = (100*$metric_value)/(1000000*$tim*$numcpu);
               $buffer=$buffer."|".$DBCPUAsPct;
               ##
               if ( $AppTitle == 0 )
               {
                    $titulo = $titulo."|DBCPUAsPct";
               }
           }
           ##
           ## Compute AAS as DBtime/Elapsed Time
           ##
           if ( $metrica =~ /DBtime/ )
           {
              ## AAS = DBtime/(1000000*DELTA)
              ##
              $AAS = $metric_value/(1000000*$tim);
              $buffer=$buffer."|".$AAS;
              ##
              if ( $AppTitle == 0 )
               {
                    $titulo = $titulo."|AAS";
               }

           }
       }
       ##
       if ( $HasApp == 1 )
       {
            if ( $snapidapp !~ /$snapidcpu/ )
            {
                 $AppTitle = 1;
                 last;
            }
       }
    }
    close FICAPP;
    ##
    ## End process FICAPP file !!!
    ##

    ## Print Data line to FICTMP !!!
    if ( $HasApp == 1 )
    {
        print FICTMP $buffer."\n";
        print "\rRaw files processing: $cnt/$numsnap ( ".ceil(($cnt/$numsnap)*100)."% )";
    }
   } ## End if ( $cnt % $sampling_factor == 0 )
   $cnt = $cnt + 1;
  } ## Fin WHILE

  close FICTMP;
  close FICCPU;

  ##
  ## Generate definitive consolidated file !!!
  ##
  print FILE $titulo."\n";
  close FILE;
  `cat $tmpfile >> $filename`;

  print "\nSnapshots consolidated in file $filename\n";
