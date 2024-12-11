#!/usr/bin/env bash

PAGELOADGLYPH=$MOZPERFAX/bin/moz-perf-x-analyze-progressive-pageload.exe


CRESULTS="./chrome/csv"
FRESULTS="./firefox/csv"

URLS=("en.wikipedia.lcp.csv" "www.cnn.lcp.csv" "www.instagram.lcp.csv")

for FILE in "${URLS[@]}"; do
    ${PAGELOADGLYPH} $FRESULTS/$FILE $CRESULTS/$FILE 
done
