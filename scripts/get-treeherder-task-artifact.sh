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
get_artifact_and_unpack "$TPMETADATA" "allrecipes" "chrome" "ccD3PkRMTUSxaXmR_373iQ"
get_artifact_and_unpack "$TPMETADATA" "amazon" "chrome" "R6wwMw82Q2mube74bcGDqg"
get_artifact_and_unpack "$TPMETADATA" "amazon-s" "chrome" "DGZ-XLMrR-SQTI3G2gkNpQ"
get_artifact_and_unpack "$TPMETADATA" "bild-de" "chrome" "YFl331S1SpqB21U0sO47Nw"
get_artifact_and_unpack "$TPMETADATA" "bing" "chrome" "RiS_H-iHRAycO-gDagwRYQ"
get_artifact_and_unpack "$TPMETADATA" "bing-s-r" "chrome" "Xvn7LQVyR2udhSxfXFtpWA"
get_artifact_and_unpack "$TPMETADATA" "booking" "chrome" "Z74QtBFhTgmM-eE9zNZ8wQ"
get_artifact_and_unpack "$TPMETADATA" "cnn" "chrome" "bsX08FihSgO6EDBgkQVHkg"
get_artifact_and_unpack "$TPMETADATA" "cnn-amp" "chrome" "TM6K2tArQZiwXiT5iO2FeQ"
get_artifact_and_unpack "$TPMETADATA" "dailymail" "chrome" "CnTr0DsFSQmASkWFQy7Gvg"
get_artifact_and_unpack "$TPMETADATA" "ebay-k" "chrome" "fail"
get_artifact_and_unpack "$TPMETADATA" "ebay-k-s" "chrome" "YsY4Z5_SQ5OSHBEoh0Sc9A"
get_artifact_and_unpack "$TPMETADATA" "espn" "chrome" "HHn0oSe4QiqKiF4GmRBFVQ"
get_artifact_and_unpack "$TPMETADATA" "fb-cris" "chrome" "Vh0dl_M1Srye8irLBxPu3w"
get_artifact_and_unpack "$TPMETADATA" "google-maps" "chrome" "Kit7QAiBREOSH_vnZksg-Q"
get_artifact_and_unpack "$TPMETADATA" "google-maps" "chrome" "aW_9c6kRT5aejEX5RbDJTQ"
get_artifact_and_unpack "$TPMETADATA" "google-search-r" "chrome" "NPQE2hiqQ4OIQWElDBdYsw"
get_artifact_and_unpack "$TPMETADATA" "imdb" "chrome" "J1-xVkwSRZKI6mrQ9mkIyg"
get_artifact_and_unpack "$TPMETADATA" "instagram" "chrome" "aIgODvyCTG-OEPfXn-pXiw"
get_artifact_and_unpack "$TPMETADATA" "micros-sup" "chrome" "fail"
get_artifact_and_unpack "$TPMETADATA" "reddit" "chrome" "Y_EeyCa9R-mzDW1mRhOa9A"
get_artifact_and_unpack "$TPMETADATA" "sina" "chrome" "HDdbyEXRRJ6IFpQNtVfIow"
get_artifact_and_unpack "$TPMETADATA" "stacko" "chrome" "LL7HAoBeS-6mxhJgcHNa4Q"
get_artifact_and_unpack "$TPMETADATA" "wikipedia" "chrome" "G9TPJDu_QnibNfW6BpI1pQ"
get_artifact_and_unpack "$TPMETADATA" "youtube" "chrome" "f13JOp58Q7GtQi8eQw5JyQ"
get_artifact_and_unpack "$TPMETADATA" "youtube-w" "chrome" "OaFcq1kSR2eKlqOkLFaDmg"



get_artifact_and_unpack "$TPMETADATA" "allrecipes" "firefox" "QbT0zvL6Rt6tFRlz69l47w"
get_artifact_and_unpack "$TPMETADATA" "amazon" "firefox" "LUmCSJvZQK6ox5ftBps4Jg"
get_artifact_and_unpack "$TPMETADATA" "amazon-s" "firefox" "U2yOAYOQRz-O2m5HEHCtIQ"
get_artifact_and_unpack "$TPMETADATA" "bild-de" "firefox" "VLMS-LRiQOOBPd3mTbeTyg"
get_artifact_and_unpack "$TPMETADATA" "bing" "firefox" "FySXbkBLQ1ylFp-Q8f2z4Q"
get_artifact_and_unpack "$TPMETADATA" "bing-s-r" "firefox" "MauMoa__R12aJ8c3356qmg"
get_artifact_and_unpack "$TPMETADATA" "booking" "firefox" "GuIhxmFqQtCDpqrngVZZtQ"
get_artifact_and_unpack "$TPMETADATA" "cnn" "firefox" "EybJ2tlNRIS53862_8c-sQ"
get_artifact_and_unpack "$TPMETADATA" "cnn-amp" "firefox" "dUSw6WtwQTKw8GmDkBIA9g"
get_artifact_and_unpack "$TPMETADATA" "dailymail" "firefox" "UM_vvGd0RkWBz77spck0Pg"
get_artifact_and_unpack "$TPMETADATA" "ebay-k" "firefox" "SuXi4HIZSfu2xkbMx1G-Vw"
get_artifact_and_unpack "$TPMETADATA" "ebay-k-s" "firefox" "K9lF6RkOSIKdp2g_ZeZqHg"
get_artifact_and_unpack "$TPMETADATA" "espn" "firefox" "WwoSw1HgSg6XzhxFzAp-zg"
get_artifact_and_unpack "$TPMETADATA" "fb-cris" "firefox" "POhyuBXWRN-iCSlLVTK05g"
get_artifact_and_unpack "$TPMETADATA" "google-maps" "firefox" "P7yFnu__Tt6OH_i8jcERuw"
get_artifact_and_unpack "$TPMETADATA" "google" "firefox" "TtK_mte2SdKjAPx30m9yNQ"
get_artifact_and_unpack "$TPMETADATA" "google-search-r" "firefox" "C2K8cQk0S36WWzIiEkSH9w"
get_artifact_and_unpack "$TPMETADATA" "imdb" "firefox" "YykKPhT6RhyGk-Bw5VGsYg"
get_artifact_and_unpack "$TPMETADATA" "instagram" "firefox" "Q1q5Dr4IQQOd8SD1kwiMTg"
get_artifact_and_unpack "$TPMETADATA" "micros-sup" "firefox" "bGjIGB3XQ4Gm7khIz4NvVQ"
get_artifact_and_unpack "$TPMETADATA" "reddit" "firefox" "b4AULCk3RjeugmrQ_fm6jA"
get_artifact_and_unpack "$TPMETADATA" "sina" "firefox" "CdPfcEi5Q7CDRxCr5L6V7g"
get_artifact_and_unpack "$TPMETADATA" "stacko" "firefox" "H93qJIGGQn6O0Rdc2ya9hA"
get_artifact_and_unpack "$TPMETADATA" "wikipedia" "firefox" "JJmJUKvURz6DEysK9uNFmw"
get_artifact_and_unpack "$TPMETADATA" "youtube" "firefox" "Nu93kYYlSIu8c_g5sAkeaA"
get_artifact_and_unpack "$TPMETADATA" "youtube-w" "firefox" "PjWn_9lBRI62yzJBdcVDFQ"
