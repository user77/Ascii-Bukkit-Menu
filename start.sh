#!/bin/bash

# Read Config File
source include/config

# If Config has not beed edited, then exit.
if [[ -z $bukkitdir ]]; then
	echo "Plese Edit include/config"
	exit 0
else
	# Start the screen sessions.
	screen -c include/screen.conf
fi