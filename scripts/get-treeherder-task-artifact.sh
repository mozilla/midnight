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


# 2025-01-27 android firefox, chrome (nofis)
# revision e8a0c7b11d2f988e747ce3112470236e8d434891
get_artifact_and_unpack "android" "allrecipes" "chrome" "ccD3PkRMTUSxaXmR_373iQ"
get_artifact_and_unpack "android" "amazon-s" "chrome" "DGZ-XLMrR-SQTI3G2gkNpQ"
get_artifact_and_unpack "android" "bild-de" "chrome" "YFl331S1SpqB21U0sO47Nw"
get_artifact_and_unpack "android" "cnn-amp" "chrome" "TM6K2tArQZiwXiT5iO2FeQ"
get_artifact_and_unpack "android" "espn" "chrome" "HHn0oSe4QiqKiF4GmRBFVQ"
get_artifact_and_unpack "android" "google-search-r" "chrome" "NPQE2hiqQ4OIQWElDBdYsw"
get_artifact_and_unpack "android" "google-maps" "chrome" "Kit7QAiBREOSH_vnZksg-Q"
get_artifact_and_unpack "android" "imdb" "chrome" "J1-xVkwSRZKI6mrQ9mkIyg"
get_artifact_and_unpack "android" "instagram" "chrome" "aIgODvyCTG-OEPfXn-pXiw"
get_artifact_and_unpack "android" "reddit" "chrome" "Y_EeyCa9R-mzDW1mRhOa9A"
get_artifact_and_unpack "android" "wikipedia" "chrome" "G9TPJDu_QnibNfW6BpI1pQ"
get_artifact_and_unpack "android" "youtube-w" "chrome" "OaFcq1kSR2eKlqOkLFaDmg"

get_artifact_and_unpack "android" "allrecipes" "firefox" "QbT0zvL6Rt6tFRlz69l47w"
get_artifact_and_unpack "android" "amazon-s" "firefox" "U2yOAYOQRz-O2m5HEHCtIQ"
get_artifact_and_unpack "android" "bild-de" "firefox" "VLMS-LRiQOOBPd3mTbeTyg"
get_artifact_and_unpack "android" "cnn-amp" "firefox" "dUSw6WtwQTKw8GmDkBIA9g"
get_artifact_and_unpack "android" "espn" "firefox" "WwoSw1HgSg6XzhxFzAp-zg"
get_artifact_and_unpack "android" "google-search-r" "firefox" "C2K8cQk0S36WWzIiEkSH9w"
get_artifact_and_unpack "android" "google-maps" "firefox" "P7yFnu__Tt6OH_i8jcERuw"
get_artifact_and_unpack "android" "imdb" "firefox" "YykKPhT6RhyGk-Bw5VGsYg"
get_artifact_and_unpack "android" "instagram" "firefox" "Q1q5Dr4IQQOd8SD1kwiMTg"
get_artifact_and_unpack "android" "reddit" "firefox" "b4AULCk3RjeugmrQ_fm6jA"
get_artifact_and_unpack "android" "wikipedia" "firefox" "JJmJUKvURz6DEysK9uNFmw"
get_artifact_and_unpack "android" "youtube-w" "firefox" "PjWn_9lBRI62yzJBdcVDFQ"
