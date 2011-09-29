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
MCPID=`ps -ef |grep -i craftbukkit-0.0.1-SNAPSHOT.jar |grep -v grep |awk '{ print $2 }'`
flags=`ps -ef |grep -i craft |egrep -v "grep|tail|wget"|sed s'/^.*java/java/'`
load=`uptime |cut -f 14-16 -d " "`
bukkitcpu=`ps -e -o pcpu,cpu,nice,state,cputime,args --sort pcpu | sed '/^ 0.0 /d'|grep -i craftbukkit-0.0.1-SNAPSHOT.jar|cut -d " " -f1-2`
memuse=`free -m |grep 'Mem' |awk '{print $1," | " $2," | " $3," | " $4}'`
swapuse=`free -m |grep 'Swap' |awk '{print $1,"| " $2,"|"" "$3,"   | " $4}'`
diskuse=`df -h $bukkitdir|grep -e "%" |grep -v "Filesystem"|grep -o '[0-9]\{1,3\}%'`
plugins=`ls $bukkitdir/plugins/|grep .jar |sed 's/\(.*\)\..*/\1/'`
cpuinfo=`cat /proc/cpuinfo|grep 'model name' |cut -f2 -d ":"|cut -f 1-6 -d " "|head -1`
cpumhz=`cat /proc/cpuinfo|grep 'cpu MHz' |cut -f2 -d ":"|head -1`

clear
  if [ $MCPID ]; then
    uptime=`ps -p $MCPID -o stime|grep -v STIME`
    echo -e $txtgrn"Bukkit Running$txtrst Since: "$uptime
  elif [ -z $MCPID ]; then 
    echo -e $txtred"Bukkit Not Running" $txtrst
  fi
echo -e $txtbld"Version:"$txtrst $version
newversion=`grep "lastBuildDate" include/latest_recommended.rss |cut -f 17 -d ">" |sed 's/<\/title//g'|cut -f3 -d " "`
if [ -n "$version"  ];then
if [ "$newversion" -gt "$version" ]; then
echo -e $txtred"Update Availible:" $newversion $txtrst
fi
fi
echo -e $txtbld"Start Flags:"$txtrst $flags
# echo -e $txtbld"Connected Players: X" #--Not Yet Implemented
echo -e $txtbld"Plugins:"$txtrst $plugins
echo -e " "
echo -e $txtbld"System Info:"$txtrst
echo -e "Hostname:" $hostname
echo -e "CPU Make:" $cpuinfo
echo -e "CPU Speed:" $cpumhz "MHz" 
echo -e "Bukkit CPU Usage:" $bukkitcpu"%" 
echo -e "Memory Usage:"
echo -e "Megabytes    Total   Used   Free "
echo -e "     $memuse  |"
echo -e "     $swapuse |"
echo -e "Disk Usage:" $diskuse
echo -e "Load:" $load
echo -e ""
echo -e "Server Time:" 
date
}

checkUpdate () {
lastup=`cat include/update`
if [ $lastup -lt `date "+%y%m%d"` ]; then 
echo -e $txtred"Checking for Bukkit Update..."
wget --quiet -m -nd -P include/ http://ci.bukkit.org/other/latest_recommended.rss
date "+%y%m%d" > include/update
sleep 2 
newversion=`grep "lastBuildDate" include/latest_recommended.rss |cut -f 17 -d ">" |sed 's/<\/title//g'|cut -f3 -d " "`
#rm include/latest_recommended.rss
fi
}

checkUpdate
while true
  do
	showInfo
	sleep 5
  done
