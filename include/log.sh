#!/bin/bash
source include/config
head -10 $bukkitdir/server.log
tail -f $bukkitdir/server.log
