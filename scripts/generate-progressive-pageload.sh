#!/usr/bin/env bash

PAGELOADGLYPH=$MOZPERFAX/bin/moz-perf-x-analyze-progressive-pageload.exe

for FILE in `ls *aggregate.json`; do
    ${PAGELOADGLYPH} $FILE
done

mv *.svg ../../pages/
