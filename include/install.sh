#!/bin/bash
latest=`wget -O - -q http://www.digitalammo.org/abm/VERSION`

installLocation () {
echo
echo "Please enter the absolute path to install location."
echo "A subdirectory called Ascii-Bukkit-Menu will be placed in this path."
echo "Example: /opt/craftbukkit"
echo
read -p  "Install Path: " installpath
}

setupConfig () {
clear
echo
echo "----==== ABM Configuration Setup Script ====----"
echo
echo "If you decide not to answer a question, defaults will be used."
echo
echo "Please enter the absolute path to your Bukkit installation."
echo "Example: /opt/craftbukkit"
echo
read -p "Bukkit Path: " bukkitdir

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
        echo "Please edit config manually $installpath/Ascii-Bukkit-Menu/config"
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
echo "Bukkit Directory: "$bukkitdir
echo "Java Arguments: "$jargs
echo "Display Refresh: "$tick
echo "RamDisk Used: "$ramdisk
echo "RamDisk Worlds: " $worlds
echo
read -p "Use this Config? [Y/N] " answer
if [[ $answer =~ ^(yes|y)$ ]]; then

cat > "$installpath/Ascii-Bukkit-Menu/include/config" <<EOF
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
worlds=($worlds)
EOF
clear
echo "$installpath/Ascii-Bukkit-Menu/include/config written successfully"
 
  elif  [[ $answer =~ ^(no|n)$ ]]; then
    echo
    read -p "Would you like to run setup again? [Y/N] " answer
      if [[ $answer =~ ^(yes|y)$ ]]; then
        setupConfig
      elif  [[ $answer =~ ^(no|n)$ ]]; then 
        echo "Please edit config manually $installpath/Ascii-Bukkit-Menu/include/config"
      fi
fi
}

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
echo "This script will install Ascii Bukkit Menu."
read -p "Enter To Proceed, Control+C to Quit."

echo "Downloading ABM..."
wget --progress=bar http://dev.bukkit.org/media/files/552/980/abm-0.1.7.zip  -O abm-$latest.zip
echo "Download Complete."

installLocation

if [[ -z $installpath ]]; then
	echo "Error, no path set. Please try again."	
	echo $installpath
	installLocation
fi

if [[ -a $installpath/Ascii-Bukkit-Menu/include/config ]]; then
	echo
	echo "Existing config found, backing up.."
	echo 
	cp -v $installpath/Ascii-Bukkit-Menu/include/config $installpath/Ascii-Bukkit-Menu/include/config.bak
	echo "Backup Complete."
	echo
fi

unzip -o abm-$latest.zip -d $installpath
rm abm-$latest.zip

echo 
echo "Would you like to create a new ABM config now?"
echo
read -p "[Y/N] " answer 
echo
  if [[ $answer =~ ^(yes|y)$ ]]; then
    setupConfig
  elif [[ $answer =~ ^(no|n)$ ]]; then
  echo 
  echo "Ascii Bukkit Menu installed to $installpath/Ascii-Bukkit-Menu"
    if [[ -a $installpath/Ascii-Bukkit-Menu/include/config.bak ]]; then
      echo
      echo "Restoring config from backup.."
      cp -v $installpath/Ascii-Bukkit-Menu/include/config.bak $installpath/Ascii-Bukkit-Menu/include/config
      echo
      echo "Restore Complete."
      echo "Backup of config located at:"
      echo "$installpath/Ascii-Bukkit-Menu/include/config.bak"
      echo
    else 
      echo "Please edit $installpath/Ascii-Bukkit-Menu/include/conf"
  fi
fi

  echo
  echo "Thanks for choosing Ascii Bukkit Menu!"
  echo "http://bit.ly/vRiHKH"
  echo

read -p "Would you like to launch ABM now? [Y/N] " answer
  if [[ $answer =~ ^(yes|y)$ ]]; then
    cd $installpath/Ascii-Bukkit-Menu/
    exit 0& ./start.sh
  elif [[ $answer =~ ^(no|n)$ ]]; then
    exit 0
  fi
exit 0
