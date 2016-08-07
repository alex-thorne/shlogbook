#!/bin/bash
# alex thorne 07/12/2016
# simple logging utility for interactive shell sessions 

BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NORMAL=$(tput sgr0) 
SOURCE="${BASH_SOURCE[0]}"

#resolve schlogbook path, considers symlinks
while [ -h "$SOURCE" ]; do 
  TARGET="$(readlink "$SOURCE")"
  if [[ $TARGET == /* ]]; then 
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    SOURCE="$DIR/$TARGET" 
  fi
done

config="$DIR/.config"
if [ -e "$config" ]; then
  source $config
else 
  default_config
fi

default_config() {
  #TODO
}

# TODO this should be done by parsing cl args, this solution is lazy and naive, see
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
msg=${2}


_last() {
  lastcommand=$(fc -lnr -1 | sed '1s/^[[:space:]]*//')
  #echo "${lastcommand}"
}

loglast() {
  if [ ! -z "$lastcommand" ]; then 
    echo -e "$lastcommand added to $logbook" && echo "$lastcommand">>"$logbook"
  elif [ -z "$lastcommand" ]; then
    lastcommand=$(fc -lnr -1 | sed '1s/^[[:space:]]*//')
    echo -e "$lastcommand added to $logbook" && echo "$lastcommand">>"$logbook"
  else
    echo -e "error"
  fi 
  logbook=""
}

case $1 in
  setup)
    push
    ;;
  todo)
    pull
    ;;
  *)
    echo -e "Usage: vimrc.sh {${GREEN}push${NORMAL}|${YELLOW}pull${NORMAL}."
    ;;
esac
exit 0
