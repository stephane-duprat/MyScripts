#!/usr/bin/perl
# #####################################################################
# $Header: showparam.pl 24-Mar-2011 acarrasc_es Exp $
#
# showparam.pl
#
# Copyright (c) 2011, Oracle Consulting (Spain).  All rights reserved.
#
#    NAME
#     showparam.pl
#
#    DESCRIPTION
#     This perl script allows to show the value of any parameter in the INI file
#
#    NOTES
#
#    VERSION            MODIFIED        (MM/DD/YY)
#      1.0              sduprat_es     24/03/11   - Initial version
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

my $line;

$numArgs = $#ARGV + 1;
my $fileprefix ;
if ($numArgs > 1 ) { print "ERROR: to many arguments\nUSAGE: showparam.pl [project]\n"; exit -1; }
elsif ($numArgs < 1 ) { print "ERROR: to few arguments\nUSAGE: showparam.pl [project]\n"; exit -1; }
elsif ($numArgs == 1 )	{ $fileprefix = "MM_4Kst-$ARGV[0]"; $Project = $ARGV[0] }
$ficini	= "$fileprefix.ini" ;

open(FICINI, "<$ficini" ) or die "Can't open $ficini";
while ( <FICINI>)
{
    $line = $_;
    chomp ($line);
    if ( $line =~ /^4KST/ )
    {
        print "$line\n";
    }
}
close FICINI;

exit;
