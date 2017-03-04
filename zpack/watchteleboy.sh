#!/bin/bash -i
################################################
# Bash script for watching/recording online TV 
# streams from teleboy.ch without browser and 
# =no f*** flash=.
#
# License:  GnuGPL v2
# Authors:   
#   2011-2012   Roman Haefeli
#   2012        Doma Smoljo
#   2011        Alexander Tuchaček 
# last modified: 2012-05-12 by Roman Haefeli
# program version: (check below)
################################################

VERSION=1.10

# Set some default values
TMPDIR=/tmp
UAGENT='Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0'
MPLAYEROPTS="-really-quiet"
RECORDPATH=$(pwd)
CHANSELECTION=all
BUFFER=500000

# Check dependencies
programlist="rtmpdump mplayer wget grep cut crontab date iconv"
for program in $programlist
do
    if ! which $program > /dev/null
    then
        echo "ERROR:" 1>&2
        echo "Could not find ${program}. Is it installed?" 1>&2
        exit 1
    fi
done

# Check availability of whiptail (interactive dialog boxes)
whiptail=$(which whiptail > /dev/null && echo true || echo false)

# Read config (overrides default values) or create it
CONFIG=~/.watchteleboyrc
if [ -f $CONFIG ]
then
  . $CONFIG
else
  echo "In order for this script to work properly you need to"
  echo "provide your user credentials for the teleboy.ch"
  echo "service."
  while true
  do
    read -p "Please enter your user name: " USER
    read -s -p "Please enter your password:  " PASS
    echo ""
    read -s -p "Confirm your password:       " PASS2
    echo "" 
    if [ "$PASS" == "$PASS2" ]
    then
      break
    else
      echo "The password entries don't match."
    fi
  done  
  echo "CAUTION: writing plain text password to the config file!"
  echo "USER='$USER'" >> $CONFIG
  echo "PASS='$PASS'" >> $CONFIG
  echo "created config file $CONFIG"  
fi

# check availability of login
# since teleboy.ch only allows you to stream one channel per session, 
# we use a different login for each session (if available)
# more users can be configured in CONFIG
userinc=1
if [ -f $TMPDIR/watchteleboy.${USER}/loggedin ]
then 
  while true
  do
    ((userinc += 1))
    uservar="USER${userinc}"
    if [ -z "${!uservar}" ]
    then
      $quiet || exit 1
      echo "Available logins already in use. Exiting" 1>&2 
      echo "You might want to configure more credentials in $CONFIG" 1>&2
      exit 1
    fi
    if ! [ -f $TMPDIR/watchteleboy.${!uservar}/loggedin ]
    then
      break # we found a login not yet in use
    fi
  done
  # use login not yet in use
  USER=${!uservar}
  passvar="PASS${userinc}"
  PASS=${!passvar}
fi

# set working directory for keeping session data
TMPPATH="${TMPDIR}/watchteleboy.${USER}"

# Comandline argument parsing
channel=false
deletecron=false
deleteme=false
duration=false
endtime=false
help=false
list=false
path=false
quiet=false
record=false
showname=false
skiplogincheck=false
starttime=false
version=false
while [ $# -gt 0 ]
do
  case "$1" in
    -c|--channel) channel=true; CHANNEL=$2; shift;;
    -d|--duration) duration=true; DURATION="$2"; shift;;
    -e|--endtime) endtime=true; ENDTIME="$2"; shift;;
    -h|--help) help=true;;
    -l|--list) list=true;;
    -n|--showname) showname=true; SHOWNAME="$2"; shift;;
    -m|--mplayer-opts) mplayeropts=true; MPLAYEROPTS="$2"; shift;;
    -p|--path) path=true; RECORDPATH="$2"; shift;;
    -q|--quiet) quiet=true;;
    -r|--record) record=true;;
    -t|--starttime) starttime=true; STARTTIME="$2"; shift;;
    -v|--version) version=true;;
    --deleteme) deleteme=true; DELETEME="$2"; shift;;
    --delete-cron) deletecron=true; DELCHAN="$2"; DELTIME="$3"; shift; shift;;
    --skip-logincheck) skiplogincheck=true;;
    -*) echo "$(basename $0): error - unrecognized option '$1'" 1>&2
        echo "use '$(basename $0) --help' to get a list of available options" 1>&2
        exit 1;;
    *)  break;;
  esac
  shift
done

# option -v|--version
if $version
then
  echo "watchteleboy $VERSION"
  echo "Authors:   
  2011-2012   Roman Haefeli
  2012        Doma Smoljo
  2011        Alexander Tuchaček"
  echo "Licensed under the GNU Public License 2.0 (GPL-2)"
  exit
fi

# option -h|--help
if $help
then
  cat << EOF

watchteleboy
------------

  <no options>                go into interactive mode

GENERAL OPTIONS:

  -c|--channel CHANNEL        specify a channel
  --delete-cron CHANNEL TIME  delete a previously scheduled job
  -h|--help                   show this help and exit
  -l|--list                   print a list of all channels and exit
  -q|--quiet                  suppress any output and do not ask
  --skip-logincheck           do not test if login was successfull
  -v|--version                print the version of this program

OPTIONS FOR RECORDING (require -r|--record):

  -e|--endtime TIME           schedule the end time of the recording
  -d|--duration SECONDS	      specify the duration of the recording
  -n|--showname SHOWNAME      specify file name prefix
  -p|--path DIR		      specify target directory
  -r|--record                 record a stream instead of watching it
  -t|--starttime TIME	      schedule the start time for a recording

MPLAYER SPECIFIC OPTIONS:

  -m|--mplayer-opts OPTS      pass options to mplayer

EOF
  exit
fi

# delete cron entry (used by tvbrowser record plugin)
if $deletecron
then
  if ! date -d "$DELTIME" > /dev/null 2>&1
  then
    echo "Could not parse specified time: $DELTIME" 1>&2
    exit 1
  fi
  crontempfile="/tmp/crontab.tmp"
  searchstring="$(date -d "$DELTIME" +"^%M[[:space:]]%H[[:space:]]%d[[:space:]]%m").*watchteleboy.*channel[[:space:]]${DELCHAN}.*"
  if ! crontab -l | grep "$searchstring" > /dev/null
  then
    echo "Could not find specified job in crontab." 1>&2
    exit 1
  else
    crontab -l | grep -v "$searchstring" > $crontempfile 
    crontab < $crontempfile
    rm $crontempfile
    $quiet || echo "Successfully deleted crontab entry."
    exit 0
  fi
fi

# Check record path validity
if $record
then
  if [ ! -d "$RECORDPATH" ]
  then
    echo "There is no such directory: $RECORDPATH" 1>&2
    exit 1
  elif [ ! -w "$RECORDPATH" ]
  then
    echo "You don't have permission to write to $RECORDPATH" 1>&2
    exit 1
  fi
fi

# Create TMPDIR if required
if  [ ! -d $TMPPATH ]
then
  if ! mkdir -p $TMPPATH
  then
    echo "Could not create directory: $TMPPATH" 1>&2
    exit 1
  fi
fi

# get the session cookie
$quiet || echo -n "login (as '$USER')..."
URL="http://www.teleboy.ch/watchlist/"
wget -U "$UAGENT" \
  --quiet \
  --save-cookies $TMPPATH/cookie0 \
  --keep-session-cookies \
  -O /dev/null \
  $URL
POST="login=${USER}&password=${PASS}&x=14&y=7&keep_login=1"
URL="http://www.teleboy.ch/layer/login_check"
wget -U "$UAGENT" \
  --quiet \
  --no-check-certificate \
  --load-cookies $TMPPATH/cookie0 \
  --save-cookies $TMPPATH/cookie1 \
  --keep-session-cookies \
  --save-headers \
  --post-data $POST \
  -O /dev/null \
  $URL

# remove loggedin file on exit
function cleanup {
  rm -rf $TMPPATH
  $quiet || echo ""
}

# check if login was successfull
if $skiplogincheck
  then
  $quiet || echo "ok (forced)"
else 
  if ! grep "^www\.teleboy\.ch.*cinergy_auth" $TMPPATH/cookie1 > /dev/null
  then
    $quiet && exit 1
    echo "failed!!!!" 1>&2
    echo "Please check your credentials in the config file:" 1>&2
    echo "$CONFIG" 1>&2
    exit 1
  else
    $quiet || echo "ok"
    touch $TMPPATH/loggedin
    trap cleanup INT TERM EXIT
  fi
fi

# get the station / channel list
$quiet || echo -n "receive channel list..."
POST="cmd=getStations&category=${CHANSELECTION}"
URL="http://www.teleboy.ch/tv/player/includes/ajax.php"
wget --user-agent "$UAGENT" \
    --quiet \
    --load-cookies $TMPPATH/cookie1 \
    --post-data $POST \
    --output-document $TMPPATH/stations.html.latin1 \
    $URL
iconv -f LATIN1 -t UTF-8 $TMPPATH/stations.html.latin1 > $TMPPATH/stations.html
# Check if current user has answered all questions on teleboy.ch
if ! grep "getLiveChannelData" $TMPPATH/stations.html > /dev/null 
then
  echo "failed"
  echo ""
  echo "The user '$USER' is not fully configured for watching streams."
  echo "Please log in to http://www.teleboy.ch and click the 'Live TV' tab."
  echo "Please fill out the form. If you're able to watch streams in the"
  echo "browser, check again with watchteleboy."
  exit 1
fi
channelnames=$(grep -e " <img.*src=\"/img/station/.*/logo" $TMPPATH/stations.html | cut -d'"' -f8)
channelids=$(grep "javascript:getLiveChannelData" $TMPPATH/stations.html | cut -d "(" -f 2 | cut -d ")" -f1 | sed -e 's/,//g')
CHANNELS=$(paste -d' ' \
  <(echo "$channelnames" | \
    sed -e '
      s/ //g
      s/\.//g
      s/+/plus/g
      s/Ô/O/g
    ' | head -n $(echo "$channelids" | wc -l)) \
  <(echo "$channelids"))
$quiet || echo "done"
CHANNELS="
$(echo "$CHANNELS" | grep -iv euronews)
SF1_o 159 0
SFzwei_o 108 0
Arte_fr 161 20
EuroNews_de 216 0
EuroNews_fr 158 0
EuroNews_it 217 0
EuroNews_en 45 0
"

# option -l|--list
if $list
then
  echo "$CHANNELS" | cut -d " " -f 1 
  exit
fi

# get flashplayer url
SWFFILE=$(wget \
  -O - \
  --quiet \
  "http://www.teleboy.ch/tv/player/player.php" | \
  grep "nelloplayer" | \
  cut -d'"' -f2 | \
  tail -n1)

# Da Time Valeditee Checkah
function check_time_validity {
  # ARGS:
  # 1: datetime string
  if ! date -d "$1" > /dev/null
  then
    echo "Could not understand time format." 1>&2
    exit 1
  fi
}

function dump_rtmp_stream {
  # ARGS:
  # 1: channel
  # 2: output file
  [ -d $TMPPATH ] || exit 1
  cid=$(echo "$CHANNELS" | grep -i "^${1} " | cut -d" " -f2)
  cid2=$(echo "$CHANNELS" | grep -i "^${1} " | cut -d" " -f3)
  URLBASE="http://www.teleboy.ch/tv/player"
  POST="cmd=getLiveChannelParams&cid=${cid}&cid2=${cid2}"
  STREAMINFO=$(wget -U "$UAGENT" \
    --quiet \
    --referer "${URLBASE}/player.php" \
    --load-cookies $TMPPATH/cookie1 \
    --post-data $POST \
    --keep-session-cookies \
    --output-document /dev/stdout \
    "${URLBASE}/includes/ajax.php")

  # get rtmp parameters
  x11=$(echo "$STREAMINFO" | cut -d "|" -f11)
  c1=$(echo "$STREAMINFO"  | cut -d "|" -f4)
  c2=$(echo "$STREAMINFO"  | cut -d "|" -f5)
  c3=$(echo "$STREAMINFO"  | cut -d "|" -f6)
  c4=$(echo "$STREAMINFO"  | cut -d "|" -f7)
  c5=$(echo "$STREAMINFO"  | cut -d "|" -f8)
  c6=$(echo "$STREAMINFO"  | cut -d "|" -f9)
  gip=$(echo "$STREAMINFO"  | cut -d "|" -f10)
  playpath=${cid}${c2}.stream

  # show channel name
  $quiet || echo "$STREAMINFO"  | cut -d "|" -f2 | iconv -f LATIN1 -t UTF-8
  
  # get IP address of streaming server
  GIPURL="${URLBASE}/includes/getserver.php?version=${gip}&nocache=1314619521398"
  wget -U "$UAGENT" \
    --quiet \
    -O $TMPPATH/step4.html \
    $GIPURL
  IP=$(cat $TMPPATH/step4.html | cut -d "=" -f2)

  # rtmpdump command
  rtmpdump \
    --rtmp rtmp://${IP}/${x11} \
    --app ${x11} \
    --flashVer LNX 10,3,183,7 \
    --swfVfy ${URLBASE}/${SWFFILE} \
    --pageUrl ${URLBASE}/player.php \
    --playpath $playpath \
    -C S:$c1 -C S:$c2 -C S:$c3 -C S:$c4 -C S:$c5 \
    --quiet \
    --flv "$2" 2> /dev/null &
  PID=$!
}

# test channel input validity
function channel_validity {
  # ARGS:
  # 1: channel
  if [ -z "$CHANNEL" ]
  then
    echo "Please specify a channel"
    return 1
  elif echo $CHANNELS | grep -i $1 > /dev/null
  then
    return 0
  else
    echo "'$CHANNEL' is not a valid channel." 1>&2
    echo "Use '--list' to display available channels." 1>&2
    return 1
  fi
}

# interface appearance
function set_ui_window_params {
  # ARGS:
  # 1: border size
  eval `resize`
  BOXWIDTH=$(( $LINES - 2 * $1 ))
  BOXHEIGHT=$(( $COLUMNS - 2 * $1 ))
  CONTENTHEIGHT=$(( $LINES - 2 * $1 - 8 ))
  TITLE="watchteleboy $VERSION"
  BUTTONLABEL=$( $record && echo "Record" || echo "Play" )
}

# channel dialog
function channel_dialog {
  while true
  do
    chanlist="$(echo "$CHANNELS" | cut -d " " -f 1) $( uname | grep "Darwin" > /dev/null && echo QUIT)"
    if $whiptail
    then
      wpsetdefault=""
      [ "$CHANNEL" != "" ] \
        && wpsetdefault="--default-item $CHANNEL" \
        || wpsetdefault=""
      unset whiptail_opts; i=0
      for i in $(echo $chanlist); 
      do 
        whiptail_opts+=("$i")
        whiptail_opts+=("Play channel $i")
      done
      set_ui_window_params 2
      CHANNEL=$(whiptail $wpsetdefault \
        --title "$TITLE" \
        --ok-button "$BUTTONLABEL" \
        --cancel-button Quit \
        --menu "Choose a channel:" \
        $BOXWIDTH $BOXHEIGHT $CONTENTHEIGHT \
        "${whiptail_opts[@]}" 3>&2 2>&1 1>&3 )
      [ "$?" != "0" ] && exit 0;
    else
      clear
      eval $(resize)
      repeat=$(( $COLUMNS - 21 ))
      echo -n "= AVAILABLE CHANNELS "
      for ch in $(seq $repeat); do echo -n "="; done
      echo -ne "\n"
      echo "" 
      PS3="
Choose a channel: "
      select CHANNEL in $chanlist
      do 
        [ "$CHANNEL" == "QUIT" ] && exit 0
        [ "$CHANNEL" != "" ] && break
      done
    fi  
    break
  done 
}

function starttime_dialog {
  while true
  do
    if $whiptail
    then
      set_ui_window_params 2
      STARTTIME=$(whiptail \
        --title "$TITLE" \
        --inputbox "\nStart recording at:" \
        $BOXWIDTH $BOXHEIGHT "$(date --rfc-3339=date) 20:15" \
        3>&2 2>&1 1>&3 )
      [ "$?" != "0" ] && exit 0;
    else
      echo -n "Start recording at: "
      read STARTTIME
    fi
    if date -d "$STARTTIME" > /dev/null 2>&1
    then
      if [ $(date -d "$STARTTIME" +%s) -lt $(date +%s) ]
      then
        if $whiptail 
        then
          whiptail --title "$TITLE" --msgbox \
            " The specified time:\n\n    ${STARTTIME}\n\nis already over." \
            $BOXWIDTH $BOXHEIGHT
        else
          echo -e "The specified time:\n    ${STARTTIME}\nis already over."  
        fi  
      else
        break
      fi
    else
      if $whiptail
      then
        whiptail --title "$TITLE" --msgbox \
          " The specified time:\n\n    ${STARTTIME}\n\ncould not be parsed." \
          $BOXWIDTH $BOXHEIGHT
      else
        echo -e "The specified time:\n    ${STARTTIME}\ncould not be parsed."
      fi
    fi
  done
}

function endtime_dialog {
  while true
  do
    if $whiptail
    then
      set_ui_window_params 2
      endtimeinit=$(( $(date -d "$STARTTIME" +%s) + 3600 ))
      ENDTIME=$(whiptail \
	--title "$TITLE" \
	--inputbox "\nStop recording at:" \
	$BOXWIDTH $BOXHEIGHT "$(date -d @${endtimeinit} '+%Y-%m-%d %H:%M')" \
	3>&2 2>&1 1>&3 )
      [ "$?" != "0" ] && exit 0;
    else
      echo -n "Stop recording at: "
      read ENDTIME
    fi
    if date -d "$ENDTIME" > /dev/null 2>&1
    then
      if [ $(date -d "$ENDTIME" +%s) -lt $(date -d "$STARTTIME" +%s) ]
      then
        if $whiptail
        then
	  whiptail --title "$TITLE" --msgbox \
	    " The specified time:\n\n    ${ENDTIME}\n\nis before start time ($STARTTIME)." \
	    $BOXWIDTH $BOXHEIGHT
         else
           echo -e "The specified time:\n    ${ENDTIME}\nis before start time ($STARTTIME)."
         fi
      else
        break
      fi
    else
      if $whiptail
      then
	whiptail --title "$TITLE" --msgbox \
	  " The specified time:\n\n    ${ENDTIME}\n\ncould not be parsed." \
	  $BOXWIDTH $BOXHEIGHT
      else
        echo -e "The specified time:\n    ${ENDTIME}\ncould not be parsed."
      fi
    fi
  done
}

function ifschedule_dialog {
  if $whiptail
  then
    set_ui_window_params 2
    answer=$(whiptail \
      --title "$TITLE" \
      --menu "What do you want to do?" \
      $BOXWIDTH $BOXHEIGHT $CONTENTHEIGHT \
      "1)" "Start recording immediately" "2)" "Schedule a recording" \
      3>&2 2>&1 1>&3 )
    [ "$?" != "0" ] && exit 0;
    [ "$answer" = "2)" ] && return 0 || return 1
  else
    clear
    echo "What do you want to do?"
    PS3="Choose action: "
    select answer in "Start recording immediately" "Schedule a recording"
    do
      [ "$answer" != "" ] && break 
    done 
    [ "$answer" = "Schedule a recording" ] && return 0 || return 1
  fi
}

function showname_dialog {
  while true
  do
    if $whiptail
    then
      set_ui_window_params 2
      shownameinit=$($showname && echo $SHOWNAME || echo $CHANNEL)
      SHOWNAME=$(whiptail \
	--title "$TITLE" \
	--inputbox "\nEnter the name of the show:" \
	$BOXWIDTH $BOXHEIGHT "$shownameinit" \
	3>&2 2>&1 1>&3 )
      [ "$?" != "0" ] && exit 0;
    else
      echo -n "Enter the name of the show: "
      read SHOWNAME
    fi
    showname=true
    [ "$SHOWNAME" = "" ] || break
  done
}

function recordpath_dialog {
  while true
  do
    if $whiptail
    then
      set_ui_window_params 2
      RECORDPATH=$(whiptail \
	--title "$TITLE" \
	--inputbox "\nSpecify a directory to save the recording:" \
	$BOXWIDTH $BOXHEIGHT "$RECORDPATH" \
	3>&2 2>&1 1>&3 )
      [ "$?" != "0" ] && exit 0;
    else
      echo "Specify a directory to save the recording"
      echo "(default: $RECORDPATH)"
      echo -n ":"
      read RECORDPATHINPUT
      [ "$RECORDPATHINPUT" != "" ] && RECORDPATH=$RECORDPATHINPUT
    fi
    if [ ! -d "$RECORDPATH" ] 
    then
      if $whiptail
      then
	whiptail --title "$TITLE" --msgbox \
	  " The specified directory:\n\n    ${RECORDPATH}\n\ndoes not exist." \
	  $BOXWIDTH $BOXHEIGHT
      else
        echo -e "The specified directory:\n    ${RECORDPATH}\ndoes not exist."
      fi
    elif [ ! -w "$RECORDPATH" ]
    then
      if $whiptail
      then
	whiptail --title "$TITLE" --msgbox \
	  " You don't have permission to write to:\n\n    ${RECORDPATH}\n\n" \
	  $BOXWIDTH $BOXHEIGHT
      else
        echo -e "You don't have permission to write to:\n    ${RECORDPATH}\n"
      fi
    else
      break
    fi
  done
}

function confirm_dialog {
  summary="Scheduled for recording:

Start time:    $(date -d "${STARTTIME}" "+%a, %F %H:%M")
End time:      $(date -d "${ENDTIME}" "+%a, %F %H:%M")
Channel:       ${CHANNEL}
Show:          ${SHOWNAME}
Directory:     ${RECORDPATH}

Are those settings correct?"
  if $whiptail
  then
    set_ui_window_params 2
    answer=$(whiptail --title "$TITLE" --yesno \
      "$summary" $BOXWIDTH $BOXHEIGHT 3>&2 2>&1 1>&3 )
 else
   echo -n "$summary (Y/n): "
   read answerinput
   answer=$([ "$answerinput" == "y" ] || [ "$answerinput" == "" ] && echo 0 || echo 1)
 fi
 echo "ANSWER IS $answer"
 return $answer
}

# record option check
function require_r_opt {
  # ARGS:
  # 1: option name
  if $record
  then
    return 0
  else
    echo "The option '--${1}' requires the '--record' option" 1>&2
    exit 1
  fi
}

# schedule a recording into crontab
crontempfile="${TMPPATH}/crontab.tmp"
function write_to_crontab {
  # when using this function make sure that
  # the necessary vars are set
  # mandatory: CHANNEL, STARTTIME, DURATION
  DELETEME=${RANDOM}${RANDOM}
  crontab -l > /dev/null 2>&1 && crontab -l > $crontempfile || touch $crontempfile
  echo -ne "$(date -d "$STARTTIME" +"%M %H %d %m") *\t$(basename ${0}) --record " >> $crontempfile
  echo -ne "--quiet --channel ${CHANNEL} --duration ${DURATION} " >> $crontempfile
  echo -ne "--deleteme ${DELETEME} " >> $crontempfile
  $showname && echo -ne "--showname \"${SHOWNAME}\" " >> $crontempfile
  echo -ne "--path ${RECORDPATH}\n" >> $crontempfile
  crontab < $crontempfile
  rm $crontempfile
}

# option -t|--starttime
if $starttime
then
  require_r_opt "starttime"
  if $endtime || $duration
  then
    check_time_validity "$STARTTIME"
    starttimeepoch=$(date -d "$STARTTIME" +%s)
    if [ $starttimeepoch -lt $(date +%s) ]
    then
      echo "The specified start time is already over." 1>&2
      exit 1
    fi
    if $endtime
    then
      check_time_validity "$ENDTIME"
      endtimeepoch=$(date -d "$ENDTIME" +%s)
      if [ $endtimeepoch -lt $starttimeepoch ]
      then
        echo "The specified end time is before the start time." 1>&2
        exit 1
      fi
      let DURATION=$endtimeepoch-$starttimeepoch
    elif $duration
    then
      if ! [ "$DURATION" -ge 0 ] 2>&-
      then
        echo "The specified duration '$DURATION' is not a number." 1>&2
        exit 1
      fi
    fi
    if $channel
    then
      channel_validity $CHANNEL || exit 1
    else
      echo "You need to specify a channel with '--channel'" 1>&2
      exit 1
    fi
    # Now we have validated all required parameters
    if ! $quiet
    then
      echo "Scheduled for recording:"
      echo -e "Start time:\t$(date -d "$STARTTIME" "+%a, %F %H:%M")"
      $endtime && echo -e "End time:\t$(date -d "$ENDTIME" "+%a, %F %H:%M")"
      $duration && echo -e "Duration:\t${DURATION} sec"
      echo -e "Channel:\t$CHANNEL"
      echo -e "Directory:\t$RECORDPATH"
      $showname && echo -e "Show:\t\t$SHOWNAME"
      read -p "Are those settings correct? (Y/n) "
      if [ "$REPLY" == "n" ]
      then
        echo "Cancelled by user. Quit." 1>&2
        exit 1
      fi
    fi 
    write_to_crontab
    $quiet || echo "Done."
    exit 0
  else 
    echo "You must specify either --duration or --endtime" 1>&2
    exit 1
  fi
fi

# option --deleteme
if $deleteme
then
  crontab -l > $crontempfile
  sed -i "/$DELETEME/ d" $crontempfile
  crontab < $crontempfile
  rm $crontempfile
fi

# Compose mplayer command
MPLAYER="mplayer $MPLAYEROPTS "

# Compose rmtpdump output filename
function compose_outfile {
  # ARGS:
  # 1: Channel
  if $record
  then
    if $showname
    then
      OUTFILE="${RECORDPATH}/${SHOWNAME}-$(date +%Y%m%d%H%M).flv"
    else
      OUTFILE="${RECORDPATH}/${1}-$(date +%Y%m%d%H%M).flv"
    fi
  else
    OUTFILE="$TMPPATH/stream.flv"
  fi
} 

function player_recorder {
  # ARGS:
  # 1: Channel
  compose_outfile $1
  if $record
  then
    dump_rtmp_stream $1 "$OUTFILE"
  else
    # Make sure there is an empty OUTFILE 
    > "$OUTFILE"
    dump_rtmp_stream $1 "$OUTFILE" 
    # Only start mplayer after having downloaded BUFFER bytes
    while [  "$(( $(du -sk "$OUTFILE" | cut -f1) * 1024 ))" -lt "$BUFFER" ]
    do
      sleep 0.1
    done
#    $MPLAYER $TMPPATH/stream.flv 2> /dev/null
#zzz
    vlc $TMPPATH/stream.flv 2> /dev/null
    kill $PID
  fi
}

# Da Keestroke Waitah
function  wait_s_key {
  $quiet || echo "Press the 's' key to stop the recording." 
  keypress=""
  while [ "$keypress" != "s" ]
  do
    read -s -n1  keypress
  done
}

# option -e|--endtime
if $endtime && ! $duration
then
  require_r_opt "endtime"
  check_time_validity "$ENDTIME"
  endtimeepoch=$(date -d "$ENDTIME" +%s)
  nowepoch=$(date +%s)
  if [ $endtimeepoch -lt $nowepoch ]
  then
    echo "The specified end time is already over." 1>&2
    exit 1
  fi
  let DURATION=${endtimeepoch}-${nowepoch}
  duration=true
fi

# option -d|--duration
if $duration
then
  require_r_opt "duration"
  if ! [ "$DURATION" -ge 0 ] 2>&-
  then
    echo "The specified duration '$DURATION' is not a number." 1>&2
    exit 1
  fi
  channel_validity $CHANNEL || exit 1
  player_recorder $CHANNEL
  $quiet || echo "Now recording $CHANNEL for $DURATION seconds."
  sleep $DURATION
  kill $PID
  $quiet || echo "Stopped recording."
  exit 0
fi

# option -c|--channel
if $channel
then
  if channel_validity $CHANNEL
  then
    if $record
    then
      $quiet || echo -n "Now recording: "
      player_recorder $CHANNEL
      wait_s_key
      kill $PID
      $quiet || echo "Stopped recording."
      exit 0
    else
      $quiet || echo -n "Now playing: "
      player_recorder $CHANNEL
    fi
    exit 0
  else
    echo "Channel '$CHANNEL' is not available..." 1>&2
    exit 1
  fi
fi

# Loop for interactive mode
while true
do
  if $record
  then
    if ifschedule_dialog
    then
      while true
      do
        channel_dialog
        starttime_dialog
        endtime_dialog
        showname_dialog
        recordpath_dialog
        confirm_dialog && break
      done
      DURATION=$(( $(date -d "$ENDTIME" +%s) - $(date -d "$STARTTIME" +%s) ))
      write_to_crontab
      set_ui_window_params 2
      whiptail --title "$TITLE" --msgbox \
        " Successfully added crontab entry:\n\n
$(crontab -l | grep $DELETEME)" \
        $BOXWIDTH $BOXHEIGHT
      exit 0
    else
      channel_dialog
      player_recorder $CHANNEL
      $quiet || echo -n "Now recording: "
      wait_s_key
      kill $PID
      $quiet || echo "Stopped recording."
      exit 0
    fi
  else
    channel_dialog
    $quiet || echo -n "Now playing: "
    player_recorder $CHANNEL
  fi
done

exit 0

