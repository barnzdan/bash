#!/usr/bin/env bash

#
#set -x
#

ARCHIVE=/var/docker/archive
PIDFILE=/var/run/exportdvdmkv.pid

if [ -f $PIDFILE ]
then
  PID=$(cat $PIDFILE)
  ps -p $PID > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    echo "`date`:    An export job is running. Conserving CPU for that job. exiting"
    exit 1
  fi
elif `pgrep -lf HandBrakeCLI` > /dev/null 2>&1; then
  if [ $? -eq "0" ]; then
    echo "`date`:    Handbrake job is running. Conserving CPU for that job. exiting"
    exit 1
  fi
fi

#
# compress the archives
#
echo "`date`:    Starting archive compression job. Hold on to your butts."
cd $ARCHIVE
for f in `find . -type f \( -iname \*.m4v -o -iname \*.mp4 \)`
do
  gzip -r -q --fast -f $f > /dev/null 2>&1 &
done

echo "`date`:    Compression job is complete."
