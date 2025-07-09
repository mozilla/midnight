#!/usr/bin/env bash

TDATE=$1

TPMETADATA1="android-15-p8"
TPMETADATA1a="android-15-p8-talkback"
TPMETADATA2="android-15-ptablet"
TPMETADATA2a="android-15-ptablet-talkback"
TPMETA=$2

../../scripts/generate-video-side-by-side-wrapper.sh $TDATE $TPMETA .
../../scripts/generate-video-filmstrip-wrapper.sh $TDATE $TPMETA .
../../scripts/generate-aggregate-json.sh $TDATE $TPMETA
../../scripts/generate-progressive-pageload.sh
../../scripts/copy-result-resources-into-places-for-display.sh
cp index-1-col-android-15-ptablet.md ../../${TDATE}/${TPMETA}.md
../../scripts/check-in-results.sh


cd ../..
git add videos filmstrip pages

