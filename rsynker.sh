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

basename=`basename "$0"`
process_count=$(pgrep -cf "$rsynker.$1.sh")
[ $process_count -gt 1 ] && exit 0

excludes=$(cat "$PROFILE_FILE"|grep ^EXCLUDE=|grep -v ^EXCLUDE=$|sed s/^EXCLUDE/--exclude/)
if [ "$IS_DRYRUN" == true ]; then
  rsync -avns --delete -e "ssh -p $BACKUP_PORT" $excludes "$SOURCE_DIR" "$BACKUP_DIR"
  exit 0
fi

first_item=$(rsync -avns --delete -e "ssh -p $BACKUP_PORT" $excludes "$SOURCE_DIR" "$BACKUP_DIR"|head -n2|tail -n1)
[ "$first_item" == "" ] && exit

rsync -as --delete -e "ssh -p $BACKUP_PORT" --log-file="$LOG_FILE" $excludes "$SOURCE_DIR" "$BACKUP_DIR"
