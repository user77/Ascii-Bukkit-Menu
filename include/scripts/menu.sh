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

# Menu Structure.
showMainMenu () {
    echo "1:$txtgrn Start"$txtrst
    echo "2:$txtred Stop"$txtrst
    echo "3:$txtylw Restart"$txtrst
	echo "4:$txtwht Send Server Command"$txtrst
	echo "5:$txtwht Say"$txtrst
	echo "9:$txtwht Advanced"$txtrst
	echo
	echo "0:$txtred Quit ABM"$txtrst
}

advancedMenu () {
while [ 1 ]
  do
  	clear
  	echo "1:$txtwht Update Bukkit"$txtrst
  	echo "2:$txtwht Kill Inactive ABM Sessions"$txtrst
	echo "3:$txtwht Delete ABM Temp Files"$txtrst
	echo
	echo "0:$txtwht Return To Main Menu"$txtrst
	echo
	echo -e "Enter Choice: \c"	
	read CHOICE
	case "$CHOICE" in
		"1")
			update
			;;
		"2")
			killdefunctABM
			;;
		"3")
			forcecleanTmp
			;;
		"0")
			break
            ;;
  		"q")
			break
			;;
        *) echo "\"$CHOICE\" is not valid "; sleep 2 ;;
    esac
done
}

# Display Menu and wait for choice.
while [ 1 ]
do
	clear
	showMainMenu
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
			sayCommand
			;;
		"t")
			sayCommand
			;;
		"9")
			advancedMenu
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
