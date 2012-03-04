#!/bin/bash
abmdir=
functions="$abmdir/include/scripts/functions.sh"
vars="$abmdir/include/config/vars"
abmconfig="$abmdir/include/config/abm.conf"

source $functions
source $vars
source $abmconfig

# Put somthing into log window so its not empty.

# Watch Bukkit Log in screen window Bukkit_Log
if [ ! -f "$slog" ]; then
	touch "$slog"
	echo "Server log not found, creating one.." >> "$slog"
	tail -f "$slog"
else
tail -f "$slog"
fi