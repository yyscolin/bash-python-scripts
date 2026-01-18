#!/bin/bash

if [ "$1" == "" ]; then
  echo Error: No profile specified
  exit 1
fi

SCRIPT_DIR="$(dirname -- "${BASH_SOURCE[0]}")"
PROFILE_FILE="$SCRIPT_DIR/profiles/rsynker.$1.sh"
if [ ! -f "$PROFILE_FILE" ]; then
  echo Error: Profile file not found: \"$PROFILE_FILE\"
  exit 1
fi

source $PROFILE_FILE

for disk in $DISKS; do
  status=$(/usr/sbin/smartctl -H $disk|grep "^SMART overall-health self-assessment test result:"|cut -d: -f2)
  if [ "$status" == "" ]; then
    message="$message\nUnable to get SMART OHSA test result for $disk"
  elif [ $status != PASSED ]; then
    message="$message\nSMART OHSA test result for $disk: $status"
  fi
done

if [ "$message" != "" ]; then
  time=$(date "+%F %T")
  api_url=https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage
  message="$HOSTNAME @$time$message"
  payload='{"chat_id":'$TELEGRAM_CHATID',"text":"'$message'"}'
  curl -X POST -H "Content-Type:application/json" -d "$payload" $api_url
fi
