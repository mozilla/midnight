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

       FFJSON=${FIREFOXDIR}/${URLM}-metrics.json
       FFCUT1P=`cat ${FFJSON} | jq -r '.LastVisualChange.median'`
       FFCUT2P=`cat ${FFJSON} | jq -r '.loadEventEnd.median'`
       FFCUT3P=`cat ${FFJSON} | jq -r '.domComplete.median'`
       echo "$FFJSON	$FFCUT1P	$FFCUT2P	$FFCUT3P"

       FFMAX=0
       if [ "${FFCUT1P}" != "null" ]; then
	   FFMAX=${FFCUT1P}
	   echo "$URLM LastVisualChange firefox is $FFMAX"
       else
	   if [ "${FFCUT2P}" != "null" ]; then
	       FFMAX=${FFCUT2P}
	       echo "$URLM LoadEventEnd firefox is $FFMAX"
	   else
	       if [ "${FFCUT3P}" != "null" ]; then
		   FFMAX=${FFCUT3P}
		   echo "$URLM domComplete firefox is $FFMAX"
	       else
		   echo "$URLM cut mystery, skipped"
	       fi
	   fi
       fi
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


TPMETADATA="android-15-p8"
generate_platform_by_sitelist "$TPMETADATA" "./sitelist.txt" "2025-02-09"
