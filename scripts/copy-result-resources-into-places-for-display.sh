#!/usr/bin/env bash

# cd midnight/results/2025-06-18/
# aka inside the specific results directory, after outputs have been generated.
git add *.json *.md *.js *.txt

# copy images into midnight/filmstrip/
mv tmp/*.webp ../../filmstrip/

# copy videos into midnight/videos/
mv tmp/*side-by-side.mp4 ../../videos/

echo "done positioning generated resources..."
