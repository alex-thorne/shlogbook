#!/bin/bash
# 07/12/2016 github.com/alex-thorne
# simple logging utility for interactive shell sessions 

#TODO: 
# add 'undo' option that searches until the last [date] entry and removes
# add 'dry-run' option that stages and displays your log entry and logs on confirmation
# fix horrible main() so that output is staged in /dev/null or temp file and added together to logfile

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do 
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" 
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

show_help() {
  cat $DIR/.help.txt 
}

default_config() {
  logbook="${HOME}/.shlogbook"
  myhost=$(hostname)
}

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
  lst_cmd=$(tail -n2 $hist_file|head -n1|sed -n -e 's/^[^;]*;//p')
  if [[ log_with_message -eq 1 ]]; then
    if [[ -z "${log_message// }" ]]; then 
      echo "Aborting shlogging due to empty message."
      exit -1
    fi
  fi
  if [[ detailed_logging -eq 1 ]]; then
    verbose_entry="$(date) $USER $myhost $SESSION $SHELL" 
    echo -e "\n[ $verbose_entry ]">>$logbook
  else
    echo -e "\n[ $(date +%F\ %T) ]">>"$logbook"
  fi	
  if [[ $log_with_message -eq 1 ]]; then
    echo -e "$log_message">>"$logbook"
  fi
  echo -e "\n   $ $lst_cmd">>"$logbook"
  if [[ verbose -eq 1 ]]; then
    if [[ detailed_logging -eq 1 ]]; then
      echo -e "[ $verbose_entry ]"
    fi		
    if [[ $log_with_message -eq 1 ]]; then
      echo -e "$log_message"     
    fi
    echo -e "   $ $lst_cmd!"
  fi	
  exit 0
}

search() {
  awk '/'$search_param'/{i=1;}/^\s*$/ {next;}{if(i){i--; print;}}' $logbook
}

OPTIND=1 
verbose=0
detailed_logging=0
test_run=0
log_with_message=0

  while getopts "h?s:vdtm:" opt; do
  case "$opt" in
    h|\?)
      show_help
      exit 0
      ;;
    s)  search_param=$OPTARG 
      search
      exit 0
      ;;
    v)  verbose=1
      ;;
    d)  detailed_logging=1
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
