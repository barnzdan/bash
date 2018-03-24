#!/usr/bin/env bash

#
# archive the movie files to archive directory
#
PLEX="/var/mnt/Plex Media Server/Movies/"

echo "Archiving movie files..."

sudo rsync -avzh "$PLEX" /var/docker/archive/

if [ $? -eq "0" ]; then
  echo "Archive successful."
  exit 0
else
  echo "Archive failed."
  exit 1
fi
