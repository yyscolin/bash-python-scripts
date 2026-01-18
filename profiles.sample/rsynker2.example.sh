#!/bin/bash
ROOT_DIR=$HOME/example
BACKUP_DIRS=(
  192.168.0.10:example
  192.168.0.20:example
  192.168.0.30:example
  192.168.0.40:example
)
LOG_FILE=/var/log/rsynker2/example.$(date +%Y-%m-%d).log
