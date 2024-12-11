#!/usr/bin/env bash

XURLMIN=$MOZPERFAX/bin/moz-perf-x-transform-url.exe
XSIDEXSIDE=../../scripts/generate_video_side_by_side_standalone.py

CHROMEDIR=chrome_release
FIREFOXDIR=fenix_nightly

ODIR=tmp
if [ ! -d tmp ]; then
    mkdir $ODIR
fi

get_side_by_side() {
    TPLATFORM="$1"
    ISODATE="$2"
    ARTIFACT_BASE="$ISODATE-$TPLATFORM";

    # firefox left, chrome right
    LEFT="$ARTIFACT_BASE-firefox.mp4"
    RIGHT="$ARTIFACT_BASE-chrome.mp4"

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
    PLATFORM="$1"
    SITELIST="$2"
    ISODATE="$3"

   for i in `cat ${SITELIST}`
   do
       URLM=`${XURLMIN} "$i"`
       TPLATFORM="${PLATFORM}-${URLM}"
       ARTIFACT_BASE="$ISODATE-$TPLATFORM";

       echo "$i"
       echo "$URLM"

       # firefox left, chrome right
       LEFT="$FIREFOXDIR/$URLM.mp4"
       RIGHT="$CHROMEDIR/$URLM.mp4"

       $XSIDEXSIDE --base-video $LEFT --new-video $RIGHT

       # rename
       mv custom-side-by-side.mp4 ${ODIR}/${ARTIFACT_BASE}-side-by-side.mp4
       mv before-rs.mp4 ${ODIR}/${ARTIFACT_BASE}-firefox.mp4
       mv after-rs.mp4 ${ODIR}/${ARTIFACT_BASE}-chrome.mp4

       # remove gen
       rm after*.mp4
       rm before*.mp4

   done

}

generate_platform_by_sitelist "android" "../sitelist.txt" "2024-11-10"
