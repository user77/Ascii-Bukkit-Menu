#!/bin/bash
source include/config
if [ -z $bukkitdir ];then
 echo "Plese Edit include/config.."
else
screen -c include/screen.conf
fi
