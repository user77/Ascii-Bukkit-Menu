#!bin/bash
dir="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
abmdir=
vars="$abmdir/include/config/vars"
abmconfig="$abmdir/include/config/abm.conf"

source $vars 2>/dev/null
source $abmconfig 2>/dev/null

#Ascii Art
banner () {
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
}

javaCheck () {
  java=`which java`
  if [ -z $java ]; then
    echo "Java Runtime Environment not found."
    echo "Please see http://docs.oracle.com/javase/7/docs/webnotes/install/index.html"
    exit 0
  fi
}

#Create directory for logs to go in.
createLogsdir () {

        if [ ! -d "$logs" ]; then
          mkdir $logs 2>/dev/null
        fi
}

# Create LogRoatate Config. New one everytime in case abm.conf has changed.
createLogrotate () {
cat > "$lrconf" <<EOF
"$slog" {
copytruncate
rotate 20
compress
olddir $logs
}
EOF
}

# Script to create include/config/abm.conf. This file is a dependency.
setupConfig () {
clear
echo
echo "----==== ABM Configuration Setup ====----"
echo
echo "This will guide you through the setup for Ascii Bukkit Menu."
echo "If you decide not to answer a question, defaults will be used."
echo 
echo "Would you like to use the Recommended, Beta or Development version"
echo "of CraftBukkit? [rb/beta/dev]"
echo
read -p "Bukkit Branch: " bukkitBranch
echo
echo "Please enter the absolute path to your Bukkit installation."
echo "Example: /opt/craftbukkit"
echo
read -p "Bukkit Path: " bukkitdir
echo
echo "Please add any Java arguments you would like. Seperated by space."
echo "For a complete list, please see: http://bit.ly/mYKJte"
echo "Default: -server -Xincgc -Xmx1g"
echo
read -p "Java Arguments: " jargs

echo
echo "How fast (in seconds) you would like ABM to refresh server status."
echo "Doesn't effect log view."
echo "Default: 5"
echo
read -p "Refresh: " tick

echo
echo "Are you using a ramdisk?" 
echo "See http://bit.ly/smK9iR for more info."
echo 
read -p "[y/n] " ramdisk
  if [[ $ramdisk =~ ^(yes|y|Y)$ ]]; then
    echo
    echo "Please enter the names of the worlds that should be copied to and from ramdisk to localdisk"
    echo "Use exact names as they show in $bukkitdir separated by space."
    echo
    read -p "Worlds: " worlds
  fi

  if [[ $sarbin ]]; then
    echo
    echo "Using Sar ABM will show network usage. Please enter the intferace name."
    echo "For example. Linux=eth0 BSD/Solaris/Arch=bge0 *check dmesg"
    echo "If you don't know just hit enter."
    read -p "Interface Name: " $eth
  fi

clear

# End of Questions. Time to check for missing variables.
  if [[ -z $bukkitBranch ]]; then
    echo
    echo "No CraftBukkit Branch set. Assuming Recommended."
    bukkitBranch=recommended
  elif [[ $bukkitBranch ]]; then
    if [[ $bukkitBranch =~ ^(recommended|Recommended|r|R|rb|RB|rB|Rb)$ ]]; then
      bukkitBranch=recommended
    elif [[ $bukkitBranch =~ ^(beta|Beta|BETA|b|B)$ ]]; then
      bukkitBranch=beta
    elif [[ $bukkitBranch =~ ^(development|Development|dev|Dev|DEV|d|D)$ ]]; then
      bukkitBranch=development
    else
      bukkitBranch=recommended
    fi
    echo "Craftbukkit Branch set to:" $bukkitBranch
  fi

  if [[ -z $bukkitdir ]]; then
    echo
    echo "Error no CraftBukkit directory set."
    read -p "Would you like to run setup again? [y/n] " answer
      case $answer in
	[yY] | [yY][eE][Ss] )
          setupConfig
	  ;;
	[nN] | [nN][oO] )
	  echo "Please edit config manually $abmconfig"
	  ;;
         *) echo "Invalid Input"
          ;;
        esac
  fi
  
  if [[ -z $jargs ]]; then
    echo
    echo "No Java Arguments set, using defaults.."
    jargs="-server -Xincgc -Xmx1g"
    echo $jargs
    sleep 1
  fi

  if [[ -z $tick ]]; then
    echo
    echo "Refresh not set, using default.."
    tick=5
    echo $tick
    sleep 1
  fi

  if [[ -z $ramdisk ]]; then
    echo
    echo "Ramdisk not set, using default.."
    ramdisk=false
    echo $ramdisk
    sleep 1
  fi

  if [[ $ramdisk =~ ^(yes|y|Y)$ ]]; then
    ramdisk=true
  fi

  if [[ $ramdisk =~ ^(no|n|N)$ ]]; then
    ramdisk=false
  fi

  if [[ $ramdisk = "true" ]]; then
    if [[ -z $worlds ]]; then
      echo
      echo "Ramdisk Worlds not set. Please try again.."
      read -p "Would you like to run setup again? [Y/N] " answer
        if [[ $answer =~ ^(yes|y|Y)$ ]]; then
          setupConfig
        fi
    fi
  fi

  if [[ $sarbin ]]; then
   if [[ -z $eth ]]; then
    echo
    echo "No Interface set."
    echo "Trying to find out based on default gateway.."
    eth=`netstat -rn |grep 0.0.0.0 |head -n 1 |awk '{print $8}'`
    echo "Found:" $eth
    echo
    sleep 1
   fi
 fi
sleep 2
clear
echo
echo "Please review:"
echo
echo "CraftBukkit Branch: "$bukkitBranch 
echo "CraftBukkit Directory: "$bukkitdir
echo "Java Arguments: "$jargs
echo "Display Refresh: "$tick
echo "RamDisk Used: "$ramdisk
echo "RamDisk Worlds: " $worlds
echo "Interface:" $eth
echo
read -p "Use this Config? [y/n] " answer
 case $answer in
 [yY] | [yY][eE][Ss] )
cat > "$abmdir/include/config/abm.conf" <<EOF
abmversion=0.2.6

bukkitBranch=$bukkitBranch

# Absolute path to your CraftBukkit installation. Example:
#bukkitdir=/opt/minecraft
bukkitdir=$bukkitdir

# Java Arguments, change to whaever you like.
# For a complete list, please see: http://bit.ly/mYKJte
jargs="$jargs"

# Set Status Refresh rate in seconds.
tick=$tick

#Are you using a ramdisk? if so change to true. See http://bit.ly/smK9iR for more info.
ramdisk=$ramdisk

#If True, set world names with space between.
worlds=( $worlds )

#NIC To use for SAR
eth=$eth
EOF
clear
echo "$abmconfig written successfully"
;; 
[nN] | [nN][oO] )
    echo
    read -p "Would you like to run setup again? [Y/N] " answer
      if [[ $answer =~ ^(yes|y|Y)$ ]]; then
        setupConfig
      elif  [[ $answer =~ ^(no|n|N)$ ]]; then 
        echo "Please edit config manually $abmconfig"
      fi
;;
*) echo "Invalid Input"
;;
esac
}

#Create update tracker..
createUpdate () {
if [[ ! -f $abmdir/include/config/update ]]; then
cat > "$abmdir/include/config/update" <<EOF
0
EOF
fi
}

#Create screen.conf 
screenConf () {
screenversion=`screen -v| awk '{ print $3 }'`
# if debian vertical patched version of screen
if [ $screenversion = "4.00.03jw4" ]; then
cat > "$abmdir/include/config/screen.conf" <<EOF
startup_message off
altscreen on
term screen-256color
termcapinfo xterm*|linux*|rxvt*|Eterm*|screen* OP
termcapinfo xterm|xterms|xs|rxvt|screen ti@:te@
sessionname abm-$abmid 
screen -t Server_Status $abmdir/include/scripts/status.sh 
screen -t Bukkit_Log $abmdir/include/scripts/log.sh 
screen -t Menu $abmdir/include/scripts/menu.sh 
select Server_Status 
split 
focus  down
select Bukkit_Log 
split -v
focus down
select Menu
focus  bottom
resize -30
EOF

#if git version of screen patched for vert. Thanks mraof
elif [ $screenversion = "4.01.00devel" ]; then
cat > "$abmdir/include/config/screen.conf" <<EOF
startup_message off
altscreen on
term screen-256color
termcapinfo xterm*|linux*|rxvt*|Eterm*|screen* OP
termcapinfo xterm|xterms|xs|rxvt|screen ti@:te@
sessionname abm-$abmid
screen -t Server_Status $abmdir/include/scripts/status.sh 
screen -t Bukkit_Log $abmdir/include/scripts/log.sh 
screen -t Menu $abmdir/include/scripts/menu.sh
select Server_Status 
split 
focus  down
select Bukkit_Log 
split -v
focus bottom
select Menu
focus  down
resize -30
EOF

else
cat > "$abmdir/include/config/screen.conf" <<EOF
startup_message off
altscreen on
term screen-256color
termcapinfo xterm*|linux*|rxvt*|Eterm*|screen* OP
termcapinfo xterm|xterms|xs|rxvt|screen ti@:te@
sessionname abm-$abmid
screen -t Server_Status $abmdir/include/scripts/status.sh 
screen -t Bukkit_Log $abmdir/include/scripts/log.sh 
screen -t Menu $abmdir/include/scripts/menu.sh
select Server_Status 
split 
focus  down
select Bukkit_Log 
split -v
focus down
select Menu
focus  bottom
resize -30
EOF

fi
}

# Find PID of Bukkit Server.
checkServer () {
        MCPID=`ps -ef |grep -i craftbukkit* |grep -v grep |awk '{ print $2 }'`
}

# Update Bukkit to Latest.
update () {
        stopServer
        if [[ ! $MCPID ]]; then
          if [ $bukkitBranch = "recommended" ]; then
            bukkiturl="http://cbukk.it/craftbukkit.jar"
            wget --progress=dot:mega $bukkiturl -O "$bukkitdir/craftbukkit.jar"
          elif [ $bukkitBranch = "development" ]; then 
            bukkiturl="http://cbukk.it/craftbukkit-dev.jar"
            wget --progress=dot:mega $bukkiturl -O "$bukkitdir/craftbukkit-dev.jar"
          elif [ $bukkitBranch = "beta" ]; then
            bukkiturl="http://cbukk.it/craftbukkit-beta.jar"
            wget --progress=dot:mega $bukkiturl -O "$bukkitdir/craftbukkit-beta.jar"
          else
            echo "Bukkit Branch not set."
            echo "Please check your ABM Config."
          fi
          cat /dev/null > $slog
          rm -f /tmp/plugins-$abmid*
          rm -f /tmp/build-$abmid*
	        clear
            if [ $craftbukkit ]; then
              echo $txtgrn"Update Successful!"$txtrst
              sleep 2
            fi
          startServer
        elif [[ $MCPID ]]; then
          echo -e "Craftbukkit Server Running"
          echo -e "Update Aborted"
          sleep 5
        fi
}

# Install MineQuery Plugin. Restart Server.
installmq () {
        clear
        wget -m -nd --progress=dot:mega -P $abmdir/include/temp/ https://github.com/downloads/vexsoftware/minequery/Minequery-1.5.zip
        unzip -o $abmdir/include/temp/Minequery-1.5.zip -d $bukkitdir/plugins
        rm $abmdir/include/temp/Minequery-1.5.zip
        clear
        stopServer
        startServer
}

# Start Bukkit Server
startServer () {
        clear
        checkServer
        # Need to recheck for screen PID for bukket-server session. In case it has been stopped.
        serverscreenpid=`screen -ls |grep bukkit-server |cut -f 1 -d .`
        if [[ -z $MCPID ]]; then
                logrotate -f -s $abmdir/include/temp/rotate.state $abmdir/include/config/rotate.conf
                rm $abmdir/include/temp/rotate.state
                cd $bukkitdir
                if [[ -z $serverscreenpid ]]; then
                        screen -d -m -S bukkit-server
                fi
                #if using ramdisk copy from local to ramdisk.
                if [ $ramdisk = true ]; then
                  read -p "Would you like copy from local disk to ram disk? [Y/N] " answer
                    if [[ $answer =~ ^(yes|y)$ ]]; then
                        for x in ${worlds[*]}
                        do
                        [ "$(ls -A $bukkitdir/$x-offline/)" ] && cp -rfv "$bukkitdir/$x-offline/"* "$bukkitdir/$x/" >>  "$bukkitdir/server.log" || echo "Nothing to Copy..."
                        find "$bukkitdir/$x" -type f -print0 | xargs -0 md5sum | cut -f 1 -d " " | sort -rn  > "$abmdir/include/temp/$x.md5"
                        find "$bukkitdir/$x-offline" -type f -print0 | xargs -0 md5sum | cut -f 1 -d " " | sort -rn > "$abmdir/include/temp/$x-offline.md5"
                        md5=`diff "$abmdir/include/temp/$x.md5" "$abmdir/include/temp/$x-offline.md5"`
                        sleep 5
                          if [ -n "$md5" ]; then
                            echo $txtred "#### Warning! #### Warning! ####" $txtrst >> $slog
                            echo "MD5 Check Failed for $x" >> $slog
                            echo "Please investigate." >> $slog
                            elif [ -z "$md5" ]; then
                              echo $txtgrn "Copied $x from local disk to ram disk sucessully!" $txtrst >> $slog
                          fi
                        rm -f "$abmdir/include/temp/$x.md5" "$abmdir/include/temp/$x-offline.md5"
                        done
                    fi
                fi
                # Start craftbukkit on existing screen session.
                screen -S bukkit-server -p 0 -X exec java $jargs -jar $bukkitdir/$cbfile nogui
                cd -

        elif [[ $MCPID ]]; then
                        echo -e "Server Already Running.."
                        sleep 1
        fi

}


# Stop Bukkit Server
stopServer () {
        clear
        checkServer
        if [[ -z $MCPID ]]; then
                clear
                echo "Bukkit Not Running.."
                sleep 1
        else
		if [[ $silent != "--stop" ]]; then
		  read -p "Confirm Shutdown. [Y/N] " answer
		fi
		if [[ $silent = "--stop" ]]; then
		  answer=y
		fi
		if [[ $answer =~ ^(yes|y|Y)$ ]]; then
      screen -S bukkit-server -p 0 -X eval 'stuff "save-all"\015'
      screen -S bukkit-server -p 0 -X eval 'stuff "stop"\015'
        while [[ $MCPID ]]; do
          echo "Bukkit Shutdown in Progress.."
          checkServer
          clear
        done
          if [ $ramdisk = true ]; then
            read -p "Would you like copy from ram disk to local disk? [Y/N] " answer
              if [[ $answer =~ ^(yes|y|Y)$ ]]; then
                for x in ${worlds[*]}
                  do
                    cp -rfv "$bukkitdir/$x/"* "$bukkitdir/$x-offline/"  >>  "$bukkitdir/server.log"
                    find "$bukkitdir/$x" -type f -print0 | xargs -0 md5sum | cut -f 1 -d " " | sort -rn > "$abmdir/include/temp/$x.md5"
                    find "$bukkitdir/$x-offline" -type f -print0 | xargs -0 md5sum | cut -f 1 -d " " | sort -rn > "$abmdir/include/temp/$x-offline.md5"
                    md5=`diff "$abmdir/include/temp/$x.md5" "$abmdir/include/temp/$x-offline.md5"`
                      if [ -n "$md5" ]; then
                        echo $txtred "#### Warning! #### Warning! ####" $txtrst
                        echo "MD5 Check Failed for $x"
                        echo "Please investigate."
                        read -p "Hit any key to continue..."
                        clear
                      elif [ -z "$md5" ]; then
                        clear
                        echo $txtgrn "Copied $x from ram disk to local disk sucessully!" $txtrst
                        sleep 2
                        clear
                      fi
                    rm -f "$abmdir/include/temp/$x.md5" "$abmdir/include/temp/$x-offline.md5"
                  done
              fi
          fi
        screen -S bukkit-server -X quit
        rm -f /tmp/plugins-$abmid*
        rm -f /tmp/build-$abmid*
		      fi
        fi
}

restartServer () {
  stopServer
  if [[ -z $MCPID ]]; then
    startServer
  fi
}

# Send Server Commands
serverCommands () {
  clear
  echo -e "Send Server Command: \c"
  read command
  screen -S bukkit-server -p 0 -X eval 'stuff '"\"$command\""'\015'
}

# Say command to server
sayCommand () {
 clear
  echo -e "Say: \c"
  read comment
  screen -S bukkit-server -p 0 -X eval 'stuff '"\"say $comment\""'\015' 
}

# Function to clean variables.  Warning: Will clean all variables.
cleanTmp () {
# Make sure all temp files are removed. Just in case.
  rm -f /tmp/topinfo-$abmid*
  rm -f /tmp/freeinfo-$abmid*
  rm -f /tmp/sarinfo-$abmid*
  rm -f /tmp/plugins-$abmid*
  rm -f /tmp/build-$abmid*
  rm -f /tmp/minequeryinfo-$abmid.*
  rm -f /tmp/done-$abmid.*
}

# Quit Function
quitFunction () {
  cleanTmp
  # Kill Screen
  kill $menuscreenpid
  exit 0
}

# Get Craftbukkit Version Info
getVersion () {
if [ $MCPID ]; then
  buildtmp=`mktemp "/tmp/build-$abmid.XXXXXX"`
  grep "This server is running CraftBukkit" $slog |tail -1 | awk '{print $10, $11, $12}' > $buildtmp
fi
}

# Get Plugin Info
getPlugins () {
if [ $MCPID ]; then  
  screen -S bukkit-server -p 0 -X eval 'stuff '"plugins"'\015'
  sleep 2
  plugintmp=`mktemp "/tmp/plugins-$abmid.XXXXXX"`
  grep "Plugins" $slog |head -1 |awk '{ $1=""; $2=""; $3=""; $4=""; print $0 }' > $plugintmp
fi
}

getDone () {
# function to find "Done" time.
if [[ $MCPID ]]; then
  donetmp=`mktemp "/tmp/done-$abmid.XXXXXX"`
  grep "Done ([0-9]\{1,\}\.[0-9]\{1,\}s)\!" $slog | awk '{print $5}' > $donetmp
fi
}

# This is the main info showed in status.sh
showInfo () {
  checkServer
  if [[ -f $abmdir/include/temp/latestabm ]]; then
    latestabm=`cat $abmdir/include/temp/latestabm`
  elif [[ ! -f $abmdir/include/temp/latestabm ]]; then
    wget --quiet -r http://bit.ly/vvizIg -O  $abmdir/include/temp/latestabm
  fi
  if [[ -f "$buildtmp" ]]; then
    build=`cat $buildtmp`
  elif [[ ! -f "$buildtmp" ]]; then
    build=
    if [[ $MCPID ]]; then
      getVersion
    fi
  fi
  load=`uptime|awk -F"average:" '{print $2}'` # Cut everthing after "average:"
  topinfo=`mktemp "/tmp/topinfo-$abmid.XXXXXX"`
  getTop=`top -n 1 -b > $topinfo`
  freeinfo=`mktemp "/tmp/freeinfo-$abmid.XXXXXX"`
  getFree=`free -m > $freeinfo`
  if [[ $MCPID ]]; then
    bukkitCpuTop=`grep $MCPID $topinfo |awk -F" " '{print $9}'`
    bukkitMemTop=`grep $MCPID $topinfo |awk -F" " '{print $10}'`
  fi
  # Get information from SAR
  if [[ $sarbin ]]; then
    sarinfo=`mktemp "/tmp/sarinfo-$abmid.XXXXXX"`
    getSar=`sar -n DEV 1 1 |grep $eth |grep -v "Average:"|grep -v lo|awk '{print $5,$6}' > $sarinfo`
    netrx=`awk {'print $1'} $sarinfo`
    nettx=`awk {'print $2'} $sarinfo`
    rm -f $sarinfo
  fi
  totalCpuTop=`grep Cpu $topinfo | cut -d ":" -f 2`
  totalMem=`sed -n 2p $freeinfo |awk '{print $2}'`
  totalMemUsed=`sed -n 2p $freeinfo |awk '{print $3}'`
  totalMemFree=`sed -n 2p $freeinfo |awk '{print $4}'`
  totalSwap=`sed -n 4p $freeinfo |awk '{print $2}'`
  totalSwapUsed=`sed -n 4p $freeinfo |awk '{print $3}'`
  totalSwapFree=`sed -n 4p $freeinfo |awk '{print $4}'`
  diskuse=`df -h $bukkitdir|grep -e "%" |grep -v "Filesystem"|grep -o '[0-9]\{1,3\}%'`
  rm -f $topinfo
  rm -f $freeinfo
  if [ -s "$plugintmp" ]; then
    plugins=`cat $plugintmp`
  elif [ ! -s "$plugintmp" ]; then
    getPlugins
  fi
  stime=`date`
  # Check for MineQuery Plugin & Set $playerCount & $players
  if [[ -f "$bukkitdir/plugins/Minequery.jar" ]]; then
    mineQueryinfo=`mktemp "/tmp/minequeryinfo-$abmid.XXXXXX"`
    mineQuery=`echo "QUERY" |nc localhost 25566 > $mineQueryinfo`
    players=`grep PLAYERLIST $mineQueryinfo | grep PLAYERLIST | awk -F"PLAYERLIST" '{print $2}'|sed -e 's/^[ \t]*//'`
    playerCount=`grep PLAYERCOUNT $mineQueryinfo | grep PLAYERCOUNT|awk -F "PLAYERCOUNT" '{print $2}'`
    rm -f $mineQueryinfo
  fi
  clear
  echo -e $txtbld"Ascii Bukkit Menu:"$txtrst $abmversion
  if [[ -n "$latestabm" ]]; then
    if [[ "$latestabm" > "$abmversion" ]]; then
      echo -e $txtred"Update Availible:" $latestabm $txtrst
    fi
  fi
  echo
  echo -e $txtbld"Bukkit Server Info"$txtrst
  if [[ $MCPID ]]; then
    uptime=`ps -p $MCPID -o stime|grep -v STIME`
    echo -e $txtgrn"Running$txtrst Since: "$uptime
  fi
  if [[ -z $MCPID ]]; then
    echo -e $txtred"Not Running" $txtrst
  fi
  craftbukkit=$bukkitdir/$cbfile
  if [ ! -f $craftbukkit ]; then
    echo -e $txtred"Not Installed"$txtrst
    echo -e $txtred"Choose Option 6 to install"$txtrst
    echo -e "If this is your first time installing"
    echo -e "Craftbukkit, then it is recommended"
    echo -e "you restart ABM after install."
    echo
  fi
  if [[ -z $build ]]; then
    if [[ $MCPID ]]; then
      echo -e $txtbld"Build:"$txtrst "Loading..."
    elif [[ -z $MCPID ]]; then
      echo -e $txtbld"Build:"$txtrst
    fi
  elif [[ $build ]]; then
    echo -e $txtbld"Build:"$txtrst $build
  fi
  echo -e $txtbld"Java Flags:"$txtrst $jargs
  if [[ -z $plugins ]]; then
    if [[ $MCPID ]]; then
      echo -e $txtbld"Plugins"$txtrst "Loading..."
    elif [[ -z $MCPID ]]; then
      echo -e $txtbld"Plugins"$txtrst
    fi
  elif [[ $plugins ]]; then
    echo -e $txtbld"Plugins"$txtrst $plugins
  fi
  if [[ $MCPID ]]; then
    echo -e $txtbld"CPU Usage:"$txtrst $bukkitCpuTop"%"
    echo -e $txtbld"Mem Usage:"$txtrst $bukkitMemTop"%"
    if [[ $playerCount ]]; then
      echo -e $txtbld"Player Count:"$txtrst $playerCount
    fi
    if [[ $players ]]; then
      echo -e $txtbld"Connected Players:"$txtrst $players
    fi
  fi
  echo
  echo -e $txtbld"System Info"$txtrst
  echo -e $txtbld"Hostname:"$txtrst $hostname
  echo -e $txtbld"CPU Usage:"$txtrst $totalCpuTop
  echo -e $txtbld"Mem Usage:"$txtrst "Total: "$totalMem"MB" "Used: "$totalMemUsed"MB"  "Free: "$totalMemFree"MB"
  echo -e $txtbld"Swap Usage:"$txtrst "Total: "$totalSwap"MB" "Used: "$totalSwapUsed"MB"  "Free: "$totalSwapFree"MB"
  echo -e $txtbld"Disk Usage:"$txtrst $diskuse
  if [[ $sarbin ]]; then
    echo -e $txtbld"Network:"$txtrst RX: $netrx"kB/s" "|" TX: $nettx"kB/s"
  fi
  echo -e $txtbld"Load:"$txtrst $load
  echo -e $txtbld"Time:"$txtrst $stime
}


# Check for Bukkit & ABM Update once a day
checkUpdate () {
  lastup=`cat $abmdir/include/config/update`
  if [[ $lastup -lt `date "+%y%m%d"` ]]; then
    echo -e $txtred"Checking for Bukkit and ABM Update..."$txtrst
    wget --quiet -r http://bit.ly/vvizIg -O  $abmdir/include/temp/latestabm
    date "+%y%m%d" > $abmdir/include/config/update
    sleep 2
    latestabm=`cat $abmdir/include/temp/latestabm`
  fi
}
# The End