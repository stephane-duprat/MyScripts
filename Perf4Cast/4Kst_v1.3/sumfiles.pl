#!/usr/bin/perl


###########
## MAIN ###
###########
use POSIX;

my $file1="/tmp/PROCAT_Caracterizado.txt";
my $file2="/tmp/PROTAS_Caracterizado.txt";
my $fileout="/tmp/PROCAT_PROTAS_Caracterizado.txt";
my $sumMetrics="7,8,13,14,15,16,17,18,19,20,21,22";
my @arrM = split(/,/, $sumMetrics);

open( FILE1, "$file1" ) or die "Can't open  $file1 : $!";
my @num = <FILE1>;
close FILE1;
my $numsnap = @num;


open(FILE1, "<$file1" ) or die "Can't open $file1";
open(FICOUT, ">$fileout" ) or die "Can't open $fileout";

my $snapid1;
my $snapid2;
my $count=0;
my $buffer;
$|=1; ## Value distinct from zero for that variable enables print auto-flush !!!

while ($line1=<FILE1>)
  {
        if ( $count==0 )
        {
            print FICOUT $line1; ## Writes the header line in the output file !!!
        }
        else
        {
            chomp($line1);
            @arr1 = split(/\|/, $line1);
            $snapid1 = @arr1 [0];

            ## Reads FILE2 to seek snap_id !!!
            open(FILE2, "<$file2" ) or die "Can't open $file2";
            while (<FILE2>)
            {
                 $line2 = $_;
                 chomp($line2);
                 @arr2 = split(/\|/, $line2);
                 $snapid2 = @arr2 [0];
                 if ( $snapid1 =~ /$snapid2/ )
                 {
                       for ($k=0;$k < scalar(@arrM);$k++) ## Sums the values that need to be sumed !!!
                       {
                             @arr2 [@arrM[$k]] = @arr2 [@arrM[$k]] + @arr1 [@arrM[$k]];
                       }

                       ## Formats line to be printed in FICOUT file !!!
                       $buffer="$snapid2";
                       for ($k=1;$k<scalar(@arr2);$k++)
                       {
                            $buffer=$buffer."|".@arr2 [$k];
                       }
                       print FICOUT "$buffer\n";
                       last;
                 }
            }
            close FILE2;
        }
        $count=$count+1;
        print "\rRaw files processing: $count/$numsnap ( ".ceil(($count/$numsnap)*100)."% )";
  }
##close all files
close (FILE1);
close (FICOUT);
print "\n";
exit;
