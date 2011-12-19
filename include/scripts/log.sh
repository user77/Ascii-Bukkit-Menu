#!/bin/bash
abmdir=
functions="$abmdir/include/scripts/functions.sh"
vars="$abmdir/include/config/vars"
abmconfig="$abmdir/include/config/abm.conf"

source $functions
source $vars
source $abmconfig

# Put somthing into log window so its not empty.
head -10 $bukkitdir/server.log

# Watch Bukkit Log in screen window Bukkit_Log
tail -f $bukkitdir/server.log
