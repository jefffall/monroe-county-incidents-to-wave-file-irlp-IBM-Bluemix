#!/usr/bin/perl

use HTML::TableExtract;
use Text::Table;


########################################################################################################
# Get an array of indicents from the Monroe County 911 website
########################################################################################################

sub get_incidents_array_from_monroe_county

{

my $status = `/bin/touch /home/irlp/jfall/monroecounty/heart_beat_file_check_my_date`;

my $incidents_raw = `wget -qO- http://www2.monroecounty.gov/etcmc/911/raw-wrap.php`;

my $headers =  [ 'Incident', 'Status', 'No.', 'Time' ];
 
my $table_extract = HTML::TableExtract->new(headers => $headers);
my $table_output = Text::Table->new(@$headers);
 
$table_extract->parse($incidents_raw);

my ($table) = $table_extract->tables;

for my $row ($table->rows) {
    $table_output->load($row);
    }
my @incidents = split(/\n/,$table_output);
return @incidents;
}


#################################################################################################
# Append Log file for events played 
#################################################################################################

sub log_play_event_started

{
$file = ${ $_[0] };

open LOGFILE2, '>> /var/www/html/log/wave_files_played.log';
my $date = `/bin/date`;
$date =~ s/\n//;
print LOGFILE2 "$date playing $file\n";
close LOGFILE2;
}


#################################################################################################
# Append Log file for events played
#################################################################################################

sub log_play_event_ended

{
$file = ${ $_[0] };

open LOGFILE2, '>> /var/www/html/log/wave_files_played.log';
my $date = `/bin/date`;
$date =~ s/\n//;
print LOGFILE2 "$date played $file\n";
close LOGFILE2;
}


##################################################################################################
# Get incident location from array of @incidents
#################################################################################################

sub get_incident_location

{
my @incidents = @{ $_[0] };


my $i=-1;
chomp(@incidents);

my $incident_and_time = @incidents[2];
my $incident_location = @incidents[4]; # This will be 4 or 5. It flips according to the incident.

$incident_location =~ s/ {1,}/ /g;
$incidenet_location =~ s/[^a-zA-Z0-9]*//g;

my $report_type = @incidents[6];
if (($report_type =~ /WAITING/) or ($report_type =~ /DISPATCHED/) or ($report_type =~ /ONSCENE/) or ($report_type =~ /ENROUTE/))
  {
  print "\ntriggered incident location change by finding Waiting Dispatched onscene or ENROUTE\n";
  $incident_location = @incidents[5];
  }

$incident_location =~ s/\// at /;
$incident_location =~ s/,//;

return $incident_location;
}

####################################################################################################
# get incident time from string
####################################################################################################

sub get_i_time_str 

{
my $incident_desc_and_time = ${ $_[0] };

my @incident_and_time = split(' ',$incident_desc_and_time);


my $i=-1;
foreach (@incident_and_time)
  {
  $i++;
#  print "$i    $_\n";
  }

my $array_size = @incident_time -1;

$incident_time = @incident_and_time[$array_size];

return $incident_time;
}


####################################################################################################
# get incident time 
####################################################################################################

sub get_incident_time

{
my @incidents = @{ $_[0] };

my @incident_and_time = split(' ',@incidents[2]);


my $i=-1;
foreach (@incident_and_time)
  {
  $i++;
#  print "$i    $_\n";
  }

my $array_size = @incident_time -1;

my $incident_time = @incident_and_time[$array_size];

print "\nincident time (from Monroecounty.gov): $incident_time\n"; 

return $incident_time;
}

####################################################################################################
# incident time to 24 hr integer
####################################################################################################

sub incident_time_to_24hr

{
my $incident_time = ${ $_[0] };


my $am_or_pm = substr($incident_time, -2);

my $time_len = length($incident_time);

my $tfourtime = 0;
my $temp_time = "";
my $hr = "";
my $min = "";

if ($time_len == 7)
   #time example: 11:21pm
  {
  if ($am_or_pm eq "am")
     {
         # am
     $hr = substr($incident_time, 0, 2);
     $min = substr($incident_time, 3, 2);

     $temp_time = $hr . $min;
     
     if ($temp_time ge "1200")
       {
       $tfourtime = $temp_time -1200;
       }
     else
       {
       $tfourtime = $temp_time;
       }
     }
  else
    {
      # pm
     $hr = substr($incident_time, 0, 2);
     $min = substr($incident_time, 3, 2);

     $temp_time = $hr . $min;

    if ($temp_time ge "1200")
      { 
      $tfourtime = $temp_time;
      }
     else
      {
      $tfourtime= $temp_time + 1200;
      }
    }
  }

if ($time_len == 6)
   #time example: 1:21pm
  {
  if ($am_or_pm eq "am")
     {
         # am
     $hr = substr($incident_time, 0, 1);
     $min = substr($incident_time, 2, 2);

     $temp_time = $hr . $min;

     if ($temp_time >= 1200)
       {
       $tfourtime = $temp_time -1200;
       }
     else
       {
       $tfourtime = $temp_time;
       }
     }
  else
    {
      # pm
     $hr = substr($incident_time, 0, 1);
     $min = substr($incident_time, 2, 2);

     $temp_time = $hr . $min;

    if ($temp_time >= 1200)
      {
      $tfourtime = $temp_time;
      }
     else
      {
      $tfourtime= $temp_time + 1200;
      }
    }
  }
return $tfourtime;
}


####################################################################################################
# get system time
####################################################################################################

sub get_system_time

{

###########################
# Get the system time and normalze to 24 hours.
# this is just the date system call for the current time
##########################

 ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();


$time_now = $hour . $min;

$time_now = $time_now +1;
$time_now = $time_now -1;

return $time_now;
}

###################################################################################################
#  evaluate_incident
###################################################################################################

sub evaluate_incident

{
my $incident_and_time =  ${ $_[0] };

  if (($incident_and_time =~ /RT 390/) or ($incident_and_time =~ /RT 490/) or ($incident_and_time =~ /RT 590/) or ($incident_and_time =~ /RT 104/) or ($incident_and_time =~ /structure fire/) or ( $incident_and_time =~ /MVA/ ) or ($incident_and_time =~ /Accident/) or (($incident_and_time =~ /Hit and Run/) and (!$incident_and_time =~ /no injury/))  )

  {
  print "\nReportable incident: accident or MVA or hit and run or structure fire or dangerous condition is true\n";

  return 1;
  }
else 
   {
  return 0;
   }
}

##########################################################################################################################
# generate time sentence 
##########################################################################################################################

sub generate_time_sentence
{
my $it = ${ $_[0] };

######################################################################################
# This section fixes up the string time obtained from monroe county into a sentence 
# that will sound good.
# monroe gives times like 951pm or 1052pm or 834am or 224pm
# this section splits up the time to make it readable as
# 1052pm becomes 10 52 p m so that it makes sense hearing it from Google Translate
######################################################################################

# $incident_time is extracted from Monroe County 911 site
my $hr = 0;
my $min = 0;
my $am_pm = "";

my $time_sentence = "reported at ";

my $strlen = length($it);

if ($strlen == 6)

  {
  # get the first character
my  $hr = substr($it, 0, 1);
  $time_sentence = $time_sentence . $hr . " ";

  $min = substr($it, 2, 2);
  $time_sentence = $time_sentence . $min . " ";

  $am_pm = substr($it, 4, 2);
  if ($am_pm eq "am")
    {
    $time_sentence = $time_sentence . "a m ";
    }
  else
   {
    $time_sentence = $time_sentence . "p m ";
   }
  }
 if ($strlen == 7)
 {
  # get the two characters
  $hr = substr($it, 0, 2);
  $time_sentence = $time_sentence . $hr . " ";

  $min = substr($it, 3, 2);
  $time_sentence = $time_sentence . $min . " ";

  $am_pm = substr($it, 5, 2);
  if ($am_pm eq "am")
    {
    $time_sentence = $time_sentence . "a m ";
    }
  else
   {
    $time_sentence = $time_sentence . "p m ";
   }
  }

  # add on the location word

  $time_sentence = $time_sentence . " incident location is ";

print "time sentence is: $time_sentence\n";

return $time_sentence;
}

######################################################################################################################################
# get incident description
######################################################################################################################################


sub get_incident_description

{
my @incidents =  @{ $_[0] };

 my $incident_and_time = @incidents[2];

 $incident_and_time =~ s/ {1,}/ /g;

  # remove the last 6 characters from the $incident_and_time which is the time from the Monroe County Incident.
  # We make our own time below
  
  $incident_and_time =  substr($incident_and_time, 0, -7);
return $incident_and_time;
}

######################################################################################################################################
# filter_incident_location 
######################################################################################################################################

sub filter_incident_location

{
my $incident_location =  ${ $_[0] };

  #print "Incident location transalate status = $translate\n";
  $incident_location =~ s/ {1,}/ /g;
  $leng = length($incident_location);
  #print "Length of string incident_location = length($leng)\n";

  $incident_location =~ s/\t//g;

  $incident_location  =~ s/show on map//; 
  $incident_location  =~ s#,# #g; 
  $incident_location  =~ s#/# at #g; 

  $incident_location  =~ s/ RD / ROAD /g; 
  $incident_location  =~ s/ST PAUL ST/Saint Paul Street/; 
  $incident_location  =~ s/ST PAUL/Saint Paul/; 
  $incident_location  =~ s/ DR / DRIVE /g; 
  $incident_location  =~ s/ BR / BRIDGE /; 
  $incident_location  =~ s/ AV / AVENUE /g; 
  $incident_location  =~ s/ WY / WAY /g; 
  $incident_location  =~ s/ TE / Terrace /; 
  $incident_location  =~ s/ ST / STREET /g; 
  $incident_location  =~ s/ STS/ STREETS /g; 
  $incident_location  =~ s/ PL / PLACE /g; 
  $incident_location  =~ s/ MT / MOUNT /g; 
  $incident_location  =~ s/ CT / COURT /g; 
  $incident_location  =~ s/ CI / CIRCLE /; 
  $incident_location  =~ s/ N / NORTH /g; 
  $incident_location  =~ s/ W / WEST /g; 
  $incident_location  =~ s/ S / SOUTH /g; 
  $incident_location  =~ s/ E / EAST /g; 
  $incident_location  =~ s/ T L / TOWN LINE /; 
  $incident_location  =~ s/UD /Upper Deck /; 
  $incident_location  =~ s/LP /Loop /; 
  $incident_location  =~ s/IL /Inner Loop /; 
  $incident_location  =~ s/ C L / County Line /; 
  
  $incident_location  =~ s/ EB / EAST BOUND /g; 
  $incident_location  =~ s/ NB / NORTH BOUND /g; 
  $incident_location  =~ s/ SB / SOUTH BOUND /g; 
  $incident_location  =~ s/ WB / WEST BOUND /g; 
  $incident_location  =~ s/EB / EAST BOUND /g;
  $incident_location  =~ s/NB / NORTH BOUND /g;
  $incident_location  =~ s/SB / SOUTH BOUND /g;
  $incident_location  =~ s/WB / WEST BOUND /g;

  $incident_location  =~ s/ EO / EAST OF /g;
  $incident_location  =~ s/ NO / NORTH OF /g;
  $incident_location  =~ s/ SO / SOUTH OF /g;
  $incident_location  =~ s/ WO / WEST OF /g;

  $incident_location  =~ s/ RT / ROUTE /g; 
  $incident_location  =~ s/ RR / RAIL ROAD /; 
  $incident_location  =~ s/ XG / CROSSING /; 
  $incident_location  =~ s/ BL / BOULEVARD /g; 
  $incident_location  =~ s/ CT / COURT /g;
  $incident_location  =~ s/ PK / PARK /g;
  $incident_location  =~ s/ PW / PARKWAY /g;

#change chili to chilie
  $incident_location  =~ s/ CHILI / CHILIE /g;

  $incident_location  =~ s/ ROUTE 390 / INTERSTATE 390 /g;
  $incident_location  =~ s/ ROUTE 490 / INTERSTATE 490 /g;
  $incident_location  =~ s/ ROUTE 590 / INTERSTATE 590 /g;

  $incident_location  =~ s/MVA / MOTOR VEHICLE ACCIDENT /g;

  ### finally at the end fix up examples like N Goodman Street to North Goodman Street

my $extracted = substr($incident_location, 0, 2);

if ($extracted eq "N ") 
  {
  $incident_location  =~ s/N /North /;
  }
elsif ($extracted eq "S ") 
   {
   $incident_location  =~ s/S /South /;
   }
elsif ($extracted eq "E ") 
   {
   $incident_location  =~ s/E /East /;
   }
elsif ($extracted eq "W ")
   {
   $incident_location  =~ s/W /West /;
   }
elsif ($extracted eq "RT")
   {
   $incident_location  =~ s/RT/Route/;
   } 

$incident_location = $incident_location . " New York";
return $incident_location;

}


##############################################################################################################################
# translate google 
##############################################################################################################################

sub translate_google
{
my $file = ${ $_[0] };
my $sentence =  ${ $_[1] };

$translate = `/usr/bin/wget -q -U Mozilla -O /home/irlp/jfall/monroecounty/$file "http://translate.google.com/translate_tts?ie=UTF-8&tl=en&client=t&q=$sentence"`;
}


##############################################################################################################################
# translate IBM Bluemix 
##############################################################################################################################

sub translate_bluemix
{
my $file = ${ $_[0] };
my $sentence =  ${ $_[1] };


print "sentence = $sentence\n\n";


# 10.24.2015 IBM Bluemix text to voice.
#$translate = `curl -u "yoursubscription":"yourkey" -X POST --header "Content-Type: application/json" --header "Accept: audio/wav" --data "{\\"text\\":\\"$sentence\\"}"  "https://stream.watsonplatform.net/text-to-speech/api/v1/synthesize" > /home/irlp/jfall/weatherforecast/weatherforecast.wav`;
}


##############################################################################################################################
# key
##############################################################################################################################

sub key
{
  $status = `/home/irlp/bin/forcekey`;
}




##############################################################################################################################
# unkey
##############################################################################################################################

sub unkey
{
  $status = `/home/irlp/bin/forceunkey`;
}

#############################################################################################################################
# convert_mp3_to_wav
#############################################################################################################################

sub convert_mp3_to_wav

{
my $path =  ${ $_[0] };
my $file =  ${ $_[1] };

my $mp3 = $path  ."/" . $file . ".mp3";
my $wav = $path . "/" . $file . ".wav";


$status = `/usr/local/bin/lame --decode $mp3 $wav`;
#$status = `/usr/bin/lame --decode $mp3 $wav`;
}


#############################################################################################################################
# dump_website_array 
#############################################################################################################################

sub dump_website_array

{
my @website_array =  @{ $_[0] };

my $i=-1;
print "\n";
foreach (@website_array)
  { 
  $i = $i + 1;
  print "Line: $i    $_\n";
  }
print "\n";
}

#############################################################################################################################
# play structure fire sound
#############################################################################################################################
sub play_structure_fire_sound
    {
    log_play_event_started(\"alertsounds/1claxon1.wav");
    $status = `/usr/bin/play /home/irlp/jfall/monroecounty/alertsounds/1claxon1.wav`;
    log_play_event_ended(\"alertsounds/1claxon1.wav");
    }

#############################################################################################################################
# play accident alart sound
#############################################################################################################################
sub play_accident_alert_sound
    {
    log_play_event_started(\"alertsounds/alert3.wav");
    $status = `/usr/bin/play /home/irlp/jfall/monroecounty/alertsounds/alert3.wav`;
    log_play_event_ended(\"alertsounds/alert3.wav");
    }

#############################################################################################################################
# play 
#############################################################################################################################

sub play

{
my $file = ${ $_[0] };

  log_play_event_started(\$file);
  $status = `/usr/bin/play $file`;
  log_play_event_ended(\$file);
}


#############################################################################################################################
# wait for cos drop 
#############################################################################################################################

sub wait_for_cos_drop 
{
# if the COS is high, this function just locks up and jams the proram to stay here

 
$cos = `/home/irlp/bin/coscheck`;
}

###################################################################################################################
# Process an Incident 
###################################################################################################################

sub process_an_incident

{
my @incident =  @{ $_[0] };
my $voice = ${ $_[1] }; 

################
# Open a log file
###############
open LOGFILE, '>> /home/irlp/jfall/monroecounty/log/monroecountyaccidents.log';

my $incident_description = get_incident_description(\@incident);
my $incident_location = get_incident_location(\@incident);
my $incident_time = get_incident_time(\@incident);
my $filtered_incident_location = filter_incident_location(\$incident_location);

my $time_sentence = generate_time_sentence(\$incident_time);

##########
# Log the event
#########
my $id = $incident_description;
my $fl = $filtered_incident_location;
my $it = $incident_time;

# get rid of excess spaces

$id =~ s/ +/ /g;
$fl =~ s/ +/ /g;
$it =~ s/ +/ /g;

# get rid of all tabs

$id =~ s/\t//g;
$fl =~ s/\t//g;
$it =~ s/\t//g;

my $date = `/bin/date`; 
print LOGFILE "$date: Time: $it Incident: $id Location: $fl\n\n";

sub make_files_for_google_translate

{

################# create MP3's ###########################################################

#### make the MP3 filenames
my $incident_description_mp3 = $incident_time . "-incident_description.mp3";
my $time_sentence_mp3 = $incident_time . "-time_sentence.mp3";
my $incident_location_mp3 = $incident_time . "-incident_location.mp3";
my $repeater_reported_mp3 = $incident_time . "-repeater_reported.mp3";

translate(\$incident_description_mp3, \$incident_description);
translate(\$time_sentence_mp3, \$time_sentence); 
translate(\$incident_location_mp3, \$filtered_incident_location);
translate(\$repeater_reported_mp3, \"this is a live amateur radio bulletin public safety update by w r 2 eh h l repeater");


############## convert MP3's to .wav #########################################################

### make the MP3 to WAV filenames

my $incident_description_conv = $incident_time . "-incident_description";
my $time_sentence_conv = $incident_time . "-time_sentence";
my $incident_location_conv = $incident_time . "-incident_location";
my $repeater_reported_conv = $incident_time . "-repeater_reported";

convert_mp3_to_wav(\"/home/irlp/jfall/monroecounty",\$incident_description_conv);
convert_mp3_to_wav(\"/home/irlp/jfall/monroecounty",\$time_sentence_conv);
convert_mp3_to_wav(\"/home/irlp/jfall/monroecounty",\$incident_location_conv);
convert_mp3_to_wav(\"/home/irlp/jfall/monroecounty",\$repeater_reported_conv);

}

sub make_files_for_ibm_bluemix

{
$filtered_incident_location = filter_incident_location(\$incident_location);
$incident_string = $incident_description . " " . $time_sentence . " " . $filtered_incident_location .  " this is a live amateur radio bulletin public safety update by w r two eh h l repeater";
#$incident_string = $time_sentence . " " . $filtered_incident_location .  " this is a live amateur radio bulletin public safety update by w r two eh h l repeater";

# Take out CRLF. They break Bluemix Text to speech
$incident_string =~ s/[\r\n]//g;
$incident_string =~ s/[^a-zA-Z0-9 _-]//g;

print "incident string = \n\n$incident_string\n\n\n";


# 10.24.2015 IBM Bluemix text to voice.
$translate = `curl -u "YourSubscription":"YourKey" -X POST --header "Content-Type: application/json" --header "Accept: audio/wav" --data "{\\"text\\":\\"$incident_string\\"}"  "https://stream.watsonplatform.net/text-to-speech/api/v1/synthesize" > /home/irlp/jfall/monroecounty/incident.wav`;

}




make_files_for_ibm_bluemix;
#make_files_for_google_translate;

# Wait 25  seconds. Avoids tramping on the ID
sleep 25;

# pauses here until the COS drops. The program just locks up here if the COS is on
wait_for_cos_drop;



key;
print "incident description looking for structure fire -----======= $incident_description\n";
  if ($incident_description =~ /structure fire/)
  {
   play_structure_fire_sound;
  }
else
  {
  play_accident_alert_sound;
  }


sub play_googlemade_files

{

my $incident_description_wav = $incident_time . "-incident_description.wav";
my $time_sentence_wav = $incident_time . "-time_sentence.wav";
my $incident_location_wav = $incident_time . "-incident_location.wav";
my $repeater_reported_wav = $incident_time . "-repeater_reported.wav";

play(\"/home/irlp/jfall/monroecounty/$incident_description_wav");
play(\"/home/irlp/jfall/monroecounty/$time_sentence_wav");
play(\"/home/irlp/jfall/monroecounty/$incident_location_wav");
play(\"/home/irlp/jfall/monroecounty/$repeater_reported_wav");

}

sub play_bluemixmade_files

{
play(\"/home/irlp/jfall/monroecounty/incident.wav");
}

play_bluemixmade_files; 

unkey;

# Clean up all the files - remove them

sub cleanup_googlemade_files

{

my $prefix = "/home/irlp/jfall/monroecounty/";

$filename =   $prefix . $incident_description_conv . ".mp3";
`rm  $filename`;
$filename =  $prefix . $time_sentence_conv . ".mp3"; 
`rm  $filename`;
$filename =  $prefix . $incident_location_conv . ".mp3";
`rm  $filename`;
$filename = $prefix . $repeater_reported_conv . ".mp3";
`rm $filename`;

$filename = "/home/irlp/jfall/monroecounty/" . $incident_description_wav;
`cp $filename /home/irlp/jfall/monroecounty/log/1_incident_description.wav`;
`rm  $filename`;
$filename = "/home/irlp/jfall/monroecounty/" . $time_sentence_wav;
`cp $filename /home/irlp/jfall/monroecounty/log/2_incident_time.wav`;
`rm  $filename`;
$filename =  "/home/irlp/jfall/monroecounty/" . $incident_location_wav;
`cp $filename /home/irlp/jfall/monroecounty/log/3_incident_location.wav`;
`rm  $filename`;
$filename = "/home/irlp/jfall/monroecounty/" . $repeater_reported_wav;
`cp $filename /home/irlp/jfall/monroecounty/log/4_repeater_reported.wav`;
`rm  $filename`;

}

sub cleanup_bluemixmade_files

{
$status = `rm /home/irlp/jfall/monroecounty/incident.wav`;
}

cleanup_bluemixmade_files;


close LOGFILE;
}

###################################################################################################################
# scan_incidents array
###################################################################################################################

sub scan_incidents_array

{
my @incidents =  @{ $_[0] };
my $voice =  ${ $_[1] };

my $index = -1;

my $incident_desc_and_time = "";
my $incident_time = "";
my $incident_time_int = 0;

my @production_array = "";

# production array matches the monroe country array
# line 0 not used.
# line 1 not used.
# line 2 - incident description
# line 3 not used.
# line 4 - might be incident location.
# line 5 - might be incident location or next incident 

@production_array[0] = " ";
@production_array[1] = " ";

my $break_out = 0;

foreach (@incidents)
  {
  $index = $index + 1;
  $incident_status = $_;
  if (($incident_status =~ /WAITING/) or ($incident_status =~ /DISPATCHED/) or ($incident_status =~ /ONSCENE/) or ($incident_status =~ /ENROUTE/))
        {
        #  this is found in the monroe county array then the incident type is next
        # Incident description will be index +1 at this point as will the incident time at the end of the string.

        $incident_desc_and_time = @incidents[$index+1]; 
        $incident_time = get_i_time_str(\$incident_desc_and_time);
        $incident_time_int = incident_time_to_24hr(\$incident_time);
        $system_window_time =  get_system_time ; # Here we set the look back window with the (- 3 or 4 or whatever minutes)
        $system_window_time = $system_window_time - 3;
        #$system_window_time = 928; # put an integer time in here for testing only
        #print "$incident_time_int == $system_window_time\n";
        if ($incident_time_int == $system_window_time)
            {
            if (evaluate_incident(\$incident_desc_and_time) == 1)
                {
                # production indicent - report it on the repeater
                # build up the productive array
                @production_array[2] = @incidents[$index+1]; # Put in the incident description and time
                @production_array[3] = " "; # not used. [$index+2]
                @production_array[4] = @incidents[$index+3]; 
                @production_array[5] = @incidents[$index+4];
                @production_array[6] = @incidents[$index+5];
                #### if the COR is busy, we hold here on the COR wait ####
                `/home/irlp/bin/coscheck`;
                process_an_incident(\@production_array, $voice);
                $break_out = 1;
                }
           }
       } # if Incident status 
  if ($break_out == 1)
    {
    # break out of the for loop. If we say one accident then we will not say any more.
    last;
    }
  } # foreach 

}

###################################################################################################################
# MAIN
###################################################################################################################

#  $voice = "en-GB"; # Female British
#  $voice = "en-AU"; # Female Australian slow and sounds bad
#  $voice = "en-CA"; # Female Canadian sounds same as American
   $voice= "en";    # Female USA

@incidents = get_incidents_array_from_monroe_county;

#dump_website_array(\@incidents);

scan_incidents_array(\@incidents, \$voice);

