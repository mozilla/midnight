#!/usr/bin/env bash

TDATE=$1

#TPMETADATA1="android-15-p8"
#TPMETADATA2="android-15-ptablet"
#TPMETADATA3="android-14-a55"
#TPMETADATA4="linux-18"
#TPMETADATA5="windows-11"
TPMETADATA=$2

TRDIR=$3

SCRIPTSDIR=/home/bkoz/src/midnight.sfo/scripts/

start_time=`date`
$SCRIPTSDIR/generate-video-side-by-side-wrapper.sh $TDATE $TPMETADATA $TRDIR
$SCRIPTSDIR/generate-video-filmstrip-wrapper.sh $TDATE $TPMETADATA $TRDIR
$SCRIPTSDIR/generate-aggregate-json.sh $TDATE $TPMETADATA
end_time=`date`

echo "done"
echo "start: $start_time"
echo "finish: $end_time"
