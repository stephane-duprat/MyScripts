#!/usr/bin/perl
# #####################################################################
# $Header: gen_fake_appfile.pl 08-Apr-2013 sduprat_es Exp $
#
# gen_fake_appfile.pl
#
# Copyright (c) 2013, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     gen_fake_appfile.pl
#
#    DESCRIPTION
#     This perl script generates a fake wl_app.dat file, containing only the NUM_CPUS metric, from the wl_cpu.dat file
#     Useful script for the consolidation of the Exadata Storage Server OSW files
#
#    NOTES
#
#    VERSION            MODIFIED        (MM/DD/YY)
#      1.0              sduprat_es     08/04/13   - Creation and mastermind
#
# #####################################################################

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
if ($numArgs > 1 )      { print "ERROR: to many arguments\nUSAGE: gen_fake_appfile.pl [project]\n"; exit -1; }
if ($numArgs == 1 )     { $fileprefix = "MM_4Kst-$ARGV[0]"; }
else                    { print "ERROR: to few arguments\nUSAGE: gen_fake_appfile.pl [project]\n"; exit -1; }

$ficini	= "$fileprefix.ini" ;

## get parameters for ini
$folder = GetParam("4KST_DATA_DIR");
$num_cpus = GetParam("4KST_NUM_CPU");
$cpufile = $folder."/wl_cpu.dat";
$appfile = $folder."/wl_app.dat";

open(CPUFILE, "<$cpufile" ) or die "Can't open $cpufile";
open(APPFILE, ">$appfile" ) or die "Can't open $appfile";

while ($line=<CPUFILE>)
  {
	chomp ($line);
        @arr = split(/,/, $line);
        $snapidcpu = @arr [0];
        print APPFILE $snapidcpu.",NUM_CPUS,".$num_cpus."\n";
  }

##close all the files
close (CPUFILE);
close (APPFILE);

print "\nFile $appfile generated.\n";
