#!/usr/bin/env bash

XURLMIN=$MOZPERFAX/bin/moz-perf-x-transform-url.exe
XTHUMBNAILS=../../scripts/generate_video_filmstrip_standalone.py

TDATE=$1

#TPMETADATA="android-15-p8"
#TPMETADATA="android-15-ptablet"
TPMETADATA=$2

TSITELIST=$3
if [ ! -n "$TSITELIST" ]; then
    echo "Sitelist argument not supplied, using default of ./sitelist.txt";
    TSITELIST="./sitelist.txt";
fi


CHROMEDIR=chrome
FIREFOXDIR=firefox

ODIR=tmp
if [ ! -d tmp ]; then
    mkdir $ODIR
fi

# assume data layout as
# results/2024-11-10/chrome_release,fenix_nightly/[minified-url].[json | mp4]
generate_platform_by_sitelist() {
    ISODATE="$1"
    PLATFORM="$2"
    SITELIST="$3"


   for i in `cat ${SITELIST}`
   do
       URLM=`${XURLMIN} "$i"`
       TPLATFORM="${PLATFORM}-${URLM}"
       ARTIFACT_BASE="$ISODATE-$TPLATFORM";

       echo "starting	${i}: ${URLM}"

       # Generate thumbnails for firefox video.
       FFJSON=${FIREFOXDIR}/${URLM}-metrics.json
       if [ -f "${FFJSON}" ]; then
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
		       echo "$URLM cut mystery firefox, skipped"
		   fi
	       fi
	   fi
	   FFV="${ODIR}/${ARTIFACT_BASE}-firefox.mp4"
	   $XTHUMBNAILS $FFV $FFMAX
	   echo "firefox: $FFV $FFMAX thumbnailing done"
       else
	   "cannot find firefox metrics file for: $URLM, skipping."
       fi
       echo ""

       # Generate thumbnails for chrome video.
       CJSON=${CHROMEDIR}/${URLM}-metrics.json
       if [ -f "${CJSON}" ]; then
	   CCUT1P=`cat ${CJSON} | jq -r '.LastVisualChange.median'`
	   CCUT2P=`cat ${CJSON} | jq -r '.loadEventEnd.median'`
	   CCUT3P=`cat ${CJSON} | jq -r '.domComplete.median'`
	   echo "$CJSON		$CCUT1P	$CCUT2P	$CCUT3P"

	   CMAX=0
	   if [ "${CCUT1P}" != "null" ]; then
	       CMAX=${CCUT1P}
	       echo "$URLM LastVisualChange chrome is $CMAX"
	   else
	       if [ "${CCUT2P}" != "null" ]; then
		   CMAX=${CCUT2P}
		   echo "$URLM LoadEventEnd chrome is $CMAX"
	       else
		   if [ "${CCUT3P}" != "null" ]; then
		       CMAX=${CCUT3P}
		       echo "$URLM domComplete chrome is $CMAX"
		   else
		       echo "$URLM cut mystery chrome, skipped"
		   fi
	       fi
	   fi
	   CV="${ODIR}/${ARTIFACT_BASE}-chrome.mp4"
	   $XTHUMBNAILS $CV $CMAX
	   echo "chrome: $CV $CMAX thumbnailing done"
       else
	   "cannot find chrome metrics file for: $URLM, skipping."
       fi
       echo ""

   done

}

#generate_platform_by_sitelist "$TDATE" "$TPMETADATA" "$TSITELIST"


generate_platform_by_sitelist_control_points() {
    ISODATE="$1"
    PLATFORM="$2"
    SITELIST="$3"
    BROWSER="$4"

   for i in `cat ${SITELIST}`
   do
       URLM=`${XURLMIN} "$i"`
       TPLATFORM="${PLATFORM}-${URLM}"
       ARTIFACT_BASE="$ISODATE-$TPLATFORM";

       # Generate thumbnails for firefox video.
       BJSON=${BROWSER}/${URLM}-control-points.json
       if [ -f "${BJSON}" ]; then
	   echo "starting	${i}: ${URLM} ${BROWSER}"
	   CV="${ODIR}/${ARTIFACT_BASE}-${BROWSER}.mp4"
	   $XTHUMBNAILS $CV $BJSON
       else
	   echo "skipping	${i}: ${URLM} ${BROWSER}, not found"
       fi
       echo ""
   done
}

generate_platform_by_sitelist_control_points "$TDATE" "$TPMETADATA" "$TSITELIST" \
					     $FIREFOXDIR

generate_platform_by_sitelist_control_points "$TDATE" "$TPMETADATA" "$TSITELIST" \
					     $CHROMEDIR
