#!/usr/bin/perl
while (1)
{
$clear = `clear`;
print "$clear";
$dir = `ls -l`;
print "\n$dir\n";
sleep 10;
}
