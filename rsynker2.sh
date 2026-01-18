#!/bin/bash


rsync_sync(){
  log_dir="$(dirname "$LOG_FILE")"
  mkdir -p "$log_dir"

  rsync -av --delete $3\
    --delete-after\
    --exclude=.angular/\
    --exclude=.DS_Store\
    --exclude=.localized\
    --exclude=.Trash-1000/\
    --exclude=.vscode/\
    --exclude=__pycache__/\
    --exclude=node_modules/\
    --exclude=venv/\
    --log-file="$LOG_FILE"\
    "$1" "$2"
}


SCRIPT_DIR="$(dirname -- "${BASH_SOURCE[0]}")"
if [ "$1" == "" ]; then
  echo Error: No profile specified
  exit 1
fi

PROFILE_FILE="$SCRIPT_DIR/profiles/rsynker2.$1.sh"
if [ ! -f "$PROFILE_FILE" ]; then
  echo Error: Profile file not found: \"$PROFILE_FILE\"
  exit 1
fi

source $PROFILE_FILE

operation="$2"
subfolder="${3%/}/"

ROOT_DIR="${ROOT_DIR%/}/" # add trailing / if not exists
ROOT_DIR="$ROOT_DIR$subfolder"
if [ ! -d "$ROOT_DIR" ]; then
  echo Error: Root directory does not exists: \"$ROOT_DIR\"!
  exit 1
fi

if [ "$operation" == "" ]; then
  echo Error: No operation given!
  exit 1
fi

if [ "$operation" != "push" ] && [ "$operation" != "pull" ]; then
  echo Error: Invalid operation: \"$operation\"!
  exit 1
fi

echo "Choose the remote directory:"
for i in "${!BACKUP_DIRS[@]}"; do
  echo "$((i + 1)). ${BACKUP_DIRS[i]}"
done

read -p "Your choice (default=1): " option_num
if [[ ! $option_num =~ ^-?[0-9]+$ ]]; then
  echo "Error: Invalid option!"
  exit 1
fi
((option_num--))

backup_dir="${BACKUP_DIRS[option_num]}"
if [ "$backup_dir" == "" ]; then
  echo "Error: Invalid option!"
  exit 1
fi
backup_dir="${backup_dir%/}/$subfolder"

if [ "$operation" == "push" ]; then
  source="$ROOT_DIR"
  target="$backup_dir"
else
  source="$backup_dir"
  target="$ROOT_DIR"
fi

echo
read -p "Would you like to perform a dry run? (y|n, default=y): " input_option
option_lowercase="${input_option,}"
if [ "$option_lowercase" == "" ] || [ "$option_lowercase" == y ]; then
  rsync_sync "$source" "$target" --dry-run

  echo
  read -p "Continue to $operation? (y|n, default=y): " input_option
  option_lowercase="${input_option,}"
  if [ "$option_lowercase" == n ]; then
    exit 0
  elif [ "$option_lowercase" != "" ] && [ "$option_lowercase" != y ]; then
    echo "Invalid option: $input_option"
    exit 1
  fi
elif [ "$option_lowercase" != n ]; then
  echo "Invalid option: $input_option"
  exit 1
fi

rsync_sync "$source" "$target" --progress
