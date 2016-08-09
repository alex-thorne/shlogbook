#!/bin/bash
# 07/12/2016 github.com/alex-thorne
# simple logging utility for interactive shell sessions 
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)
default_config() {
  logbook="${HOME}/.shlogbook"
  myhost=$(hostname)
}

_day="$(date +%F)"
_daytime="$(date +%T)"
TIMESTAMP="$_day at $_daytime" #TODO i'm sure there's a better way to do this.

#resolve shlogbook home
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do 
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" 
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

config="$DIR/.config"
if [[ -e "$config" ]]; then
  source $config
else 
  default_config
fi

#TODO improve history file resolution
if [[ ${SHELL} == *"zsh"* ]]; then
  hist_file="${HOME}/.zsh_history"
elif [[ ${SHELL} == *"bash"* ]]; then
  hist_file="${HOME}/.bash_history"
else
  echo "error reading \$HISTFILE please configure history file"
  exit -1
fi

## main ##
main() {
  lst_cmd=$(tail -n2 $hist_file|head -n1|sed -n -e 's/^.*;//p')
  if [[ log_with_message -eq 1 ]]; then
    read log_message
    if [[ -z "${log_message// }" ]]; then 
      echo "Aborting shlogging due to empty message."
      exit -1
    fi
  fi
  if [[ verbose_log -eq 1 ]]; then
    verbose_entry="$(date) $USER $myhost $SESSION $SHELL" 
    echo "\n--- $verbose_entry ---">>$logbook
  else
    echo -e "\n----- $TIMESTAMP -----">>"$logbook"
  fi	
  echo -e "\n$lst_cmd">>"$logbook"
  if [[ $log_with_message -eq 1 ]]; then
    echo -e "\n$log_message">>"$logbook"
  fi
  if [[ verbose_out -eq 1 ]]; then
    if [[ verbose_log -eq 1 ]]; then
      echo -e "\n$verbose_log"
    fi		
    echo -e "\n$lst_cmd!"
    if [[ $log_with_message -eq 1 ]]; then
      echo -e "\n$log_with_message"     
    fi
    echo -e "\n${GREEN}added to shlogbook!${NORMAL}"
  fi	
  exit 0
}
## end main ##

## shlogbook accepts arguments! ##
OPTIND=1 

verbose_out=0
verbose_log=0
test_run=0
log_with_message=0

while getopts "h?vf:" opt; do
  case "$opt" in
    h|\?)
      show_help
      exit 0
      ;;
    v)  verbose_out=1
      ;;
    V)  verbose_log=1
      ;;
    t)  test_run=1
      ;;
    m)  log_message=$OPTARG    
      log_with_message=1
      ;;
  esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

main
