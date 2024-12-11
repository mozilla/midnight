#!/usr/bin/env bash

#ISODATE=`date --iso`
ISODATE=2024-11-20

ITERATIONFINDER=$MOZPERFAX/bin/moz-perf-x-extract.browsertime_iteration.exe

get_artifact_and_unpack() {
    TPLATFORM="$1"
    TASKID="$2"

    # ARTIFACT=browsertime-results.tgz
    ARTIFACT=browsertime-videos-original
    ARTIFACT_URL="https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/${TASKID}/runs/0/artifacts/public/test_info/${ARTIFACT}.tgz"

    #curl --fail --silent --show-error "${ARTIFACT_URL}" --output "$ARTIFACTF";
    wget "${ARTIFACT_URL}"
    tar xfz ${ARTIFACT}.tgz

    # select data files and copy/rename.
    ARTIFACT_BASE="$ISODATE-$TPLATFORM";

    # find browsertime result json file
    ARTIFACT1_NAME=cold-browsertime.json
    ARTIFACT1_ONAME=${ARTIFACT_BASE}-${ARTIFACT1_NAME};
    ARTIFACT1=`find ./$ARTIFACT -type f -name $ARTIFACT1_NAME`
    cp ${ARTIFACT1} ./${ARTIFACT1_ONAME};

    # use it to select iteration to use for rest of extraction.
    # Note browsertime numbering starts at 0, artifact numbering starts at 1
    ITER=`$ITERATIONFINDER ./${ARTIFACT1_ONAME}`
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


# 2024-11-11
# revision: 544768c159ebb03a8419e5fe3b1135bbce4965a5 amarc@mozilla.com
#get_artifact_and_unpack "android-amazon-chrome" "XVtnHMq5RIKSjctXmONWUA"
#get_artifact_and_unpack "android-amazon-firefox" "FY3DkYW_TqK-OAAnRWUCag"
#get_artifact_and_unpack "linux-amazon-chrome" "bSrPsvpRRyuV8Viufi2ThA"
#get_artifact_and_unpack "linux-amazon-firefox" "MK_AQzRzTxicH4mqSoLwmA"
#get_artifact_and_unpack "win11-amazon-chrome" "AMQmRGlnQECayEI5w7AFzw"
#get_artifact_and_unpack "win11-amazon-firefox" "ac68E6Y1R5eYweHTaGtNEQ"

# 2024-11-13
# revision: 723946b9a47990aa6253585366bb18863de4df33
#get_artifact_and_unpack "android-amazon-chrome" "TZYbceDiQmi9QFRD-p5SFA"
#get_artifact_and_unpack "android-amazon-firefox" "SRBmXxxqQgqdh93HmOnarA"
#get_artifact_and_unpack "linux-amazon-chrome" ""
#get_artifact_and_unpack "linux-amazon-firefox" "TL0sHKldQ1e_yCOZnRqwAQ"
#get_artifact_and_unpack "win11-amazon-chrome" "Oa70G72URmi3IWnVPCBjfA"
#get_artifact_and_unpack "win11-amazon-firefox" "HJZ7SBoBT_Cm27D5w05_3g"

# 2024-11-15T09:34:47Z
# revision: f918befd42312cdf96757bea838a55620ce4cb7f
# pstanciu@mozilla.com, id(482802694), push_id(1533676)
#get_artifact_and_unpack "android-amazon-chrome" "SbxKRIQhTQK7bNLVazz56A"
#get_artifact_and_unpack "android-amazon-firefox" "TmBexU_jTky6uTRUnikYsw"

# 2024-11-20T01:16:56Z
# revision c03ba0b165f20fa7694f8ec94ad24134407b45a9
# kshampur@mozilla.com
#get_artifact_and_unpack "linux-amazon-chrome" "LAkRMFQeRlO_nGBz7NGMSg"
#get_artifact_and_unpack "linux-amazon-firefox" "AngA8HVnTCWnP4Jq3fdY4Q"
#get_artifact_and_unpack "win11-amazon-chrome" "ZSBBjQdFTUu1cccBNdZFrA"
#get_artifact_and_unpack "win11-amazon-firefox" "FqLOMW9MTx-1BRFJVCQdYQ"

# lastest platform matches as of 2024-11-20

# 2024-11-20
# revision a3474ea43c045230a16fe2546af125bc643d47c2
get_artifact_and_unpack "android-allrecipes-chrome" "OxA_fZ3RSAStcrYEJXkwYA"
get_artifact_and_unpack "android-allrecipes-firefox" "cATLFcaiSeuA9v1HtFV2Eg"

get_artifact_and_unpack "android-espn-chrome" "CbP1VDn4SV-BlFHMxwPPaQ"
get_artifact_and_unpack "android-espn-firefox" "KR3QO8o0TM-ETeSjgZKobQ"

get_artifact_and_unpack "android-micros-sup-chrome" "CWg2rBBrQ3iKeCbZVZetVg"
get_artifact_and_unpack "android-micros-sup-firefox" "Hvp-x46aS5K37HKIZWgWyg"


