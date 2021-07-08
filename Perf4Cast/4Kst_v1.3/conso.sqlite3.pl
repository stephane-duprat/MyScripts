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
#     1.4.0             sduprat_es      30/08/13   - Use sqlite for wl_app and wl_io processing
#     1.4.1             sduprat_es      01/10/13   - Check input files consistency
#                                                  - Compute Exadata Cell eficiency ratios
#     1.4.2             sduprat_es      07/04/14   - Added Cell CPU balance percentage as an eficiency ratio
#                                                  - Complete wl_cpu raw file with 0 if generated without iow stat
#
# #####################################################################
#     Planned versions:
#
#
# #####################################################################
use Switch;
use POSIX;
use DBI;
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

$|=1; ## Value distinct from zero for that variable enables print auto-flush !!!

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
$importfile="/tmp/import.$ARGV[0].sh"; ## Temporary import file for data loading into sqlite !!!
$sqlitedbname="conso4kst"; ## sqlite database name for data loading into sqlite !!!

##
## Load wl_io, wl_cpu and wl_app files into sqlite !!!
##
##
## If wl_io.dat is empty, generate a fake line in wl_io.dat !!!
##
open ( FICIO, "< $fic_io" ) or die "Can't open  $fic_io : $!";
my @num = <FICIO>;
close FICIO;

if (@num == 0)
{
    print "IO file was found empty ... generating fake IO file\n";
    open ( FICIO, "> $fic_io" ) or die "Can't open  $fic_io : $!";
    open( FICCPU, "< $fic_cpu" ) or die "Can't open  $fic_cpu : $!";
    while( <FICCPU> )
    {
        $line = $_;
        chomp($line);
        @arr = split(/,/, $line);
        $snapidcpu = @arr [0];
        last;
    }
    print FICIO $snapidcpu.",FAKE IO,0\n";
    close FICCPU;
    print "Fake IO file generated.\n";
}
close FICIO;
##
## Complete FICCPU file with zeroes if it has been generated without the iow statistic !!!
##

system qq { cat $fic_cpu | awk -F"," '{ if (\$5 == "") {\$5=0}; print \$1","\$2","\$3","\$4","\$5 }' > $fic_cpu.tmp };
system qq { mv $fic_cpu.tmp $fic_cpu };

##
print "\nLoading raw data in SQLITE ... \n\n";

open( FICIMP, "> $importfile" ) or die "Can't open  $importfile : $!";

print FICIMP "#!/bin/ksh\n";
print FICIMP "\n";
print FICIMP "rm $sqlitedbname 2>/dev/null\n";
print FICIMP "\n";
print FICIMP "sqlite3 $sqlitedbname << EOF\n";
print FICIMP ".echo ON\n"; 
print FICIMP ".timer ON\n"; 
print FICIMP "create table wl_cpu  (snap_id text, cpuusr real, cpusys real, cpuidl real, cpuiow real default 0);\n";
print FICIMP "create table wl_io  (snap_id text, metric text, val real);\n";
print FICIMP "create table wl_apptmp (snap_id text, metric text, val real);\n";
print FICIMP ".separator \",\"\n"; 
print FICIMP ".import $fic_cpu wl_cpu\n";
print FICIMP ".import $fic_io wl_io\n";
print FICIMP ".import $fic_app wl_apptmp\n";
print FICIMP "create table dim_metrics as select distinct metric from wl_apptmp;\n";
print FICIMP "create table dim_snaps as select distinct snap_id from wl_apptmp;\n";
print FICIMP "create table wl_app as select A.snap_id,B.metric, cast(0 as real) as val from dim_snaps A, dim_metrics B;\n";
print FICIMP "create index i_wl_cpu_snapid on wl_cpu (snap_id);\n";
print FICIMP "create index i_wl_io_snapid on wl_io (snap_id);\n";
print FICIMP "create index i_wl_apptmp_snapid on wl_apptmp (snap_id, metric);\n";
print FICIMP "create index i_wl_app_snapid on wl_app (snap_id, metric);\n";
print FICIMP "update wl_app set val = coalesce((select val from wl_apptmp B where B.snap_id = wl_app.snap_id and B.metric = wl_app.metric),0);\n";
print FICIMP "EOF\n";
print FICIMP "\n";
print FICIMP "exit 0\n";
close FICIMP;

close FICIMP;

system qq { chmod +x $importfile };
system qq { $importfile };

print "Loading raw data in SQLITE ... [OK]\n\n";
##
##
## INPUT files consistency check !!!
##
print "Checking input files consistency ...\n ";

$dbh = DBI->connect( "dbi:SQLite:$sqlitedbname" ) || die "Cannot connect: $DBI::errstr";
$res = $dbh->selectall_arrayref( "select count(*) from wl_cpu where not exists (select 'X' from wl_app where snap_id = wl_cpu.snap_id)" );

foreach( @$res )
{
    $numAppErr = $_->[0];
}

print " ... Inconsistencies between wl_cpu and wl_app: $numAppErr\n";
if ( $numAppErr > 0 )
{
    print " ...... Inconsistencies will be ignored\n";
}

$res = $dbh->selectall_arrayref( "select distinct snap_id from wl_app where val < 0" );

foreach( @$res )
{
    print "Snapshot $_->[0] was found with negative values, probably due to instance bouncing. Will be ignored.\n";
}

## print "Database metrics consistency check:\n\n";
## $res = $dbh->selectall_arrayref( "select metric, count(*) from wl_app group by metric order by metric" );
## foreach( @$res )
## {
    ## print "$_->[0] => $_->[1]\n";
## }

$dbh->disconnect;

##
## Compute Exadata Cells eficiency ratios !!!
##
print "\nComputing Exadata Cells eficiency ratios ...\n";
$dbh = DBI->connect( "dbi:SQLite:$sqlitedbname" ) || die "Cannot connect: $DBI::errstr";

## Cell offloading eficiency pct !!!
##
print "... Cell offloading efficiency percentage ...";
my $smt = qq { insert into wl_app (snap_id, metric, val) select A.snap_id, 'Cell offloading eficiency pct', 
               (A.val*100)/(case when B.val = 0 then 1 else B.val end)
               from wl_app A, wl_app B
               where A.snap_id = B.snap_id
               and A.metric like 'cell physical IO bytes eligible for predicate offload%'
               and B.metric like 'physical read total bytes%' } ;
$dbh->do ($smt);
print "\t\t\t [OK]\n";

## Cell storage index eficiency pct !!!
##
print "... Cell storage index efficiency percentage ...";
my $smt = qq { insert into wl_app (snap_id, metric, val)
               select A.snap_id, 'Cell storage index eficiency pct', 
               (A.val*100)/(case when B.val = 0 then 1 else B.val end)
               from wl_app A, wl_app B
               where A.snap_id = B.snap_id
               and A.metric like 'cell physical IO bytes saved by storage index%'
               and B.metric like 'cell physical IO bytes eligible for predicate offload%' };
$dbh->do ($smt);
print "\t\t [OK]\n";

## Cell flashcache eficiency pct !!!
##
print "... Cell flashcache efficiency percentage ...";
my $smt = qq { insert into wl_app (snap_id, metric, val)
               select A.snap_id, 'Cell flashcache eficiency pct', 
               (A.val*100)/(case when B.val = 0 then 1 else B.val end)
               from wl_app A, wl_app B
               where A.snap_id = B.snap_id
               and A.metric like 'cell flash cache read hits%'
               and B.metric like 'physical read total IO requests%' };
$dbh->do ($smt);
print "\t\t\t [OK]\n";

## Smart Scan eficiency pct !!!
##
print "... Cell smartscan efficiency percentage ...";
my $smt = qq { insert into wl_app (snap_id, metric, val)
               select A.snap_id, 'Smart Scan eficiency pct', 
               (B.val/(case when A.val = 0 then 1 else A.val end))*100
               from wl_app A, wl_app B
               where A.snap_id = B.snap_id
               and A.metric like 'cell physical IO interconnect bytes returned by smart scan%'
               and B.metric like 'cell physical IO bytes eligible for predicate offload%' };
$dbh->do ($smt);
print "\t\t\t [OK]\n";

## Smart Scan normalized eficiency pct !!!
## Pct normalized to a value between (- infinite) and 1: good ratios should be as close a possible to 100% !!!
## Negative ratios should indicate cells overwhelming !!!
##
print "... Cell smartscan normalized efficiency percentage ...";
my $smt = qq { insert into wl_app (snap_id, metric, val)
               select A.snap_id, 'Smart Scan normalized eficiency pct', 
               (1-(A.val/(case when B.val = 0 then 1 else B.val end)))*100
               from wl_app A, wl_app B
               where A.snap_id = B.snap_id
               and A.metric like 'cell physical IO interconnect bytes returned by smart scan%'
               and B.metric like 'cell physical IO bytes eligible for predicate offload%' };
$dbh->do ($smt);
print "\t\t [OK]\n";

## Cell CPU balance efficiency percentage !!!
## Ratios greater than 0 indicate cells overwhelming !!!
##
print "... Cell CPU balance efficiency percentage ...";
my $smt = qq { insert into wl_app (snap_id, metric, val)
               select A.snap_id, 'Cell CPU balance eficiency pct', 
               (A.val*100)/(case when B.val = 0 then 1 else B.val end)
               from wl_app A, wl_app B
               where A.snap_id = B.snap_id
               and A.metric like 'cell physical IO bytes sent directly to DB node to balance CPU%'
               and B.metric like 'physical read total bytes%' };
$dbh->do ($smt);
print "\t\t\t [OK]\n";

print "Computing Exadata Cells eficiency ratios ... [ OK ]\n";

print "\nComputing composite metrics ...\n";

## Wait Time !!!
##
print "... Computing Wait Time ...";
my $smt = qq { insert into wl_app (snap_id, metric, val) select A.snap_id, 'Wait Time', 
               abs(A.val-B.val)
               from wl_app A, wl_app B
               where A.snap_id = B.snap_id
               and A.metric like 'DB time%'
               and B.metric like 'DB CPU%' } ;
$dbh->do ($smt);
print "\t\t\t\t\t [OK]\n";

## Wait Time Pct !!!
##
print "... Computing Wait Time as percentage ...";
my $smt = qq { insert into wl_app (snap_id, metric, val) select A.snap_id, 'Wait Time Pct', 
               (abs(A.val-B.val)/(case when A.val = 0 then 1 else A.val end))*100
               from wl_app A, wl_app B
               where A.snap_id = B.snap_id
               and A.metric like 'DB time%'
               and B.metric like 'DB CPU%' } ;
$dbh->do ($smt);
print "\t\t\t [OK]\n";

## Service Time Pct !!!
##
print "... Computing Service Time as percentage ...";
my $smt = qq { insert into wl_app (snap_id, metric, val) select A.snap_id, 'Service Time Pct', 
               (B.val/(case when A.val = 0 then 1 else A.val end))*100
               from wl_app A, wl_app B
               where A.snap_id = B.snap_id
               and A.metric like 'DB time%'
               and B.metric like 'DB CPU%' } ;
$dbh->do ($smt);
print "\t\t\t [OK]\n";

print "Computing composite metrics ... [ OK ]\n\n";

$dbh->disconnect;

##

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
    ## For each snap_id read in the FICCPU file, process the FICIO file rows, previously loaded in sqlite !!!
    ##
    $dbh = DBI->connect( "dbi:SQLite:$sqlitedbname" ) || die "Cannot connect: $DBI::errstr";
    $res = $dbh->selectall_arrayref( "SELECT * from wl_io where snap_id = ?", undef, $snapidcpu );

    $HasIo = 0;
    foreach( @$res ) 
    {
       $HasIo = 1;
       $snapidio = $_->[0];
       $device   = $_->[1];
       $device   =~ s/ //g;
       $Uio      = $_->[2];
       $buffer   = $buffer."|$Uio";
       if ( $IoTitle == 0 )
       {
            $titulo = $titulo."|$device"."UtilPct";
            $IoTitle=1;
       }
    }
    ##
    if ( $HasIo == 0 )
    {
        $buffer = $buffer."|0"; ## If no IO stat for that snap_id, force IO utilization to zero !!!
    }
    ##
    $dbh->disconnect;
    ##
    ## End process FICIO file rows !!!
    ##
    ##
    ## For each snap_id read in the FICCPU file, process the FICAPP file rows, previously loaded in sqlite!!!
    ##
    $dbh = DBI->connect( "dbi:SQLite:$sqlitedbname" ) || die "Cannot connect: $DBI::errstr";
    $res = $dbh->selectall_arrayref( "SELECT * from wl_app where snap_id = ?", undef, $snapidcpu );

    $HasApp=0;
    my $PrintLine = 1;
    foreach( @$res )
    {
       $HasApp=1;
       $snapidapp = $_->[0];
       $metrica   = $_->[1];
       $metrica =~ s/ //g;
       $metrica =~ s/\(//g;
       $metrica =~ s/\)//g;
       $metric_value = $_->[2];
       $metric_value =~ s/ //g;

       ## DBG !!!
       ## print $snapidapp.";".$metrica.";".$metric_value."\n";
       ##

       $buffer=$buffer."|".$metric_value;
       ##
       ## If the value is negative, ignore the entire snapshot line !!!
       ## Except for the "Smart Scan normalized eficiency pct" metric that can be relevantly negative !!!
       ##
       if ($metric_value < 0 && $metrica !~ /SmartScannormalizedeficiencypct/)
       {
           $PrintLine = 0
       }
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
    $AppTitle = 1;
    
    $dbh->disconnect;
    ##
    ## End process FICAPP file rows !!!
    ##

    ## Print Data line to FICTMP !!!
    if ( $HasApp == 1 )
    {
        if ( $PrintLine == 1 )
        {
            print FICTMP $buffer."\n";
        }
        else
        {
            print "     ..... Skipping line with Snap_id = $snapidcpu as it was found with negative values.\n";
        }
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
