#!/usr/bin/env bash

XURLMIN=$MOZPERFAX/bin/moz-perf-x-transform-url.exe
XAGGREGATE=../../scripts/generate_aggregate_json_by_date.py
CHROMEDIR=chrome_release
FIREFOXDIR=fenix_nightly

ODIR=tmp
if [ ! -d tmp ]; then
    mkdir $ODIR
fi


get_aggregate() {
    TESTN="$1"
    PLATFORMN="$2"
    ISODATE="$3"
    TPLATFORM="${PLATFORMN}-${TESTN}"
    ARTIFACT_BASE="${ISODATE}-${TPLATFORM}";

    $XAGGREGATE "$TESTN" "$PLATFORMN" "$ISODATE" "${ARTIFACT_BASE}-side-by-side.mp4" "${ARTIFACT_BASE}-firefox-filmstrip.json" "${ARTIFACT_BASE}-firefox-cold-browsertime-metrics.json" "${ARTIFACT_BASE}-chrome-filmstrip.json" "${ARTIFACT_BASE}-chrome-cold-browsertime-metrics.json"
}

#get_aggregate "amazon" "android" "2024-11-15"
#get_aggregate "amazon" "linux" "2024-11-20"
#get_aggregate "amazon" "win11" "2024-11-20"

#get_aggregate "amazon" "android" "2024-11-11"

#get_aggregate "allrecipes" "android" "2024-11-20"
#get_aggregate "espn" "android" "2024-11-20"
#get_aggregate "micros-sup" "android" "2024-11-20"

# 2
generate_platform_by_sitelist() {
    PLATFORM="$1"
    SITELIST="$2"
    ISODATE="$3"

   for i in `cat ${SITELIST}`
   do
       URLM=`${XURLMIN} "$i"`
       TPLATFORM="${PLATFORM}-${URLM}"
       ARTIFACT_BASE="${ISODATE}-${TPLATFORM}";

       echo "$i"
       echo "$URLM"

       FFMJ="${FIREFOXDIR}/${URLM}-metrics.json"
       FFFJ="${ODIR}/${ARTIFACT_BASE}-firefox-filmstrip.json"

       CMJ="${CHROMEDIR}/${URLM}-metrics.json"
       CFJ="${ODIR}/${ARTIFACT_BASE}-chrome-filmstrip.json"

       $XAGGREGATE "$URLM" "$PLATFORM" "$ISODATE" "${ARTIFACT_BASE}-side-by-side.mp4" "$FFFJ" "$FFMJ" "$CFJ" "$CMJ"
   done
}

generate_platform_by_sitelist "android" "../sitelist.txt" "2024-11-10"

# 3
generate_data_json() {

    OFILE=data.json
    TOTALFILES=`ls *-aggregate.json | wc -l`

    echo "[" >> $OFILE

    FILEN=0
    for i in `ls *-aggregate.json`
    do
	cat $i >> $OFILE
	((FILEN+=1))
	if [ "$FILEN" -ne "$TOTALFILES" ]; then
	    echo "," >> $OFILE
	fi
    done

    echo "" >> $OFILE
    echo "]" >> $OFILE
}

#generate_data_json
