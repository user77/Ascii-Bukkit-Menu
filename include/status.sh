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

hostname=`hostname`

showInfo () {
  version=`grep -m 1 "Craftbukkit version" $bukkitdir/server.log |cut -f 10-12 -d " "|cut -f6 -d "-" |cut -f1 -d " "|sed 's/[a-zA-Z]*//g'`
  MCPID=`ps -ef |grep -i craftbukkit-0.0.1-SNAPSHOT.jar |grep -v grep |grep -v wget |awk '{ print $2 }'`
  load=`uptime|awk -F"average:" '{print $2}'` # Cut everthing after "average:"
  totalCpu=`ps aux | awk '{sum +=$3}; END {print sum}'`
  totalMem=`ps aux | awk '{sum +=$4}; END {print sum}'`
  bukkitCpu=`ps aux | grep -i craftbukkit-0.0.1-SNAPSHOT.jar|grep -v grep| awk '{sum +=$3}; END {print sum}'`
  bukkitMem=`ps aux | grep -i craftbukkit-0.0.1-SNAPSHOT.jar|grep -v grep| awk '{sum +=$4}; END {print sum}'`
  diskuse=`df -h $bukkitdir|grep -e "%" |grep -v "Filesystem"|grep -o '[0-9]\{1,3\}%'`
  plugins=`ls $bukkitdir/plugins/|grep .jar |sed 's/\(.*\)\..*/\1/'`
  stime=`date`
  # Check for MineQuery Plugin & Set $players 
  if [[ -f "$bukkitdir/plugins/Minequery.jar" ]]; then
    players=`echo "QUERY" |nc localhost 25566 |grep PLAYERLIST|awk -F"PLAYERLIST" '{print $2}'|sed -e 's/^[ \t]*//'`
  fi
  clear
  echo -e $txtbld"Bukkit Server Info:"$txtrst
  if [[ $MCPID ]]; then
    uptime=`ps -p $MCPID -o stime|grep -v STIME`
    echo -e $txtgrn"Running$txtrst Since: "$uptime
  elif [[ -z $MCPID ]]; then
    echo -e $txtred"Not Running" $txtrst
  fi
  echo -e $txtbld"Version:"$txtrst $version
  newversion=`grep "lastBuildDate" include/latest_recommended.rss |cut -f 17 -d ">" |sed 's/<\/title//g'|cut -f3 -d " "`
  if [[ -n "$version" ]]; then
    if [[ "$newversion" -gt "$version" ]]; then
      echo -e $txtred"Update Availible:" $newversion $txtrst
    fi
  fi
  echo -e $txtbld"Java Flags:"$txtrst $jargs 
  echo -e $txtbld"Plugins:"$txtrst $plugins
  echo -e $txtbld"CPU Usage:"$txtrst $bukkitCpu"%"
  echo -e $txtbld"Mem Usage:"$txtrst $bukkitMem"%"
  if [[ $players ]]; then
    echo -e $txtbld"Connected Players:"$txtrst $players
  fi
  echo 
  echo -e $txtbld"System Info:"$txtrst
  echo -e $txtbld"Hostname:"$txtrst $hostname
  echo -e $txtbld"CPU Usage:"$txtrst $totalCpu"%"
  echo -e $txtbld"Mem Usage:"$txtrst $totalMem"%"
  echo -e $txtbld"Disk Usage:"$txtrst $diskuse
  echo -e $txtbld"Load:"$txtrst $load
  echo -e $txtbld"Time:"$txtrst $stime
}

# Check for Bukkit Update once a day
checkUpdate () {
  lastup=`cat include/update`
  if [[ $lastup -lt `date "+%y%m%d"` ]]; then
    echo -e $txtred"Checking for Bukkit Update..."$txtrst
    wget --quiet -m -nd -P include/ http://ci.bukkit.org/other/latest_recommended.rss
    date "+%y%m%d" > include/update
    sleep 2 
    newversion=`grep "lastBuildDate" include/latest_recommended.rss |cut -f 17 -d ">" |sed 's/<\/title//g'|cut -f3 -d " "`
  fi
}

#Check for update daily on first startup
checkUpdate

# Loop and display status information
while [[ true ]]; do
  showInfo
  # Set screen refresh variable in include/conf
  sleep $tick
done
