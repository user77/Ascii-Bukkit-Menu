#!/bin/bash
dir="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
abmdir=
abmid=$$
export abmid=$abmid
clear
if [ -z $abmdir ]; then
	echo "ABM First Run."
	echo "Please enter the path where ABM is installed to."
	echo "For example it may be $dir"
	read -p "Path: " path
	sed -i '3s#'abmdir='[^ ]*''#'abmdir="$path"'#g' abm.sh
	sed -i '2s#'abmdir='[^ ]*''#'abmdir=$path'#g' $path/include/scripts/log.sh
	sed -i '2s#'abmdir='[^ ]*''#'abmdir=$path'#g' $path/include/scripts/menu.sh
	sed -i '2s#'abmdir='[^ ]*''#'abmdir=$path'#g' $path/include/scripts/status.sh
	sed -i '3s#'abmdir='[^ ]*''#'abmdir=$path'#g' $path/include/scripts/functions.sh
	sed -i '2s#'abmdir='[^ ]*''#'abmdir=$path'#g' $path/include/config/vars
	abmdir=$path
fi

functions="$abmdir/include/scripts/functions.sh"
vars="$abmdir/include/config/vars"
abmconfig="$abmdir/include/config/abm.conf"
TERM=xterm
source $functions
source $vars

if [[ ! -f $abmconfig ]]; then
	   echo
       echo "ABM configuration incomplete or missing."
        read -p "Would you like to create one now? [y/n]: " answer
	case $answer in
	  [yY] | [yY][eE][Ss] )
            setupConfig
	    ;;
	  [nN] | [nN][oO] )
            echo "Please edit config manually $abmconfig"
            exit 0
	    ;;
	*) echo "Invalid Input"
	   ;;
	esac
fi

source $abmconfig

# If Config has not been edited, then exit.
if [[ -z $bukkitdir ]]; then
	echo "ABM configuration incomplete or missing."
        read -p "Would you like to create one now? [y/n]: " answer
        case $answer in
          [yY] | [yY][eE][Ss] )    
	    setupConfig
	    ;;
	  [nN] | [nN][oO] )
            echo "Please edit config manually $abmconfig"
	    exit 0
	    ;;
          *) echo "Invalid Input"
	    ;;
	esac

else
	if [ $ramdisk = true ]; then
	for x in ${worlds[*]}
	  do
            [ -d "$bukkitdir/$x-offline" ] || mkdir "$bukkitdir/$x-offline"
	  done
	fi
	# If screen size too small, adjust. 
	if [[ $cols -lt 120 || $lines -lt 50 ]]; then
		printf '\033[8;50;120t'
		sleep 0.5 
fi

if [[ $1 = "--start" ]]; then
	startServer
	exit 0
elif [[ $1 = "--stop" ]]; then
	export silent=$1
	stopServer
	exit 0
fi

manybukkits=`ls $bukkitdir/craftbukkit*.jar|wc -l`
if [[ $manybukkits > 1 ]]; then
	echo "You appear to have multiple copies of a craftbukkit*.jar"
	echo "in you CraftBukkit directory. This may cause unexpected"
	echo "results with ABM."
	echo
	ls -lah $bukkitdir/craftbukkit*.jar
	echo
	read -p "Would you like to continue? [y/n] " proceed
	if [[ $proceed =~ ^(no|n|N)$ ]]; then
		exit 0
	fi
fi
	
	# Start the screen sessions.
	createLogrotate
	createLogsdir
	createUpdate
	screenConf
	javaCheck
	screen -c $screenconf
fi
clear
exit 0
cd -
