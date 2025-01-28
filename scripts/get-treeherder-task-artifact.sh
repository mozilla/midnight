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


# latest platform almost-matches as of 2024-12-12

# 2024-12-11
# revision 2b2422cd05b931e4ebe38754df3ca56ce3e3dc2e
# "amarc@mozilla.com", id(486417162), push_id(1548183)
#get_artifact_and_unpack "win11" "amazon" "chrome" "GOquU6R6TImHYqmnOnLAhA"
#get_artifact_and_unpack "win11" "bing" "chrome" "b4CUU1UFSoqDmU81cfFwxQ"
#get_artifact_and_unpack "win11" "cnn" "chrome" "aCXYDNr_QGa3uL7w0RQPjw"
#get_artifact_and_unpack "win11" "fandom" "chrome" "JseHKJZ3R7i9BF8Pn5DE3Q"
#get_artifact_and_unpack "win11" "gslides" "chrome" "dRRIygVRQju1jpbvMmAPgA"
#get_artifact_and_unpack "win11" "instagram" "chrome" "QmXPDH7LRuGcuF2TL18jdg"
#get_artifact_and_unpack "win11" "twitter" "chrome" "GcZMIRKXTPWvfj4_qpCC6g"
#get_artifact_and_unpack "win11" "wikipedia" "chrome" "D7AcB7WFRQ6nPZ3eCJUfhw"
#get_artifact_and_unpack "win11" "yahoo-mail" "chrome" "EK3nYflJSRWl4sVj-egNEA"

# 2024-12-11
# revision c0157231377305c8d7c22e452beff7c43fe4e9d7
# "agoloman@mozilla.com", id(486540021), push_id(1548795)
#get_artifact_and_unpack "win11" "amazon" "firefox" "eM_a4US3SECL0A39m78I0A"
#get_artifact_and_unpack "win11" "bing" "firefox" "aDN9Eq2QTcah5PE9i_DaJw"
#get_artifact_and_unpack "win11" "cnn" "firefox" "Jg4GDO_4Q-mAjmv3iLXksQ"
#get_artifact_and_unpack "win11" "fandom" "firefox" "C2jYIa6ERRqaaEsNQipkzw"
#get_artifact_and_unpack "win11" "gslides" "firefox" "Yp3c1TUrSyK48eU1tPunkg"
#get_artifact_and_unpack "win11" "instagram" "firefox" "azd7JTRXTzKSGPnTJ7ZiCA"
#get_artifact_and_unpack "win11" "twitter" "firefox" "NmdyxwohTjCCMBk_R0-oaw"
#get_artifact_and_unpack "win11" "wikipedia" "firefox" "ZfmKQ2-0Q7WENdwWy7rOag"
#get_artifact_and_unpack "win11" "yahoo-mail" "firefox" "MyHCxztqT5Se__p6qoUJVA"


# 2024-12-11
# revision 2b2422cd05b931e4ebe38754df3ca56ce3e3dc2e
# "amarc@mozilla.com", id(486417162), push_id(1548183)
#get_artifact_and_unpack "linux" "amazon" "firefox" "YyFpiR6yTwmB3-j26TLXpA"
#get_artifact_and_unpack "linux" "bing" "firefox" "JaI1JaEaQ6ec66QeXJ22-Q"
#get_artifact_and_unpack "linux" "cnn" "firefox" "ZdIc8HB4R-iwIEeXkKslog"
#get_artifact_and_unpack "linux" "fandom" "firefox" "R0ab7DVTTMuRJ-B34wucOw"
#get_artifact_and_unpack "linux" "gslides" "firefox" "YGynxK-BQBujM3gorCy0FA"
#get_artifact_and_unpack "linux" "instagram" "firefox" "V7gOIrxZRhOY7-ofPoFPGQ"
#get_artifact_and_unpack "linux" "twitter" "firefox" "WFZ_-nshRZu_BUEmrOxmmA"
#get_artifact_and_unpack "linux" "wikipedia" "firefox" "RglKQhh_T-Ws5-Y8lENbyA"
#get_artifact_and_unpack "linux" "yahoo-mail" "firefox" "K5YzrYQiQwq0d954QbiCgQ"

#get_artifact_and_unpack "linux" "amazon" "chrome" "IWQuc8gzTNqCiQ1MpMgjoQ"
#get_artifact_and_unpack "linux" "bing" "chrome" "WX1NThl6TdqtJm7bHnatgg"
#get_artifact_and_unpack "linux" "cnn" "chrome" "W20zn2XMSKGwyjHiF9pKHg"
#get_artifact_and_unpack "linux" "fandom" "chrome" "D84u4Of6TheMnBVhKNYWpw"
#get_artifact_and_unpack "linux" "gslides" "chrome" "c0ecCwY2RFe9GTirfNVWFA"
#get_artifact_and_unpack "linux" "instagram" "chrome" "bO9c0KnrSpmrO8bxr2Sc9Q"
#get_artifact_and_unpack "linux" "twitter" "chrome" "UZwRsq4uRO2SUjKMoFg4Uw"
#get_artifact_and_unpack "linux" "wikipedia" "chrome" "agLdrX77S_6h-jDqC_Vc8g"
#get_artifact_and_unpack "linux" "yahoo-mail" "chrome" "D-Rb65ykRmy2wZ1tODtXBg"

# 2024-12-18
#https://treeherder.mozilla.org/jobs?repo=mozilla-central&searchStr=a55%2Ctp6&revision=afa1013c2e3013ee65a6f03fe76ca7a75b5051c5
# fenix w/ power on A55
# revision afa1013c2e3013ee65a6f03fe76ca7a75b5051c5
# amarc
# btime fenix tier 2
#get_artifact_and_unpack "android" "amazon" "firefox" "Pz0rsAvXSgi8YGKLeoP7AQ"
#get_artifact_and_unpack "android" "bing" "firefox" "ZOkZuN92Qre5DqSBmGFhIQ"
#get_artifact_and_unpack "android" "cnn" "firefox" "aiy21RmuQpeiMVIel5mgQA"
#get_artifact_and_unpack "android" "ebay" "firefox" "WsQIa8u6Ru2Z89ek8iuxag"
#get_artifact_and_unpack "android" "imdb" "firefox" "NeOXgSnlRNK_na-7zWljvg"
#get_artifact_and_unpack "android" "instagram" "firefox" "dhhvY2IST5mr39ontjtO6w"
#get_artifact_and_unpack "android" "stacko" "firefox" "PJ9cu65yTESNMTflROBTpg"
#get_artifact_and_unpack "android" "wikipedia" "firefox" "Hur529PkQiuaIQvN7sICJQ"
#get_artifact_and_unpack "android" "reddit" "firefox" "ZrncMronRjG_0fHjfm2QLg"

# 2024-12-18
# revision
# smolnar
# Btime-nofis
get_artifact_and_unpack "android" "amazon" "firefox" "c-bi2qbHQDq1mNinVM_uAQ"
get_artifact_and_unpack "android" "allrecipes" "firefox" "Leqpq2V8QsWHMxNhZ_cnYQ"
get_artifact_and_unpack "android" "espn" "firefox" "Nvtqn_FSSzOblgHDPviJIg"
get_artifact_and_unpack "android" "google" "firefox" "RNsajmXlR4WerKFDengHqg"
get_artifact_and_unpack "android" "micros-sup" "firefox" "UB-Zm010QDa5UEX5sIeNQw"
#get_artifact_and_unpack "android" "youtube-w" "firefox" ""

get_artifact_and_unpack "android" "amazon" "chrome" "OcNIhQnRRx6mnNb7PPdMgw"
get_artifact_and_unpack "android" "allrecipes" "chrome" "QK-a-Z6US-m8lP5oo5yUxQ"
get_artifact_and_unpack "android" "espn" "chrome" "TUgwhSneQlSfTle8X-PH8w"
get_artifact_and_unpack "android" "google" "chrome" "Y43TUXvASAmWlp5VdGLsXw"
get_artifact_and_unpack "android" "micros-sup" "chrome" "Qf83npuASMSzEsSwwtyZlQ"
#get_artifact_and_unpack "android" "youtube-w" "chrome" "Dwd3NMsZStyfYGrhvjyPAg"
