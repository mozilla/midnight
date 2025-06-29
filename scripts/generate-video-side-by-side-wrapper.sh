#!/usr/bin/env bash

XURLMIN=$MOZPERFAX/bin/moz-perf-x-transform-url.exe
XSIDEXSIDE=../../scripts/generate_video_side_by_side_standalone.py

TDATE=$1

#TPMETADATA="android-15-p8"
#TPMETADATA="android-15-ptablet"
TPMETADATA=$2

TRDIR=$3

usage="To use run generate-video-side-by-side-wrapper 2025-XX-XX android-15-ptablet-talkback ./tmp"

if [ ! -n "$TDATE" ]; then
    echo "$usage";
    echo "date missing"
    exit 1;
fi

if [ ! -n "$TPMETADATA" ]; then
    echo "$usage";
    echo "metadata missing"
    exit 1;
fi

if [ ! -n "$TRDIR" ]; then
    echo "$usage";
    echo "test restults dir missing"
    exit 1;
fi

CHROMEDIR=chrome
FIREFOXDIR=firefox

ODIR=tmp
if [ ! -d tmp ]; then
    mkdir $ODIR
fi

get_side_by_side() {
    TPLATFORM="$1"
    ISODATE="$2"
    ARTIFACT_BASE="$ISODATE-$TPLATFORM";

    # firefox left, chrome right
    LEFT="$TDIR/$ARTIFACT_BASE-firefox.mp4"
    RIGHT="$TDIR/$ARTIFACT_BASE-chrome.mp4"

    $XSIDEXSIDE --base-video $LEFT --new-video $RIGHT --remove-orange

    # rename
    mv custom-side-by-side.mp4 ${ODIR}/${ARTIFACT_BASE}-side-by-side.mp4
    mv before-rs.mp4 ${ODIR}/${ARTIFACT_BASE}-firefox.mp4
    mv after-rs.mp4 ${ODIR}/${ARTIFACT_BASE}-chrome.mp4

    # remove gen
    rm after*.mp4
    rm before*.mp4
}

#get_side_by_side "android-amazon" "2024-11-11"
#get_side_by_side "linux-amazon" "2024-11-20"
#get_side_by_side "win11-amazon" "2024-11-20"

#get_side_by_side "android-allrecipes" "2024-11-20"
#get_side_by_side "android-espn" "2024-11-20"
#get_side_by_side "android-micros-sup" "2024-11-20"


# assume data layout as
# results/2024-11-10/chrome_release,fenix_nightly/[minified-url].[json | mp4]
generate_platform_by_sitelist() {
    ISODATE="$1"
    PLATFORM="$2"
    RDIR="$3"
    SITELIST="$4"

    logfile="$RDIR/$ISODATE-$PLATFORM-video-side-by-side.skipped"

   for i in `cat ${SITELIST}`
   do
       URLM=`${XURLMIN} "$i"`
       TPLATFORM="${PLATFORM}-${URLM}"
       ARTIFACT_BASE="$ISODATE-$TPLATFORM";

       echo "$i $URLM starting... "

       # firefox left, chrome right
       LEFT="$RDIR/$FIREFOXDIR/$URLM.mp4"
       RIGHT="$RDIR/$CHROMEDIR/$URLM.mp4"

       if [[ -f "${LEFT}" && -f "${RIGHT}" ]]; then
	   #$XSIDEXSIDE --base-video $LEFT --new-video $RIGHT
	   $XSIDEXSIDE --base-video $LEFT --new-video $RIGHT --remove-orange

	   # rename
	   mv custom-side-by-side.mp4 ${ODIR}/${ARTIFACT_BASE}-side-by-side.mp4
	   mv before-rs.mp4 ${ODIR}/${ARTIFACT_BASE}-firefox.mp4
	   mv after-rs.mp4 ${ODIR}/${ARTIFACT_BASE}-chrome.mp4

	   # remove gen
	   rm after*.mp4
	   rm before*.mp4

	   echo "$i $URLM done"
       else
	   if [[ ! -f "${LEFT}" ]]; then
	       echo "$LEFT not found"
	       echo "$LEFT" >> $logfile
	   fi
	   if [[ ! -f "${RIGHT}" ]]; then
	       echo "$RIGHT not found"
	       echo "$RIGHT" >> $logfile
	   fi
	   echo "$i $URLM skipping..."
       fi
       echo ""
   done
}


generate_platform_by_sitelist "$TDATE" "$TPMETADATA" "$TRDIR" "./sitelist.txt"

DTSTAMP=`date`
echo "done side-by-side generaton of $TPMETADATA at $DTSTAMP"
