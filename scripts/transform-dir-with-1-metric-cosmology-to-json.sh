#!/usr/bin/env bash

# NB: Assume MOZPERFAX set in environment

RDIR=$1
echo "checking for results directory: $RDIR ... "
if [ ! -d "$RDIR" ]; then
    echo "directory $RDIR not found, exiting."
    exit 3;
fi

SITELIST=$2
echo "checking for sitelist: $SITELIST";
if [ ! -n "$SITELIST" ]; then
    echo "sitelist not found, exiting."
    exit 4;
fi

# Where to find necessary binary prerequisites.
MOZXBDIR="${MOZPERFAX}/bin"
MOZXBROWSERTIMELCP=$MOZXBDIR/moz-perf-x-extract.browsertime_pageload.exe
MOZXDOMAIN=$MOZXBDIR/moz-perf-x-extract.browsertime_url.exe

echo "checking for moz-perf-x-extract.browsertime_pageload.exe"
test ! -f ${MOZXBROWSERTIMELCP} && exit 8;

echo "checking for moz-perf-x-extract.browsertime_url.exe"
test ! -f ${MOZXDOMAIN} && exit 5;


# Prep: enter working directory, prep result data files.
BTIME=`date`;

for file in ${RDIR}/*.json
do
    # Extract minimum domain information
    DOMAIN=`${MOZXDOMAIN} $file`
    echo "DOMAIN is $DOMAIN"

    # Make extracted json file with only the specified metrics...
    $MOZXBROWSERTIMELCP $file $SITELIST
done

CSVDIR=$RDIR.transform
mkdir $CSVDIR;
mv *.json $CSVDIR;

ETIME=`date`;

echo "start ETL at $BTIME"
echo "end ETL at $ETIME"
