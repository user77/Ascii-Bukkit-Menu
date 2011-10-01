#!/bin/bash

# Read Config File
source include/config

# Put somthing into log window so its not empty.
head -10 $bukkitdir/server.log

# Watch Bukkit Log in screen window Bukkit_Log
tail -f $bukkitdir/server.log