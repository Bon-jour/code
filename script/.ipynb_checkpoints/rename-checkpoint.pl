#!/usr/bin/perl
open IN,"$ARGV[0]";
$a = $ARGV[0];
$a =~ /(\S+).fa/;
$name = $1;
open OUT,">./${name}_rename.fa";
while($line=<IN>)
{
if($line =~ /^>/)
{
$line =~ s/>/>$name\_/;
print OUT "$line";
}
else
{
print OUT "$line";
}
}

