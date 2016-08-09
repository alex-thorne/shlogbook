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
  myhost=$(hostname)
}

_day="$(date +%F)"
_daytime="$(date +%T)"
TIMESTAMP="$_day at $_daytime" #TODO there must be a better way...
VERBOSE_STAMP=""

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
  echo "please configure history file"
  exit -1
fi

## main ##

get_last() {
  lst_cmd=$(tail -n2 $hist_file | head -n1)
  #lst_cmd=$(fc -lnr -1|sed '1s/^[[:space:]]*//'|mktemp /tmp/sb.lastcommand.XXX)
}

main() {
  lst_cmd=$(tail -n2 $hist_file | head -n1)
 	echo -e "\n\n\n $lst_cmd \n\n\n"
  if [[ commit_message -eq 1 ]]; then
    read cmmt_msg
    if [[ -z "$cmmt_msg" ]]; then #FIXME this still allows for blank ie " " message?
      echo "<msg> missing or misformed, use without -m|--message to skip"
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
  if [[ $commit_message -eq 1 ]]; then
    echo -e "\n$cmmt_msg">>"$logbook"
  fi
  if [[ verbose_out -eq 1 ]]; then
    if [[ verbose_log -eq 1 ]]; then
      echo -e "\n$verbose_log"
    fi		
    echo -e "\n$lst_cmd! \n${GREEN}added to shlogbook!${NORMAL}"
  fi	
  exit 0
}

## end main ##

## shlogbook accepts arguments! ##
#TODO alphabetize and document
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose)
      verbose_out=1 #Generously shows user an output
      shift
      ;;
    -r|--range)  #TODO (support selection from fc -lnr -(>1)items)
      shift
      ;;
    -t|--test) #TODO runs 'dry-run' with option to log after displaying output
      dry_run=1
      shift
      ;;
    -m|--message)
      commit_message=1
      shift
      ;;
    -V|--verbose-logging)
      verbose_log=1 #Generously shows user an output
      ;;
    -c|--config) #TODO allow for in-line shlogbook config 
      CONFFILE="$1"
      shift
      if [[ ! -f $CONFFILE ]]; then
        echo "${RED}Error reading shlogbook config file${NORMAL}"
        exit -1  # TODO error handling
      fi
      ;;
    -h|--help)
      cat "$DIR/help.txt"
      ;;
    --default) # End of all options
      shift
      ;;
    -*)
      echo "Error: Unknown option: $1" >&2
      exit 1
      ;;
    *)
      echo -e "Invalid option ("shlogbook --help" for help)"
      exit 0
      ;;
  esac
  shift  # Check next set of parameters.
done

main
