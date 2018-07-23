#!/bin/bash

#set -x

pgrep -lf disc:0 > /dev/null
if [ $? -eq 0 ]
then
    echo "rip in progress. exiting"
    exit 1
else

      ls -1d /output/* | grep -vw output.txt > /output/output.txt
      for i in `cat /output/output.txt`
      do
        cd $i
        ls *.mkv > list.txt
      for m in `cat list.txt`
      do
        p=`/opt/makemkv/bin/makemkvcon -r info file:$m --cache=2048 | /tmp/fl2`
        echo "$m $p" >> scratch.txt
      done
    done

  for i in `cat /output/output.txt`
  do
    cd $i
    movietitle=`pwd | awk -F '/' '{print $3}' | tr '[:upper:]' '[:lower:]'`
    featuremkv=`sort -r -k 2 scratch.txt | head -1 | awk '{print $1}'`
    mv $featuremkv ${movietitle}.mkv
    mv scratch.txt scratch.txt.$$
  done

#    x=`pwd | awk -F '/' '{print $3}'`
#    feature=`sort -r -k 2 scratch.txt | head -1 | awk '{print $1}'`
#    mv scratch.txt scratch.txt.$$
#    mv $feature ${x}.mkv
#    mv scratch.txt scratch.txt.$$

fi
