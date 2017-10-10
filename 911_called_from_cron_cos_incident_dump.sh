DATE0=`/bin/date +%s`
$BIN/coscheck
DATE1=`/bin/date +%s`
if [ $DATE0 -eq $DATE1 ]
then
file="/var/www/html/log/wave_files_played.log"
DATE2=`/bin/date`
echo "$DATE2 processing incidents" >> "$file"
/home/irlp/jfall/monroecounty/get_incidents.pl
file="/var/www/html/log/wave_files_played.log"
DATE2=`/bin/date`
echo "$DATE2 processed incidents" >> "$file"
else
file="/var/www/html/log/wave_files_played.log"
DATE2=`/bin/date`
echo "$DATE2 incidents not processed due to COS activity" >> "$file"
fi
