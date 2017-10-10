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
print "cos value down = $cos\n";
sleep 1;
}
