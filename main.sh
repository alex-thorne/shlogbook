#!/bin/bash
# alex thorne 07/12/2016
# simple logging utility for interactive shell sessions 

BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NORMAL=$(tput sgr0) 

_day="$(date +%F)"
_daytime="$(date +%T)"
TIMESTAMP="$_day at $_daytime"

#resolve shlogbook home dir
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do 
  TARGET="$(readlink "$SOURCE")"
  if [[ $TARGET == /* ]]; then 
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    SOURCE="$DIR/$TARGET" 
  fi
done

#TODO - check config on run!
#config="$DIR/.config"
#if [ -e "$config" ]; then
#  source $config
#else 
#  default_config
#fi
#
#default_config() {
#  #TODO
#}

# optional --message param, to allow logging with reference message
# TODO this should be done by parsing cl args, this solution is lazy and naive, see
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
msg=${2}

#TODO this should write to tmp file:
get_last() {
  lastcommand=$(fc -lnr -1 | sed '1s/^[[:space:]]*//')
  #write to temp file!
}

#TODO should be pulled from tmp file!
display_last() {
  echo "$lastcommand"
}

log_last() {
  if [ ! -z "$lastcommand" ]; then 
#    echo -e "$lastcommand added to $logbook" && echo "$lastcommand">>"$logbook"
  elif [ -z "$lastcommand" ]; then
    lastcommand=$(fc -lnr -1 | sed '1s/^[[:space:]]*//')
#    echo -e "$lastcommand added to $logbook" && echo "$lastcommand">>"$logbook"
  else
    echo -e "${RED}error logging command!${NORMAL}"
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
  if [ -z "$commit_message" -a "$commit_message" = " " ]; then
  echo -e "\n$commit_message">>"$logbook"
  echo -e "\n${GREEN}$lastcommand logged!${NORMAL}"
  logbook=""
  commit_message=""
}


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
    -c|--config)
      CONFFILE="$1"
      shift
      if [ ! -f $CONFFILE ]; then
        echo "Error reading config file"
        exit $E_CONFIG  # Error loading config 
      fi
      ;;
  esac
  shift       # Check next set of parameters.
done

case $1 in
  get)
    getlast
    ;;
  log)
    loglast
    ;;
  *)
    echo -e "Usage: {${GREEN}get${NORMAL}|${YELLOW}log${NORMAL}."
    ;;
esac
exit 0
