#!/bin/bash
abmdir=
functions="$abmdir/include/scripts/functions.sh"
vars="$abmdir/include/config/vars"
abmconfig="$abmdir/include/config/abm.conf"

source $functions
source $vars
source $abmconfig

# Trap ctrl+c and do cleanup.
trap ctrl_c INT

#Check for update daily on first startup
checkUpdate
banner

# Loop and display status information
while [[ true ]]; do
  showInfo
  # Set screen refresh variable in include/conf
  sleep $tick
done
