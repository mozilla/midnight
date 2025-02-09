#!/usr/bin/env bash

XURLMIN=$MOZPERFAX/bin/moz-perf-x-transform-url.exe
XTHUMBNAILS=../../scripts/generate_video_filmstrip_standalone.py

CHROMEDIR=chrome
FIREFOXDIR=firefox

ODIR=tmp
if [ ! -d tmp ]; then
    mkdir $ODIR
fi

# assume data layout as
# results/2024-11-10/chrome_release,fenix_nightly/[minified-url].[json | mp4]
generate_platform_by_sitelist() {
    PLATFORM="$1"
    SITELIST="$2"
    ISODATE="$3"

   for i in `cat ${SITELIST}`
   do
       URLM=`${XURLMIN} "$i"`
       TPLATFORM="${PLATFORM}-${URLM}"
       ARTIFACT_BASE="$ISODATE-$TPLATFORM";

       echo "$i"
       echo "${URLM}"

       CUTMETRIC=.LastVisualChange.median

       FFJSON=${FIREFOXDIR}/${URLM}-metrics.json
       FFCUTP=`grep -c ${CUTMETRIC} ${FFJSON}`
       FFMAX=0
       if [ "${FFCUTP}" -gt 0 ]; then
	   FFMAX=`cat ${FFJSON} | jq -r '$CUTMETRIC'`
       fi
       echo "$URLM LastVisualChange firefox is $FFMAX"

       FFV="${ODIR}/${ARTIFACT_BASE}-firefox.mp4"
       $XTHUMBNAILS $FFV $FFMAX
       echo "$FFV + $FFMAX"

       CJSON=${CHROMEDIR}/${URLM}-metrics.json
       CCUTP=`grep -c ${CUTMETRIC} ${CJSON}`
       CMAX=0
       if [ "${CCUTP}" -gt 0 ]; then
	   CMAX=`cat ${CJSON} | jq -r '$CUTMETRIC'`
       fi
       echo "$URLM LastVisualChange chrome is $CMAX"

       CV="${ODIR}/${ARTIFACT_BASE}-chrome.mp4"
       $XTHUMBNAILS $CV $CMAX
       echo "$CV + $CMAX"

       echo ""
   done

}

generate_platform_by_sitelist "android" "./sitelist.txt" "2025-02-03"
