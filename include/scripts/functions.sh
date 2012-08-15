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

# Trap ctrl+c and do cleanup.
 ctrl_c () {
         clear
         echo "CTRL+C Detected. I won't take it personally."
         echo "Cleaning Up all temp files.."
         sleep 3
         quitFunction
}

depCheck () {
  if [ -z `which java` ]; then
    echo "Fatal Error!"
    echo "Java Runtime Environment not found."
    echo "Please see http://docs.oracle.com/javase/7/docs/webnotes/install/index.html"
    echo "ABM can not continue."
    exit 0
  fi
  if [[ -z `which screen` ]]; then
    echo "Fatal Error!"
    echo "screen not found."
    echo "Please see http://www.gnu.org/software/screen/"
    echo "ABM can not continue."
    exit 0
  fi
  if [[ -z `which grep` ]]; then
    echo "Fatal Error!"
    echo "grep not found."
    echo "Please see http://www.gnu.org/s/grep/"
    echo "ABM can not continue."
    exit 0
  fi
  if [[ -z `which wget` ]]; then
    echo "Warning!"
    echo "wget not found."
    echo "Please see http://www.gnu.org/s/wget/"
    echo "ABM can continue, however you may experiance problems."
    sleep 2
  fi
  if [[ -z `which zip` ]]; then
    echo "Warning!"
    echo "zip not found."
    echo "Please see http://www.info-zip.org/"
    echo "ABM can continue, however you may experiance problems."
    sleep 2
  fi
  if [[ -z `which logrotate` ]]; then
    echo "Warning!"
    echo "logrotate not found."
    echo "Please see https://fedorahosted.org/logrotate/"
    echo "ABM can continue, however you may experiance problems."
    sleep 2
  fi
  if [[ -z `which md5sum` ]]; then
    echo "Warning!"
    echo "md5sum not found."
    echo "Please see http://www.gnu.org/software/coreutils/"
    echo "ABM can continue, however you may experiance problems."
    sleep 2
  fi
}

#Create directory for logs to go in.
createLogsdir () {
  if [[ ! -d "$logs" ]]; then
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
echo "Default: -server -Xincgc -Xmx1G"
echo
read -p "Java Arguments: " jargs

echo
echo "How fast (in seconds) you would like ABM to refresh server status."
echo "Doesn't effect log view."
echo "Default: 5"
echo
read -p "Refresh: " tick

echo
echo "ABM can automatically notify players of an impending shutdown."
echo "Would you like to create a custom shutdown message?"
read -p "[y/n] " notify
echo
  if [[ $notify =~ ^(yes|y|Y) ]]; then
    echo "Please enter a message that will be displayed to players upon shutdown."
    echo "Enter your message and hit enter to complete."
    echo "You can edit this later in "$abmconfig
    read -p "Shutdown Message: " shutdownNotify
    echo
    echo "Enter shutdown timer in seconds."
    echo "For immediate shutdown leave blank."
    echo "This will allow a delay between displaying your custom message and server shutdown."
    read -p "Shutdown Timer: " shutdownTimer
    echo
    echo "Shutdown Message:" $shutdownNotify
    if [[ -n $shutdownTimer ]]; then
      echo "Shutdown Timer: " $shutdownTimer"s"
    fi
  fi
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

####### Start of Backup - Not Complete #######
#echo
#echo "ABM can manage backups of your Minecraft worlds"
#echo "This is achieved though a backup script and cron job."
#echo "Backups are saved in a zip format compatible with WorldEdit Snapshots."
#echo "See http://wiki.sk89q.com/wiki/WorldEdit/Snapshots"
#read -p "Would you like to enable backups? [y/n] " backup
#if [[ $backup =~ ^(yes|y|Y)$ ]]; then
#  read -p "Where would you like to store backups?: " backupdir
#  cat > "$abmdir/include/scripts/backup.sh" <<EOF
#  filename=`date '+%Y-%m-%d-%H-%M-%S'`
#  backupdir=$backupdir
#  log=$bukkitdir/logs/backup.txt
#  players=`echo "QUERY" |nc localhost 25566 |grep "PLAYERCOUNT" |awk '{ print $2 }'`
#  saveall="save-all"
#  saveoff="save-off"
#  saveon="save-on"

#  if [ $players -gt 0 ]; then
#    echo "`date '+%Y:%m:%d-%H:%M:%S'` - Players Detected, Starting Backup" >> $log
#    screen -S bukkit-server -p 0 -X eval 'stuff '"\"$saveall\""'\015'
#    screen -S bukkit-server -p 0 -X eval 'stuff '"\"$saveoff\""'\015'
#    cd $bukkitdir/Worlds
#    sleep 5
#    for x in ${worlds[*]}
#      do
#      if [ ! -d $backupdir/$x ]; then
#       mkdir -p $backupdir/$x
#      fi
#      zip -6 -v -r $backupdir/$x/$filename $x >> $log
#      find $backupdir/$x -type f -mtime +2 -exec rm {} \; >> $log
#    done
#  screen -S bukkit-server -p 0 -X eval 'stuff '"\"$saveon\""'\015'
#  cd -
#  elif [ $players = 0 ]; then
#   echo "`date '+%Y:%m:%d-%H:%M:%S'` - No Players Connected, Skipping Backup"  >> $log
#  fi
#  exit 0
#EOF
#fi
####### End of Backup #######
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
  jargs="-server -Xincgc -Xmx1G"
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

  if [[ -z $shutdownTimer ]]; then
    shutdownTimer='0'
  elif [[ -n $shutdownTimer ]]; then
    shutdownTimer=$shutdownTimer
  fi

sleep 2
clear
echo "Please Review:"
echo
echo "CraftBukkit Branch: "$bukkitBranch 
echo "CraftBukkit Directory: "$bukkitdir
echo "Java Arguments: "$jargs
echo "Display Refresh: "$tick
echo "RamDisk Used: "$ramdisk
echo "RamDisk Worlds: " $worlds
echo "Interface:" $eth
if [[ $shutdownNotify ]]; then
  echo "Shutdown Message:" $shutdownNotify
  echo "Shutdown Timer:" $shutdownTimer"s"
fi
echo
read -p "Use this Config? [y/n] " answer
 case $answer in
 [yY] | [yY][eE][Ss] )
cat > "$abmdir/include/config/abm.conf" <<EOF
abmversion=0.2.8

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

#Custom Shutdown Message & Timer
shutdownNotify="$shutdownNotify"
shutdownTimer="$shutdownTimer"

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
  bukkitPID=`ps -ef |grep "java $jargs -jar $bukkitdir/craftbukkit" | grep -v grep | awk '{ print $2 }'`
}

# Update Bukkit to Latest.
update () {
  stopServer
  if [[ ! $bukkitPID ]]; then
    rm $bukkitdir/craftbukkit*.jar
    if [[ $bukkitBranch = "recommended" ]]; then
      bukkiturl="http://cbukk.it/craftbukkit.jar"
      wget --progress=dot:mega $bukkiturl -O "$bukkitdir/craftbukkit.jar"
    elif [[ $bukkitBranch = "development" ]]; then
      bukkiturl="http://cbukk.it/craftbukkit-dev.jar"
      wget --progress=dot:mega $bukkiturl -O "$bukkitdir/craftbukkit-dev.jar"
    elif [[ $bukkitBranch = "beta" ]]; then
      bukkiturl="http://cbukk.it/craftbukkit-beta.jar"
      wget --progress=dot:mega $bukkiturl -O "$bukkitdir/craftbukkit-beta.jar"
    else
      echo "Bukkit Branch not set."
      echo "Please check your ABM Config."
    fi
    cat /dev/null > $slog
    clear
    if [[ $craftbukkit ]]; then
      echo $txtgrn"Update Successful!"$txtrst
      sleep 1
    fi
    startServer
  elif [[ $bukkitPID ]]; then
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
  cleanTmp
  # Need to recheck for screen PID for bukket-server session. In case it has been stopped.
  serverscreenpid=`screen -ls |grep bukkit-server |cut -f 1 -d .`
  if [[ -z $bukkitPID ]]; then
    logrotate -f -s $abmdir/include/temp/rotate.state $abmdir/include/config/rotate.conf
    rm $abmdir/include/temp/rotate.state
    cd $bukkitdir
    if [[ -z $serverscreenpid ]]; then
      screen -d -m -S bukkit-server
    fi
    #if using ramdisk copy from local to ramdisk.
    if [[ $ramdisk = true ]]; then
      read -p "Would you like copy from local disk to ram disk? [Y/N] " answer
      if [[ $answer =~ ^(yes|y)$ ]]; then
        for x in ${worlds[*]}
        do
          [ "$(ls -A $bukkitdir/$x-offline/)" ] && cp -rfv "$bukkitdir/$x-offline/"* "$bukkitdir/$x/" >>  "$bukkitdir/server.log" || echo "Nothing to Copy..."
          find "$bukkitdir/$x" -type f -print0 | xargs -0 md5sum | cut -f 1 -d " " | sort -rn  > "$abmdir/include/temp/$x.md5"
          find "$bukkitdir/$x-offline" -type f -print0 | xargs -0 md5sum | cut -f 1 -d " " | sort -rn > "$abmdir/include/temp/$x-offline.md5"
          md5=`diff "$abmdir/include/temp/$x.md5" "$abmdir/include/temp/$x-offline.md5"`
          sleep 5
          if [[ -n "$md5" ]]; then
            echo $txtred "#### Warning! #### Warning! ####" $txtrst >> $slog
            echo "MD5 Check Failed for $x" >> $slog
            echo "Please investigate." >> $slog
          elif [[ -z "$md5" ]]; then
            echo $txtgrn "Copied $x from local disk to ram disk sucessully!" $txtrst >> $slog
          fi
          rm -f "$abmdir/include/temp/$x.md5" "$abmdir/include/temp/$x-offline.md5"
        done
      fi
    fi
    # Start craftbukkit on existing screen session.
    screen -S bukkit-server -p 0 -X exec java $jargs -jar $bukkitdir/$cbfile nogui
    cd -
  elif [[ $bukkitPID ]]; then
    echo -e "Server Already Running.."
      sleep 1
  fi
}

# Stop Bukkit Server
stopServer () {
  clear
  checkServer
  if [[ -z $bukkitPID ]]; then
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
      if [[ $shutdownNotify ]]; then
        screen -S bukkit-server -p 0 -X eval 'stuff '"\"say $shutdownNotify\""'\015'
        if [[ -n $shutdownTimer ]]; then
          screen -S bukkit-server -p 0 -X eval 'stuff '"\"say Server Shutdown in $shutdownTimer seconds\""'\015'
          for x in `seq 1 $shutdownTimer`; do
            echo "[CTRL+C] will Kill ABM and cancel shutdown."
            echo $x"s" of $shutdownTimer"s"
            sleep 1;
            clear
          done
       fi
      fi
      screen -S bukkit-server -p 0 -X eval 'stuff "save-all"\015'
      screen -S bukkit-server -p 0 -X eval 'stuff "stop"\015'
      while [[ $bukkitPID ]]; do
        echo "Bukkit Shutdown in Progress.."
        checkServer
        unset bukkitPID
        clear
      done
      if [[ $ramdisk = true ]]; then
        read -p "Would you like copy from ram disk to local disk? [Y/N] " answer
        if [[ $answer =~ ^(yes|y|Y)$ ]]; then
          for x in ${worlds[*]}
          do
            cp -rfv "$bukkitdir/$x/"* "$bukkitdir/$x-offline/"  >>  "$bukkitdir/server.log"
            find "$bukkitdir/$x" -type f -print0 | xargs -0 md5sum | cut -f 1 -d " " | sort -rn > "$abmdir/include/temp/$x.md5"
            find "$bukkitdir/$x-offline" -type f -print0 | xargs -0 md5sum | cut -f 1 -d " " | sort -rn > "$abmdir/include/temp/$x-offline.md5"
            md5=`diff "$abmdir/include/temp/$x.md5" "$abmdir/include/temp/$x-offline.md5"`
            if [[ -n "$md5" ]]; then
              echo $txtred "#### Warning! #### Warning! ####" $txtrst
              echo "MD5 Check Failed for $x"
              echo "Please investigate."
              read -p "Hit any key to continue..."
              clear
            elif [[ -z "$md5" ]]; then
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
      unset bukkitPID
    fi
  fi
}

restartServer () {
  stopServer
  if [[ -z $bukkitPID ]]; then
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

cleanTmp () {
# Remove all temp files. For this ABM Session
  rm -f /tmp/topinfo-$abmid*
  rm -f /tmp/freeinfo-$abmid*
  rm -f /tmp/sarinfo-$abmid*
  rm -f /tmp/plugins-$abmid*
  rm -f /tmp/build-$abmid*
  rm -f /tmp/minequeryinfo-$abmid*
  rm -f /tmp/abmstmp-$abmid*
  rm -f /tmp/donetmp-$abmid*
  rm -f /tmp/bukkitpid-$abmid*
}

forcecleanTmp () {
# force remove all temp files. 
  rm -f /tmp/topinfo-*
  rm -f /tmp/freeinfo-*
  rm -f /tmp/sarinfo-*
  rm -f /tmp/plugins-*
  rm -f /tmp/build-*
  rm -f /tmp/minequeryinfo-*
  rm -f /tmp/abmstmp-*
  rm -f /tmp/donetmp-
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
if [[ $bukkitPID ]]; then
  if [[ ! -f $buildtmp ]]; then
    buildtmp=`mktemp "/tmp/build-$abmid.XXXXXX"`
    grep "This server is running CraftBukkit" $slog |tail -1 | awk '{print $10, $11, $12}' > $buildtmp
  fi
  build=`cat $buildtmp`
fi
}

# Get Plugin Info
getPlugins () {
  if [[ ! -f $plugintmp ]]; then
    plugintmp=`mktemp "/tmp/plugins-$abmid.XXXXXX"`
    grep "Plugins" $slog |head -1 |awk '{ $1=""; $2=""; $3=""; $4=""; print $0 }' > $plugintmp
  fi
  plugins=`cat $plugintmp`
  if [[ -z $plugins ]]; then
    screen -S bukkit-server -p 0 -X eval 'stuff '"plugins"'\015'
    grep "Plugins" $slog |head -1 |awk '{ $1=""; $2=""; $3=""; $4=""; print $0 }' > $plugintmp
    plugins=`cat $plugintmp`
    while [[ -z $plugins ]]; do
      sleep 1
      grep "Plugins" $slog |head -1 |awk '{ $1=""; $2=""; $3=""; $4=""; print $0 }' > $plugintmp
      plugins=`cat $plugintmp`
    done
  fi
}

 getDone () {
     donetmp=`mktemp "/tmp/donetmp-$abmid.XXXXXX"`
     grep "Done ([0-9]\{1,\}\.[0-9]\{1,\}s)\!" $slog | awk '{print $5}' | sed 's/(//g;s/)//g;s/!//g' > $donetmp
     doneTime=`cat $donetmp`
     rm -f $donetmp
 }

mqConnect () {
  exec 3<>/dev/tcp/localhost/25566
  echo -e "QUERY" >&3
  cat <&3
}

abmSessions () {
  # Count Up ABM Sessions on Server. Both Active and Inactive.
  abmstmp=`mktemp "/tmp/abmstmp-$abmid.XXXXXX"`
  screen -ls |grep [0-9]*.abm-[0-9]* > $abmstmp
  abmAttached=`grep [0-9]*.abm-[0-9]* $abmstmp | grep "(Attached)" | wc -l`
  abmDetached=`grep [0-9]*.abm-[0-9]* $abmstmp | grep "(Detached)" | wc -l`
  rm -f $abmstmp
}

killdefunctABM () {
  for i in `screen -ls |grep [0-9]*.abm-[0-9]*|grep "(Detached)"|cut -d "." -f 1`; do 
    echo "Killing Session:" $i
    kill $i
    sleep 1
  done
}

# This is the main info showed in status.sh
showInfo () {
  checkServer
  if [[ -f $abmdir/include/temp/latestabm ]]; then
    latestabm=`cat $abmdir/include/temp/latestabm`
  elif [[ ! -f $abmdir/include/temp/latestabm ]]; then
    wget --quiet -r http://bit.ly/vvizIg -O  $abmdir/include/temp/latestabm
  fi
  load=`uptime|awk -F"average: " '{print $2}'` # Cut everthing after "average:"
  topinfo=`mktemp "/tmp/topinfo-$abmid.XXXXXX"`
  getTop=`top -n 1 -b > $topinfo`
  freeinfo=`mktemp "/tmp/freeinfo-$abmid.XXXXXX"`
  getFree=`free -m > $freeinfo`
  # Count Amount of Running ABM sessions.
  abmSessions
  if [[ $bukkitPID ]]; then
    bukkitCpuTop=`grep $bukkitPID $topinfo |awk -F" " '{print $9}'`
    bukkitMemTop=`grep $bukkitPID $topinfo |awk -F" " '{print $10}'`
  fi
  # Get information from SAR
  if [[ $sarbin ]]; then
    if [[ -z $eth ]]; then
      eth=`netstat -rn |grep 0.0.0.0 |head -n 1 |awk '{print $8}'`
      sed -e "s/eth=/&$eth/g" -i $abmconfig
    fi
    sarinfo=`mktemp "/tmp/sarinfo-$abmid.XXXXXX"`
    getSar=`sar -n DEV 1 1 |grep $eth |grep -v "Average:"|grep -v lo|awk '{print $6,$7}' > $sarinfo`
    netrx=`awk {'print $1'} $sarinfo`
    nettx=`awk {'print $2'} $sarinfo`
  fi
  totalCpuTop=`grep Cpu $topinfo | cut -d ":" -f 2`
  totalMem=`sed -n 2p $freeinfo |awk '{print $2}'`
  totalMemUsed=`sed -n 2p $freeinfo |awk '{print $3}'`
  totalMemFree=`sed -n 2p $freeinfo |awk '{print $4}'`
  totalSwap=`sed -n 4p $freeinfo |awk '{print $2}'`
  totalSwapUsed=`sed -n 4p $freeinfo |awk '{print $3}'`
  totalSwapFree=`sed -n 4p $freeinfo |awk '{print $4}'`
  diskuse=`df -h $bukkitdir|grep -e "%" |grep -v "Filesystem"|grep -o '[0-9]\{1,3\}%'`
  stime=`date`
  # Check for MineQuery Plugin & Set $playerCount & $players
  if [[ -f "$bukkitdir/plugins/Minequery.jar" ]]; then
    mineQueryinfo=`mktemp "/tmp/minequeryinfo-$abmid.XXXXXX"`
    mqConnect > $mineQueryinfo
    players=`grep PLAYERLIST $mineQueryinfo | grep PLAYERLIST | awk -F"PLAYERLIST" '{print $2}'|sed -e 's/^[ \t]*//'`
    playerCount=`grep PLAYERCOUNT $mineQueryinfo | grep PLAYERCOUNT|awk -F "PLAYERCOUNT" '{print $2}'`
    rm -f $mineQueryinfo
  fi
  clear
  echo -e $txtbld"Ascii Bukkit Menu: "$txtrst$abmversion$txtbld "Session ID: "$txtrst$abmid
  if [[ -n "$latestabm" ]]; then
    if [[ "$latestabm" > "$abmversion" ]]; then
      echo -e $txtred"Update Availible:" $latestabm $txtrst
    fi
  fi
  echo -e $txtbld"Sessions Active: "$txtrst$abmAttached$txtbld" Inactive: "$txtrst$abmDetached
  echo
  echo -e $txtbld"Bukkit Server Info"$txtrst
  if [[ $bukkitPID ]]; then
       uptime=`ps -p $bukkitPID -o stime|grep -v STIME`
    if [[ -z $doneTime ]]; then
      getDone
    fi
    if [[ $doneTime ]]; then
      echo -e $txtgrn"Online "$txtrst$txtbld"PID: "$txtrst$bukkitPID$txtbld" StartUp Time: "$txtrst$doneTime$txtbld" Start Time: "$txtrst$uptime
    else
      echo -e $txtgrn"Online "$txtrst$txtbld"PID: "$txtrst$bukkitPID$txtbld" StartUp Time: "$txtrst"Loading..."$txtbld" Start Time: "$txtrst$uptime  
    fi
  fi
  if [[ -z $bukkitPID ]]; then
    echo -e $txtred"Offline" $txtrst
  fi
  craftbukkit=$bukkitdir/$cbfile
  if [ ! -f $craftbukkit ]; then
    echo -e $txtred"Not Installed"$txtrst
    echo -e $txtred"Choose: Advanced (9) Update Bukkit (1)"$txtrst
    echo -e "If this is your first time installing"
    echo -e "Bukkit, then it is recommended"
    echo -e "you restart ABM after install."
    echo
  fi
  if [[ $bukkitPID ]]; then
     if [[ -z $doneTime ]]; then
      getDone
    else
        getVersion
        getPlugins
        echo -e $txtbld"Build:"$txtrst $build
        echo -e $txtbld"Plugins"$txtrst $plugins
     fi
        echo -e $txtbld"CPU Usage:"$txtrst $bukkitCpuTop"%"
        echo -e $txtbld"Mem Usage:"$txtrst $bukkitMemTop"%"
        echo -e $txtbld"Connected Players:"$txtrst $playerCount $players
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
