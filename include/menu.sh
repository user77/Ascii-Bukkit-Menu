#!/bin/bash
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

menuscreenpid=`screen -ls |grep bukkitmenu |cut -f 1 -d .`

checkServer () {
MCPID=`ps -ef |grep -i craftbukkit-0.0.1-SNAPSHOT.jar |grep -v grep |awk '{ print $2 }'`
}

update () {
stopServer
sleep 2
wget -m -nd --progress=dot:mega -P $bukkitdir http://ci.bukkit.org/job/dev-CraftBukkit/promotion/latest/Recommended/artifact/target/craftbukkit-0.0.1-SNAPSHOT.jar
cat /dev/null > $bukkitdir/server.log
startServer
}

startServer () {
clear
checkServer
serverscreenpid=`screen -ls |grep bukkit-server |cut -f 1 -d .`
 if [ -z $MCPID ]; then
	cd $bukkitdir
	  if [ -z $serverscreenpid ]; then 	
	   screen -d -m -S bukkit-server 
	   screen -S bukkit-server -p 0 -X exec java -Xincgc -Xmx2G -jar $bukkitdir/craftbukkit-0.0.1-SNAPSHOT.jar
	  else		
	   screen -S bukkit-server -p 0 -X exec java -Xincgc -Xmx2G -jar $bukkitdir/craftbukkit-0.0.1-SNAPSHOT.jar
	  fi
	cd -
elif [ -n $MCPID ]; then
	echo -e "Server Already Running.."
	sleep 1 
fi
}

stopServer () {
checkServer
if [ -z $MCPID ]; then
clear
echo "Bukkit Not Running.."
sleep 1
else 
screen -S bukkitmenu -p 1 -X stuff "stop"
screen -S bukkit-server -p 0 -X quit
fi
}

showMenu () {
        echo "1:$txtgrn Start"$txtrst
        echo "2:$txtred Stop"$txtrst
        echo "3:$txtylw Restart"$txtrst
	echo "4:$txtwht Clear Log Window"$txtrst
	echo "5:$txtwht Update Bukkit to Latest"$txtrst
	echo
        echo "q:$txtred Quit Bukkit Menu"$txtrst
}

while [ 1 ]
do
	clear
	showMenu
	echo
	echo -e "Enter Choice: \c"	
	read CHOICE
	case "$CHOICE" in
		"1")    clear
			echo "Starting Server.."
			startServer	
			sleep 1
			;;

		"2")	clear	
			echo "Stopping Server.."
                        stopServer 
			sleep 1
			;;

		"3")	clear	
			echo "Restarting Server.."
			stopServer
			sleep 1
			startServer
			;;

		"4")	screen -S bukkitmenu -p 1 -X exec "clear"
			;;

		"5")	clear	
			update
			;;

		"q")	clear
			echo "Bye"
         		$txtrst
			clear
			screen -d -S bukkit-server
			kill $menuscreenpid		
			exit
			;;
		*) echo "\"$CHOICE\" is not valid "; sleep 2 ;;
	esac
done
