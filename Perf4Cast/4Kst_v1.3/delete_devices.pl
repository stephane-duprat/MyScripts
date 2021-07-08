#!/usr/bin/perl
# #####################################################################
# $Header: delete_devices.pl 03-Jan-2011 acarrasc_es Exp $
#
# delete_devices.pl
#
# Copyright (c) 2010, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     delete_devices.pl
#
#    DESCRIPTION
#     This perl script allows exclude all devices not included in param 4KST_DEVICE_LIST in the .ini file
#
#    NOTES
#
#    VERSION            MODIFIED        (MM/DD/YY)
#      1.0              acarrasc_es     02/01/11   - exclude devices from a wl_io.dat
#      1.1              acarrasc_es     04/01/11   - this perl do the backup of wl_io.dat original 
#      1.2              sduprat_es      10/10/11   - Bug searching devices from the device list (comma delimited)
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
my $fileprefix ;
if (($numArgs > 1 ) || ($numArgs < 1 ))	{ print "ERROR: to many arguments\nUSAGE: delete_devices.pl [project]\n"; exit -1; }
elsif ($numArgs == 1 )	{ $fileprefix = "MM_4Kst-$ARGV[0]"; $Project = $ARGV[0] }
$ficini	= "$fileprefix.ini" ;

## get parameters for ini
$folder = GetParam("4KST_DATA_DIR");
$devices = GetParam("4KST_DEVICE_LIST");
$devices_file = GetParam("4KST_DEVICE_FILENAME");chomp($devices_file);
@device_list=split(",",$devices);
$filter_device_file="wl_io_filter.dat";

$num_files=$ARGV[1];

## go to 4KST_DATA_DIR
chomp($folder);
chdir("$folder") or die "Unable to change to the directory $folder!\n";

## clean previous split files
system(`rm $folder/$filter_device_file 2>/dev/null`);

## open consolidation file for read
open(READFILE, "<$devices_file" ) or die "Can't open $devices_file";

## backup of wl_io.dat original
system(`cp wl_io.dat wl_io.dat.full`);
system(`rm wl_io.dat`);

## create the output file
open(DEVFILE, ">$filter_device_file" ) or die "Can't open $filter_device_file";


## this loop is used to filter the devices that we want
while ($line=<READFILE>)
{
	foreach (@device_list) {			
		if ($line =~ m/,($_),/) {print DEVFILE $line;};
	}
}
system(`ln -s wl_io_filter.dat wl_io.dat`);
