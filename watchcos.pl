#!/usr/bin/perl
use integer;
$i = 0;
while (1)
{
$sec = $sec + 1;
$date = `date`;
$clear = `clear`;
print "$clear";
print "$date\n\n";

$cos = `/home/irlp/bin/coscheck`;
if ($cos == 1)
  {
  print "Time elapsed: $sec, Squelch is open - PL detected. Signal is detected\n";
  }
else
  {
  print "Seconds elapsed $sec, No carrier detected\n";
  }
print "\n$dir\n";
sleep 1;
}
