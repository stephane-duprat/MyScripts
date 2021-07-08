#!/usr/bin/perl
# #####################################################################
# $Header: splitfile.pl 02-Jan-2011 acarrasc_es Exp $
#
# QuickPlot.pl
#
# Copyright (c) 2010, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     splitfile.pl
#
#    DESCRIPTION
#     This perl script allows to split a file into several files passed with a input param
#
#    NOTES
#
#    VERSION            MODIFIED        (MM/DD/YY)
#      1.0              acarrasc_es     02/01/11   - split file script
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
if (($numArgs > 2 ) || ($numArgs < 2 ))	{ print "ERROR: to many arguments\nUSAGE: splitfile.pl [project] [number of files]\n"; exit -1; }
elsif ($numArgs == 2 )	{ $fileprefix = "MM_4Kst-$ARGV[0]"; $Project = $ARGV[0] }
$ficini	= "$fileprefix.ini" ;

## get parameters for ini
$folder = GetParam("4KST_DATA_DIR");
$file = GetParam("4KST_FIC_INPUT");
$num_files=$ARGV[1];

chomp($folder);
chdir("$folder") or die "Unable to change to the directory $folder!\n";

## clean previous split files
system(`rm $folder"/"$Project"_M"* 2>/dev/null`);

##generate two arrys with the output file names and handlers for each one of this files
for ($i=1; $i<=$num_files; $i++) {
	push(@outfile_names, $Project."\_M".$i);
	push(@handlers, "WRITEFILE".$i);
}

##open consolidation file for read
open(READFILE, "<$file" ) or die "Can't open $file";

##open a write-handler for each file that we will generate
$i=0;
for ($num=1; $num<=scalar(@outfile_names); $num++) {	
	$HANDLER=$handlers[$i];
	$output_filename=$outfile_names[$i];
	open($HANDLER, ">$output_filename" ) or die "Can't open $output_filename";
	$i++;
}

##in this loop fill all the output file with the lines contained in the file we are reading 
$count=0;
$first_time = 1;
while ($line=<READFILE>)
  {
	$HANDLER=$handlers[$count];
	if ($first_time == 1) 
	{ 
		foreach (@handlers){
			print $_ $line;
		} 
		$first_time=0;
	}
	else {
		print $HANDLER $line;
		$count++;
	}
	if ($count == $num_files) {$count=0;}
  }
##close all files
close (READFILE);
foreach (@handlers) {
	close ($_);
}
