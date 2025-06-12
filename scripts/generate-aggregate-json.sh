#!/usr/bin/env bash

XURLMIN=$MOZPERFAX/bin/moz-perf-x-transform-url.exe
XAGGREGATE=../../scripts/generate_aggregate_json_by_date.py

TDATE=$1

#TPMETADATA1="android-15-p8"
#TPMETADATA2="android-15-ptablet"
#TPMETADATA3="android-14-a55"
#TPMETADATA4="linux-18"
#TPMETADATA5="windows-11"
TPMETADATA=$2

CHROMEDIR=chrome
FIREFOXDIR=firefox

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

#get_aggregate "amazon" "android" "$TDATE"

# 2
generate_platform_by_sitelist() {
    PLATFORM="$1"
    ISODATE="$2"
    SITELIST="$3"


   MDOWNIDX=index-1-col-${PLATFORM}.md
   echo "## Results" >> $MDOWNIDX

   JSIDX=index-${PLATFORM}.js

   for i in `cat ${SITELIST}`
   do
       URLM=`${XURLMIN} "$i"`
       TPLATFORM="${PLATFORM}-${URLM}"
       ARTIFACT_BASE="${ISODATE}-${TPLATFORM}";

       echo "$i"
       echo "$URLM"

       FFMJ="${FIREFOXDIR}/${URLM}"
       FFFJ="${ODIR}/${ARTIFACT_BASE}-firefox-filmstrip.json"

       CMJ="${CHROMEDIR}/${URLM}"
       CFJ="${ODIR}/${ARTIFACT_BASE}-chrome-filmstrip.json"

       $XAGGREGATE "$URLM" "$i" "$PLATFORM" "$ISODATE" "${ARTIFACT_BASE}-side-by-side.mp4" "$FFFJ" "$FFMJ" "$CFJ" "$CMJ"

       # generate 1-col markdown index
       echo "- [${URLM}](/pages/${ARTIFACT_BASE}-aggregate.svg)" >> $MDOWNIDX

       # generate js index
       echo "\"${URLM}\", " >> $JSIDX
   done
}

generate_platform_by_sitelist "$TPMETADATA" "$TDATE" "./sitelist.txt"

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

generate_data_json


# 4
# NB: FPO only, does not check to make sure files exist before linking to them.
generate_2_col_index() {
    PLATFORM1="$1"
    ISODATE1="$2"
    PLATFORM2="$3"
    ISODATE2="$4"
    SITELIST="$5"


    MDOWNIDX2=index-2-col-${PLATFORM1}-${PLATFORM2}.md
    echo "## Results" >> $MDOWNIDX2

    # create table head
    echo "<table>" >> $MDOWNIDX2
    echo "<thead>" >> $MDOWNIDX2
    echo "<tr>" >> $MDOWNIDX2
    echo "<th align=\"left\">URL</th>" >> $MDOWNIDX2
    echo "<th align=\"left\">${PLATFORM1}</th>" >> $MDOWNIDX2
    echo "<th align=\"left\">${PLATFORM2}</th>" >> $MDOWNIDX2
    echo "</tr>" >> $MDOWNIDX2
    echo "</thead>" >> $MDOWNIDX2

    echo "<tbody>" >> $MDOWNIDX2

    for i in `cat ${SITELIST}`
    do
	URLM=`${XURLMIN} "$i"`
	TPLATFORM1="${PLATFORM1}-${URLM}"
	ARTIFACT_BASE1="${ISODATE1}-${TPLATFORM1}";
	TPLATFORM2="${PLATFORM2}-${URLM}"
	ARTIFACT_BASE2="${ISODATE2}-${TPLATFORM2}";

	# generate 2-col html table for markdown embedding
	echo "<tr>" >> $MDOWNIDX2
	echo "<td>${URLM}</td>" >> $MDOWNIDX2
	echo "<td><a href=\"pages/${ARTIFACT_BASE1}-aggregate.svg\">Y</a></td>" >> $MDOWNIDX2
	echo "<td><a href=\"pages/${ARTIFACT_BASE2}-aggregate.svg\">Y</a></td>" >> $MDOWNIDX2
	echo "</tr>" >> $MDOWNIDX2
    done

    echo "</tbody>" >> $MDOWNIDX2
    echo "</table>" >> $MDOWNIDX2
}

#TPMETADATA_A=$TPMETADATA1
#TPMETADATA_B=$TPMETADATA2
#generate_2_col_index "$TPMETADATA_A" "2025-02-09" "$TPMETADATA_B" "2025-05-27" "./sitelist.txt"
