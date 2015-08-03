#!/bin/bash

# Alex Haslehurst - https://github.com/axle-h
# Client for updating free.afraid.org dynamic dns service by monitoring uPNP.

ipregex="(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
token="TOP_SECRET"
logfile=/tmp/dns-update.log

# Get last ip address logged
if [ -f $logfile ]; then
  cacheIp=$(tail -n 1 $logfile | cut -d '-' -f 2 | tr -d ' ' |  grep -Eo "$ipregex" | head -n 1)
fi

# Get external ip from IGD
ip=$(upnpc -s | grep ExternalIPAddress | sed 's/[^0-9\.]//g')
log="`date` -"

if [ -z "$ip" ]; then
  log="$log Cannot get ip from uPNP"
else
  log="$log $ip -"
  if [ "$ip" = "$cacheIp" ]; then
    log="$log Update not required"
  else
    echo "Updating free.afraid.org with" $ip
    result=$(curl -qsk http://freedns.afraid.org/dynamic/update.php?$token&address=$ip)
    log="$log $result"
  fi
fi

echo "$log" >> $logfile
