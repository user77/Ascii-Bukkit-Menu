#!/bin/bash

# Read Config File
source include/config

# Text color variables
txtund=$(tput sgr 0 1)    # Underline
txtbld=$(tput bold)       # Bold
txtred=$(tput setaf 1)    # Red
txtgrn=$(tput setaf 2)    # Green
txtylw=$(tput setaf 3)    # Yellow
txtblu=$(tput setaf 4)    # Blue
txtpur=$(tput setaf 5)    # Purple
txtcyn=$(tput setaf 6)    # Cyan
txtwht=$(tput setaf 7)    # White
txtrst=$(tput sgr0)       # Text reset

# Find PID of the screen session for the menu.
menuscreenpid=`screen -ls |grep bukkitmenu |cut -f 1 -d .`

# Find PID of Bukkit Server.
checkServer () {
	MCPID=`ps -ef |grep -i craftbukkit-0.0.1-SNAPSHOT.jar |grep -v grep |awk '{ print $2 }'`
}

# Update Bukkit to Latest Recommended.
update () {
	stopServer
	# Download Latest, overwrite existing.
	wget -m -nd --progress=dot:mega -P $bukkitdir http://ci.bukkit.org/job/dev-CraftBukkit/promotion/latest/Recommended/artifact/target/craftbukkit-0.0.1-SNAPSHOT.jar
	cat /dev/null > $bukkitdir/server.log
	startServer
}

# Install MineQuery Plugin. Restart Server.
installmq () {
	clear
	wget -m -nd --progress=dot:mega -P $bukkitdir/plugins https://github.com/downloads/vexsoftware/minequery/Minequery-1.5.zip
	unzip -o $bukkitdir/plugins/Minequery-1.5.zip -d $bukkitdir/plugins/
	rm $bukkitdir/plugins/Minequery-1.5.zip
	stopServer
	startServer
}

# Start Bukkit Server
startServer () {
	clear
	checkServer
	if [ $ramdisk = true ]; then
		for x in ${worlds[*]}
		  do
		 [ "$(ls -A $bukkitdir/$x-offline/)" ] && cp -rf "$bukkitdir/$x-offline/"* "$bukkitdir/$x/"  
		  done
	fi
	# Need to recheck for screen PID for bukket-server session. In case it has been stopped.
	serverscreenpid=`screen -ls |grep bukkit-server |cut -f 1 -d .`
	if [[ -z $MCPID ]]; then
		cd $bukkitdir
		if [[ -z $serverscreenpid ]]; then
			screen -d -m -S bukkit-server
		fi
		screen -S bukkit-server -p 0 -X exec java $jargs -jar $bukkitdir/craftbukkit-0.0.1-SNAPSHOT.jar nogui
		cd -
	elif [[ $MCPID ]]; then
			echo -e "Server Already Running.."
			sleep 1
	fi
}

# Stop Bukkit Server
stopServer () {
	checkServer
	if [[ -z $MCPID ]]; then
		clear
		echo "Bukkit Not Running.."
		sleep 1
	else
		screen -S bukkit-server -p 0 -X eval 'stuff "stop"\015'
		while [[ $MCPID ]]; do
			echo "Bukkit Shutdown in Progress.."
			checkServer
      		clear
		done
                if [ $ramdisk = true ]; then
                  for x in ${worlds[*]}
                    do
                      cp -rf "$bukkitdir/$x/"* "$bukkitdir/$x-offline/"
                    done
                fi
		screen -S bukkit-server -X quit
	fi
}

# Menu Structure.
showMenu () {
        echo "1:$txtgrn Start"$txtrst
        echo "2:$txtred Stop"$txtrst
        echo "3:$txtylw Restart"$txtrst
		echo "4:$txtwht Update Bukkit to Latest"$txtrst
		if [[ ! -f "$bukkitdir/plugins/Minequery.jar" ]]; then
			echo "5:$txtwht Install Minequery"$txtrst
			echo "    -Adds Functionality"
			echo "    -Will Restart Bukkit"
		fi
		echo
        echo "q:$txtred Quit Bukkit Menu"$txtrst
}

# Display Menu and wait for choice.
while [ 1 ]
do
	clear
	showMenu
	echo
	echo -e "Enter Choice: \c"	
	read CHOICE
	case "$CHOICE" in
		"1")
			clear
			echo "Starting Server.."
			startServer	
			sleep 1
			;;

		"2")
			clear	
			echo "Stopping Server.."
            stopServer 
			;;

		"3")
			clear	
			echo "Restarting Server.."
			stopServer
			startServer
			;;

		"4")	
			clear	
			update
			;;

		"5")    
			installmq  #install MineQuery Plugin
			clear
			;;

		"q")
			clear
			echo "Bye"
         	$txtrst
			clear
			screen -d -S bukkit-server
			kill $menuscreenpid		
			exit 0
			;;
		*) echo "\"$CHOICE\" is not valid "; sleep 2 ;;
	esac
done
