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
          mkdir $logs
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
###### Add screen.config at later date. #####
clear
echo
echo "----==== ABM Configuration Setup ====----"
echo
echo "This will guide you through the setup for Ascii Bukkit Menu."
echo "If you decide not to answer a question, defaults will be used."
echo
echo "Please enter the absolute path to your Bukkit installation."
echo "Example: /opt/craftbukkit"
echo
read -p "Bukkit Path: " bukkitdir

read -p "Would you like Bukkit Latest or Recommended? [l/r] " bbuild
  if [[ $bbuild =~ ^(latest|l)$ ]]; then
    echo
    echo "Latest Bukkit build selected."
    bbuild=latest
  elif [[ $bbuild =~ ^(recommended|r)$ ]]; then
    echo
    echo "Recommended Bukkit build selected."
    bbuild=recommended
  else
    echo "Invalid Selection, assuming Recommended."
    bbuild=recommended
  fi

echo
echo "Please add any Java arguments you would like. Seperated by space."
echo "For a complete list, please see: http://bit.ly/mYKJte"
echo "Default: -Xincgc -Xmx1g"
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
read -p "[Y/N] " ramdisk
  if [[ $ramdisk =~ ^(yes|y)$ ]]; then
    echo
    echo "Please enter the names of the worlds that should be copied to and from ramdisk to localdisk"
    echo "Use exact names as they show in $bukkitdir separated by space."
    echo
    read -p "Worlds: " worlds
  fi

# End of Questions. Time to check for missing variables.

  if [[ -z $bukkitdir ]]; then
    echo
    echo "Error no Bukkit directory set."
    read -p "Would you like to run setup again? [Y/N] " answer
      if [[ $answer =~ ^(yes|y)$ ]]; then
        setupConfig
      else 
        echo
        echo "Please edit config manually $abmconfig"
      fi
  fi
  
  if [[ -z $jargs ]]; then
    echo
    echo "No Java Arguments set, using defaults.."
    jargs="-Xincgc -Xmx1g"
  fi

  if [[ -z $tick ]]; then
    echo
    echo "Refresh not set, using default.."
    tick=5
  fi

  if [[ -z $ramdisk ]]; then
    echo
    echo "Ramdisk not set, using default.."
    ramdisk=false
  fi

  if [[ $ramdisk =~ ^(yes|y)$ ]]; then
    ramdisk=true
  fi

  if [[ $ramdisk =~ ^(no|n)$ ]]; then
    ramdisk=false
  fi

  if [[ $ramdisk = "true" ]]; then
    if [[ -z $worlds ]]; then
      echo
      echo "Ramdisk Worlds not set. Please try again.."
      read -p "Would you like to run setup again? [Y/N] " answer
        if [[ $answer =~ ^(yes|y)$ ]]; then
          setupConfig
        fi
    fi
  fi
clear
echo
echo "Please review:"
echo
echo "Bukkit Build Tree: "$bbuild
echo "Bukkit Directory: "$bukkitdir
echo "Java Arguments: "$jargs
echo "Display Refresh: "$tick
echo "RamDisk Used: "$ramdisk
echo "RamDisk Worlds: " $worlds
echo
read -p "Use this Config? [Y/N] " answer
if [[ $answer =~ ^(yes|y)$ ]]; then

cat > "$abmdir/include/config/abm.conf" <<EOF
abmversion=0.2.2
#Bukkit Build Tree latest or recommended
bbuild=$bbuild

# Absolute path to your bukkit installation. Example:
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
EOF
clear
echo "$abmconfig written successfully"
 
  elif  [[ $answer =~ ^(no|n)$ ]]; then
    echo
    read -p "Would you like to run setup again? [Y/N] " answer
      if [[ $answer =~ ^(yes|y)$ ]]; then
        setupConfig
      elif  [[ $answer =~ ^(no|n)$ ]]; then 
        echo "Please edit config manually $abmconfig"
      fi
fi
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
sessionname abm
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
sessionname abm
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
sessionname abm
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
        MCPID=`ps -ef |grep -i craftbukkit-* |grep -v grep |awk '{ print $2 }'`
}

# Update Bukkit to Latest.
update () {
	if [ $bbuild = "latest" ]; then
	  wget -m -nd -P $abmdir/include/temp http://ci.bukkit.org/job/dev-CraftBukkit/lastSuccessfulBuild/
    ver=`grep -o 'artifact/target/[^"]*' $abmdir/include/temp/index.html |head -1`
	  bukkiturl="http://ci.bukkit.org/job/dev-CraftBukkit/lastSuccessfulBuild/$ver"
	elif [ $bbuild = "recommended" ]; then
	      ver=`awk 'NR==2' /opt/minecraft/Ascii-Bukkit-Menu/include/temp/latest_recommended.rss |tr '\076\074' '\076\012\074' | grep "title>" | grep "Build:" | cut -d\> -f2 |awk '{ print $3}'`
	      link=`awk 'NR==2' /opt/minecraft/Ascii-Bukkit-Menu/include/temp/latest_recommended.rss |tr '\076\074' '\076\012\074' | grep "link>http:" | cut -d\> -f2|grep -v "http://www.bukkit.org"`
	      bukkiturl="$link/artifact/target/craftbukkit-$ver.jar"
	fi
        stopServer
        # Download Latest. Remove old, download latest.
        rm $bukkitdir/$cbfile
        wget -m -nd --progress=dot:mega -P $bukkitdir $bukkiturl
        cat /dev/null > $bukkitdir/server.log
	      getBuild
        clear
        if [ $craftbukkit ]; then
          echo $txtgrn"Update Successful!"$txtrst
          sleep 2
        fi
        startServer
}

#Unzip MANIFEST.MF, store build number for referance later. Should only be done on new install or update.
getBuild () { 
unzip $bukkitdir/$cbfile "META-INF/MANIFEST.MF" -d $abmdir/include/temp > /dev/null
grep "Implementation-Version" $abmdir/include/temp/META-INF/MANIFEST.MF |awk '{print $2}'> $abmdir/include/temp/build
rm -rf $abmdir/include/temp/META-INF
}

# Install MineQuery Plugin. Restart Server.
installmq () {
        clear
        wget -m -nd --progress=dot:mega -P $abmdir/include/temp/ https://github.com/downloads/vexsoftware/minequery/Minequery-1.5.zip
        unzip -o $abmdir/include/temp/Minequery-1.5.zip -d $bukkitdir/plugins
        rm $abmdir/include/temp/Minequery-1.5.zip
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
                            echo $txtred "#### Warning! #### Warning! ####" $txtrst
                            echo "MD5 Check Failed for $x"
                            echo "Please investigate."
                            read -p "Hit any key to continue..."
                            clear
                            elif [ -z "$md5" ]; then
                            echo $txtgrn "Copied $x from local disk to ram disk sucessully!" $txtrst
                            sleep 2
                            clear
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
		read -p "Confirm Shutdown. [Y/N] " answer
		if [[ $answer =~ ^(yes|y)$ ]]; then
                screen -S bukkit-server -p 0 -X eval 'stuff "save-all"\015'
                screen -S bukkit-server -p 0 -X eval 'stuff "stop"\015'
                while [[ $MCPID ]]; do
                        echo "Bukkit Shutdown in Progress.."
                        checkServer
                clear
                done
                if [ $ramdisk = true ]; then
                  read -p "Would you like copy from ram disk to local disk? [Y/N] " answer
                    if [[ $answer =~ ^(yes|y)$ ]]; then
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
		fi
        fi
}

restartServer () {
  stopServer
if [ -z $MCPID ]; then
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

# Quit Function
quitFunction () {
        clear
        #$txtrst
        kill $menuscreenpid
        exit 0
}

# This is the main info showed in status.sh
showInfo () {
  checkServer
  latestabm=`cat $abmdir/include/temp/latestabm`
  build=`cat $abmdir/include/temp/build`
  load=`uptime|awk -F"average:" '{print $2}'` # Cut everthing after "average:"
if [[ $MCPID ]]; then
  bukkitCpuTop=`top -n 1 -b -p $MCPID |grep $MCPID |awk -F" " '{print $9}'`
  bukkitMemTop=`top -n 1 -b -p $MCPID |grep $MCPID |awk -F" " '{print $10}'`
fi
  totalCpuTop=`top -n 1 -b |grep Cpu | cut -d ":" -f 2`
  totalMem=`free -m |sed -n 2p|awk '{print $2}'`
  totalMemUsed=`free -m |sed -n 2p|awk '{print $3}'`
  totalMemFree=`free -m |sed -n 2p|awk '{print $4}'`
  diskuse=`df -h $bukkitdir|grep -e "%" |grep -v "Filesystem"|grep -o '[0-9]\{1,3\}%'`
  plugins=`ls $bukkitdir/plugins/|grep .jar |sed 's/\(.*\)\..*/\1/'`
  stime=`date`
  # Check for MineQuery Plugin & Set $players
  if [[ -f "$bukkitdir/plugins/Minequery.jar" ]]; then
    players=`echo "QUERY" |nc localhost 25566 |grep PLAYERLIST|awk -F"PLAYERLIST" '{print $2}'|sed -e 's/^[ \t]*//'`
  fi
  clear
  echo -e $txtbld"Ascii Bukkit Menu"$txtrst
  echo -e $txtbld"Version:"$txtrst $abmversion
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
    cat /dev/null > $abmdir/include/temp/build 
    echo -e $txtred"Not Installed"$txtrst
    echo -e $txtred"Choose Option 5 to install"$txtrst
  fi
  echo -e $txtbld"Build:"$txtrst $build

   # if [ $bbuild = "latest" ]; then
      #newbuild=`grep "lastBuildDate" $abmdir/include/temp/latest_recommended.rss |cut -f 17 -d ">" |sed 's/<\/title//g'|cut -f3 -d " "`
    #elif [ $bbuild = "recommended" ]; then
      #newbuild=`awk 'NR==2' /opt/minecraft/Ascii-Bukkit-Menu/include/temp/latest_recommended.rss |tr '\076\074' '\076\012\074' | #grep "title>" | grep "Build:" | cut -d\> -f2 |awk '{ print $3}'`
    #fi

#  if [[ -n "$build" ]]; then
#    if [[ "$newbuild" -gt "$build" ]]; then
#      echo -e $txtred"Update Availible:" $newbuild $txtrst
#    fi
#  fi
  echo -e $txtbld"Java Flags:"$txtrst $jargs
  echo -e $txtbld"Plugins:"$txtrst $plugins
  #echo -e $txtbld"CPU Usage ps:"$txtrst $bukkitCpuPs"%"
if [[ $MCPID ]]; then
  echo -e $txtbld"CPU Usage:"$txtrst $bukkitCpuTop"%"
  #echo -e $txtbld"Mem Usage ps:"$txtrst $bukkitMemPs"%"
  echo -e $txtbld"Mem Usage:"$txtrst $bukkitMemTop"%"

  if [[ $players ]]; then
    echo -e $txtbld"Connected Players:"$txtrst $players
  fi
fi
  echo
  echo -e $txtbld"System Info"$txtrst
  echo -e $txtbld"Hostname:"$txtrst $hostname
  echo -e $txtbld"CPU Usage:"$txtrst $totalCpuTop
  echo -e $txtbld"Mem Usage:"$txtrst "Total:" $totalMem"MB" "Used:" $totalMemUsed"MB"  "Free:" $totalMemFree"MB"

  echo -e $txtbld"Disk Usage:"$txtrst $diskuse
  echo -e $txtbld"Load:"$txtrst $load
  echo -e $txtbld"Time:"$txtrst $stime
}


# Check for Bukkit Update once a day
checkUpdate () {
  lastup=`cat $abmdir/include/config/update`
  if [[ $lastup -lt `date "+%y%m%d"` ]]; then
    echo -e $txtred"Checking for Bukkit and ABM Update..."$txtrst
    getBuild 
    wget --quiet -r http://bit.ly/tTI6g8 -O  $abmdir/include/temp/latest_recommended.rss
    wget --quiet -r http://bit.ly/vvizIg -O  $abmdir/include/temp/latestabm
    date "+%y%m%d" > $abmdir/include/config/update
    sleep 2
    newbuild=`grep "lastBuildDate"  $abmdir/include/temp/latest_recommended.rss |cut -f 17 -d ">" |sed 's/<\/title//g'|cut -f3 -d " "`
   latestabm=`cat $abmdir/include/temp/latestabm`
  fi
}
