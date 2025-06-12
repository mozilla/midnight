#!/usr/bin/env bash

PAGELOADGLYPH=$MOZPERFAX/bin/moz-perf-x-analyze-progressive-pageload.exe

for FILE in `ls *aggregate.json`; do
    if [ -f "$FILE" ]; then
	${PAGELOADGLYPH} $FILE
    else
	echo "$FILE" >> progressive-pageload.missing
    fi
done

mv *.svg ../../pages/
