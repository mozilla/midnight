#!/usr/bin/env bash

# Input is a browsertime results directory, with layout is as per
# acreskey's browsertime scripts.
# level 0: browsertime-results
# level 1: URL dir (yx.ste.cn)
# level 2: BROWSER (chrome_125, fenix_nightly)
# level 3: browsertime.json

# Output is as follows, but for all URL's tested.
# json.fenix_nightly/URL.json
# json.chrome_125/URL.json

# Binary tool for renames, parses browsertime json for url name.
MOZXBDIR="${MOZPERFAX}/bin"
MOZXDOMAIN=$MOZXBDIR/moz-perf-x-extract.browsertime_url.exe
MOZXITER=$MOZXBDIR/moz-perf-x-extract.browsertime_iteration.exe

RESULTSDIR=$1
if [ ! -d ${RESULTSDIR} ]; then
    echo "result directory not found: $RESULTSDIR"
    exit 11;
fi

copy_json_files_for_browser() {
    BROWSER="$1"

    OUTDIR=./json.${BROWSER}

    if [ -d $OUTDIR ]; then
	rm -rf $OUTDIR;
    fi

    JFILES=`find ${RESULTSDIR}/*/${BROWSER}/* -type f -name "browsertime.json"`
    if [ -z "$JFILES" ]; then
	echo "no json files found for $BROWSER, exiting"
	exit 11;
    else
	mkdir $OUTDIR;

	# Copy json file and copy and rename .har file if it exists.
	i=0
	for jfile in ${JFILES}
	do
	    DOMAIN=`${MOZXDOMAIN} $jfile`
	    echo $DOMAIN

	    cp "${jfile}" "$OUTDIR/$DOMAIN.json";

	    ORIGINDIR=`dirname $jfile`

	    HARFILE=$ORIGINDIR/true.har
	    if [ -e $HARFILE ]; then
	       cp "${HARFILE}" "$OUTDIR/$DOMAIN.har";
	    fi

	    # this script gives an offset in browsertime json starting at 0.
	    # mozilla CI indexes starting at 1.
	    VITER=`${MOZXITER} $jfile`
	    ((VITER+=1))
	    echo $VITER
	    VFILE=`find ${ORIGINDIR}/pages -type f -name "${VITER}.mp4"`
	    echo $VFILE
	    if [ -e $VFILE ]; then
	       cp "${VFILE}" "$OUTDIR/$DOMAIN.mp4";
	    fi

	    echo ""

	    ((i+=1))
	done

	echo "$i files found for $BROWSER"
    fi
}


# run for
copy_json_files_for_browser "fenix_nightly";
#copy_json_files_for_browser "Chrome_release";
copy_json_files_for_browser "chrome";
