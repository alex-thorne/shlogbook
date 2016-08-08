#!/bin/bash
# alex thorne 07/12/2016
# simple logging utility for interactive shell sessions 

BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NORMAL=$(tput sgr0) 

default_config() {
  logbook="${HOME}/.shlogbook"
}

_day="$(date +%F)"
_daytime="$(date +%T)"
TIMESTAMP="$_day at $_daytime" #TODO there must be a better way...

#resolve shlogbook home
shlog_path="${BASH_SOURCE[0]}"
while [ -h "$shlog_path" ]; do 
  TARGET="$(readlink "$shlog_path")"
  if [[ $TARGET == /* ]]; then 
    shlog_path="$TARGET"
  else
    shlog_home="$( shlog_homename "$shlog_path" )"
    shlog_path="$shlog_home/$TARGET" 
  fi
done


echo "$shlog_home" 




config="$shlog_home/.config"

if [ -e "$config" ]; then
  source $config
else 
  default_config
fi



## main ##

get_last() {
  lastcommand=$(fc -lnr -1 | sed '1s/^[[:space:]]*//')|mktemp /tmp/sb.lastcommand.XXXXX
  echo "$lastcommand" 
  #TODO DEBUG - remove echo 
}

display_last() {
  echo "$lastcommand"
}

log_last() {
  if [ -z "$lastcommand" ]; then
    lastcommand=$(fc -lnr -1 | sed '1s/^[[:space:]]*//')|mktemp /tmp/sb.lastcommand.XXXXX
  else
    echo -e "${RED}err getting last command!${NORMAL}"
    exit -1
  fi
  if [ $2 -eq 1 ]; then
    read commit_message
    if [ -z "$commit_message" -a "$commit_message" = " " ]; then
      echo "<msg> missing or not well-formed, invoke without --message -m for no <msg>"
      exit -1
    fi
  fi
  echo -e "\n----- $TIMESTAMP -----">>"$logbook"
  echo -e "\n$lastcommand">>"$logbook"
  if [ $2 -eq 1 ]; then
    echo -e "\n$commit_message">>"$logbook"
  fi
  echo -e "\n$lastcommand! ${GREEN}added to shlogbook!${NORMAL}"
  exit 0
}

## end main ##

## shlogbook accepts arguments! ##
while [ $# -gt 0 ]; do
  case "$1" in
    -g|--display)
      display_last=1
      ;;
    -l|--log)
      log_last=1
      ;;
    -m|--message)
      commit_message=1
      ;;
    -c|--config) #TODO allow for in-line shlogbook config 
      CONFFILE="$1"
      shift
      if [ ! -f $CONFFILE ]; then
        echo "${RED}Error reading shlogbook config file${NORMAL}"
        exit -1  # TODO error handling
      fi
      ;;
  esac
  shift  # Check next set of parameters.
done

exit 0
