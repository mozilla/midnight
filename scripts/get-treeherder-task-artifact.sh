#!/usr/bin/env bash

#ISODATE=`date --iso`
ISODATE=2024-12-11

XITERATION=$MOZPERFAX/bin/moz-perf-x-extract.browsertime_iteration.exe
XURLMIN=$MOZPERFAX/bin/moz-perf-x-transform-url.exe

SITELIST=sitelist.txt

CHROMEDIR=chrome
FIREFOXDIR=firefox
mkdir $CHROMEDIR
mkdir $FIREFOXDIR

get_artifact_and_unpack() {
    PLATFORM="$1"
    TESTNAME="$2"
    BROWSER="$3"
    TASKID="$4"

    # ARTIFACT=browsertime-results.tgz
    ARTIFACT=browsertime-videos-original
    ARTIFACT_URL="https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/${TASKID}/runs/0/artifacts/public/test_info/${ARTIFACT}.tgz"

    #curl --fail --silent --show-error "${ARTIFACT_URL}" --output "$ARTIFACTF";
    wget "${ARTIFACT_URL}"
    if [ ! -e "${ARTIFACT}.tgz" ]; then
	echo "cannot find artifact for $TESTNAME, skipping"
	return 1
    fi
    tar xfz ${ARTIFACT}.tgz

    # find browsertime result json file
    ARTIFACT1_NAME=cold-browsertime.json
    ARTIFACT1=`find ./$ARTIFACT -type f -name $ARTIFACT1_NAME`

    URL=`cat ${ARTIFACT1} | jq -r '.[0].info.url'`
    echo "$URL" >> sitelist.txt
    URLM=`${XURLMIN} "$URL"`

    # select data files and copy/rename.
    ARTIFACT_BASE="${BROWSER}/${URLM}"

    ARTIFACT1_ONAME=${ARTIFACT_BASE}-${ARTIFACT1_NAME};
    cp ${ARTIFACT1} ./${ARTIFACT1_ONAME};

    # use it to select iteration to use for rest of extraction.
    # Note browsertime numbering starts at 0, artifact numbering starts at 1
    ITER=`$XITERATION ./${ARTIFACT1_ONAME}`
    ITER=$((ITER + 1))

    # find video file.
    ARTIFACT2_NAME=${ITER}-original.mp4
    ARTIFACT2=`find ./$ARTIFACT -type f -name $ARTIFACT2_NAME | grep cold`
    cp ${ARTIFACT2} ./${ARTIFACT_BASE}.mp4;

    # make json file with video file, iteration info
    VOFILE=${ARTIFACT_BASE}-"video.json"
    echo '{' >> $VOFILE
    str1='"file": "XXFILE",'
    echo ${str1/XXFILE/${ARTIFACT_BASE}.mp4} >> $VOFILE
    str2='"iteration": "XXITER"'
    echo ${str2/XXITER/${ITER}} >> $VOFILE
    echo "}" >> $VOFILE

    #rm -rf ${ARTIFACT} ${ARTIFACT}.tgz

    rm -rf ${ARTIFACT}
    mv ${ARTIFACT}.tgz ${ARTIFACT_BASE}-${ARTIFACT}.tgz
}


# 2025-01-27 android firefox (Btime-nofis-fenxi tier 2), chrome (Btime-nofis-ChR tier 3)
# revision e8a0c7b11d2f988e747ce3112470236e8d434891
TPMETADATA="android-14-a55"
get_artifact_and_unpack "$TPMETADATA" "allrecipes" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "amazon" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "amazon-s" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "bild-de" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "bing" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "bing-s-r" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "booking" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "cnn" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "cnn-amp" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "dailymail" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "ebay-k" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "ebay-k-s" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "espn" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "fb-cris" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "google-maps" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "google-maps" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "google-search-r" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "imdb" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "instagram" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "micros-sup" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "reddit" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "sina" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "stacko" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "wikipedia" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "youtube" "chrome" ""
get_artifact_and_unpack "$TPMETADATA" "youtube-w" "chrome" ""



get_artifact_and_unpack "$TPMETADATA" "allrecipes" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "amazon" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "amazon-s" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "bild-de" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "bing" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "bing-s-r" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "booking" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "cnn" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "cnn-amp" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "dailymail" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "ebay-k" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "ebay-k-s" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "espn" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "fb-cris" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "google-maps" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "google" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "google-search-r" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "imdb" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "instagram" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "micros-sup" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "reddit" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "sina" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "stacko" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "wikipedia" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "youtube" "firefox" ""
get_artifact_and_unpack "$TPMETADATA" "youtube-w" "firefox" ""
