#!/bin/bash
abmdir=
functions="$abmdir/include/scripts/functions.sh"
vars="$abmdir/include/config/vars"
abmconfig="$abmdir/include/config/abm.conf"

source $functions
source $vars
source $abmconfig

# Menu Structure.
showMenu () {
        echo "1:$txtgrn Start"$txtrst
        echo "2:$txtred Stop"$txtrst
        echo "3:$txtylw Restart"$txtrst
	echo "4:$txtwht Send Server Command"$txtrst
	echo "5:$txtwht Update Bukkit"$txtrst
	  if [[ ! -f "$bukkitdir/plugins/Minequery.jar" ]]; then
	    echo "6:$txtwht Install Minequery"$txtrst
	    echo "    -Adds Functionality"
	    echo "    -Will Restart Bukkit"
	  fi
	echo " "
        echo "0:$txtred Quit ABM"$txtrst
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
			echo "Starting Server.."
			startServer	
			sleep 1
			;;

		"2")
			echo "Stopping Server.."
            		stopServer 
			;;

		"3")
			echo "Restarting Server.."
			restartServer
			;;
		"4")
			serverCommands
			;;
		"5")
			update
			;;
		"6")
			installmq
			;;
		"0")
			quitFunction
                        ;;
		"q")	
			quitFunction
			;;
                *) echo "\"$CHOICE\" is not valid "; sleep 2 ;;
        esac
done
