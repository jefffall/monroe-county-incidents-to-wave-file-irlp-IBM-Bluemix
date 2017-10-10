if [ -e /home/irlp/custom/accident_reporting_unlock ]
then
  if [ -e  /home/irlp/custom/accident_reporting_on ]
  then
  /home/irlp/jfall/monroecounty/get_incidents.pl
  /bin/usleep 500000
  $BIN/forceunkey
  fi
fi
