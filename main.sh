#!/bin/bash
# alex thorne 07/12/2016
# logic for some sort of logging/callback for personal terminal session use

# return last line from bash_history
showlast() {
      fc -ln "$1" "$1" | sed '1s/^[[:space:]]*//'
    }

# append last line from bash_history to log file
showlast >> /home/thorale/workspace/fkin-howdoi/LOGBOOK.md



