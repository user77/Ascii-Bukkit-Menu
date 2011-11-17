#!/bin/bash

# Read Config File
source include/config
cols=`tput cols`
lines=`tput lines`
# Check for Logrotate config
if [ ! -d "$bukkitdir/logs" ]; then
mkdir $bukkitdir/logs
fi

cat > "include/rotate.conf" <<EOF
"$bukkitdir/server.log" {
copytruncate
rotate 20
compress
olddir $bukkitdir/logs/
}
EOF

# If Config has not beed edited, then exit.
if [[ -z $bukkitdir ]]; then
	echo "Plese Edit include/config"
	exit 0
else
	if [ $ramdisk = true ]; then
	for x in ${worlds[*]}
	  do
            [ -d "$bukkitdir/$x-offline" ] || mkdir "$bukkitdir/$x-offline"
	  done
	fi
	# If screen size too small, adjust. 
	if [[ $cols -lt 120 || $lines -lt 42 ]]; then
		printf '\033[8;42;120t'
		sleep 0.5 
	fi
	# Start the screen sessions.

clear
echo
echo "                   _ _   ____        _    _    _ _     __  __                  "
echo "    /\            (_|_) |  _ \      | |  | |  (_) |   |  \/  |                 "
echo "   /  \   ___  ___ _ _  | |_) |_   _| | _| | ___| |_  | \  / | ___ _ __  _   _ "
echo "  / /\ \ / __|/ __| | | |  _ <| | | | |/ / |/ / | __| | |\/| |/ _ \ '_ \| | | |"
echo " / ____ \\\\__ \ (__| | | | |_) | |_| |   <|   <| | |_  | |  | |  __/ | | | |_| |"
echo "/_/    \_\___/\___|_|_| |____/ \__,_|_|\_\_|\_\_|\__| |_|  |_|\___|_| |_|\__,_|"
echo "                                                                               "
echo
sleep 0.5 
clear

	screen -c include/screen.conf
fi
