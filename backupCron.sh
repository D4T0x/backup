#!/bin/bash

#$1 -> Directory to do backup
name=$(echo $(basename $1)-$(date '+%y%m%d-%H%M'))
tar -czf /backups/$name.tar.gz $1
echo "A backup of directory $1 has been done on $(date '+%F') at $(date '+%H:%M')." >> /backups/backup.log