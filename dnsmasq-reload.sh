#!/bin/bash

IPs=(192.168.X.50 192.168.Y.50)
PORT=1234
HOST_FILE=/path/to/host/file # File content: "192.168.Z.50 <HOST_NAME>"
HOST_NAME=example.com
LOG_FILE=/path/to/log/file.log

for ip_address in "${IPs[@]}"; do
  if nc -z -w 2 $ip_address $PORT; then
    current_ip=$(cat $HOST_FILE|cut -d" " -f1)
    if [ $current_ip != $ip_address ]; then
      echo "$ip_address $HOST_NAME" > $HOST_FILE
      sudo systemctl reload dnsmasq.service

      timedate=$(date '+%Y-%m-%d %H:%M:%S')
      log_entry="$timedate Updated $HOST_NAME from $current_ip to $ip_address"
      echo "$log_entry" >> $LOG_FILE
    fi
    exit 0
  fi
done
