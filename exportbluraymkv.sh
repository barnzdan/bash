#!/usr/bin/env bash

#
#set -x
#

#
# vars
#
HBWATCH=/var/docker/docker-handbrake/watch
BLURAYDIR=/var/docker/docker-ripper/root/ripper/Ripper/BluRay
ARCHIVE=/var/docker/archive
PIDFILE=/var/run/exportbluraymkv.pid

#
# export the raw mkv files into handbrake 
# right now its quicker to run this off the substrate but should be run as a container
#

#
# first check and make sure makemkv is not running if it is then exit
# if we are putting in multiple discs they should batch up the mkvs under their own
# respective directories then we can for loop and process as needed once all the ripping 
# is complete
#

#
# check all the things
#

if [ -f $PIDFILE ]
then
  PID=$(cat $PIDFILE)
  ps -p $PID > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    echo "`date`:    An export job is already running. exiting"
    exit 1
  else
    ## Process not found assume not running
    echo $$ > $PIDFILE
    if [ $? -ne 0 ]
    then
      echo "Could not create PID file"
      exit 1
    fi
  fi
else
  echo $$ > $PIDFILE
  if [ $? -ne 0 ]
  then
    echo "Could not create PID file"
    exit 1
  fi
fi

pgrep -lf makemkvcon > /dev/null 2>&1
if [ $? -eq "0" ]; then
  echo "`date`:    BluRay:makemkvcon currently running. exiting."
  exit 1
fi

# Check BluRay
if [ -z "$(ls -A /var/docker/docker-ripper/root/ripper/Ripper/BluRay/)" ]; then
  echo "`date`:    no BluRay mkv files exist for transport. exiting."
  exit 0
fi

#
# lets get started 
# if there are spaces in the title replace them with _ to deal with them easier
#
cd ${BLURAYDIR}
for d in */
do
  if [[ "$d" =~ \ |\' ]]; then
    echo "`date`:    BluRay:found spaces in the title switching to underscores"
    mv -u "$d" `echo $d | sed -e 's/ /_/g'`
  fi
done

#
# rename generic mkv file to title of the movie based on the directory it lives in
# then ship it to handbrake watch directory
# clean up everything else
#

cd ${BLURAYDIR}
for m in `ls -1`
do
  #
  # test if the directory is populated
  #
  if [ "$(ls -A $m)" ]; then
    echo "`date`:    BluRay directory populated...lets get started."
    MOVIENAME=`ls -d $m | tr '[:upper:]' '[:lower:]'`
    echo "`date`:    Found BluRay $MOVIENAME sending to handbrake..."
    cd $m
    rename title ${MOVIENAME} *.mkv
    cp *.mkv ${HBWATCH}/ 
    #
    # only if the copy was successful should we move the mkv on to the archives
    #
    if [ $? -eq "0" ]; then
      echo "`date`:    BluRay: copy was successful to handbrake. No longer need $MOVIENAME raw MKV..."
      rm -f *.mkv 
    fi

    cd ..
    #
    # check if the ripped bluray directory is empty now
    #
    if [ ! "$(ls -A $m)" ]; then
      echo "`date`:    BluRay:$m is empty. removing directory:    $m"
      rm -rf $m
      sleep 1
      echo "`date`:    processing job for BluRay $MOVIENAME is complete."
    fi
  fi
done

# remove the pid file
rm $PIDFILE
