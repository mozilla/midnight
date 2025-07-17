../../scripts/generate-video-side-by-side-wrapper.sh 2025-07-01 android-15-p8 .
../../scripts/generate-video-filmstrip-wrapper.sh 2025-07-01 android-15-p8 .
../../scripts/generate-aggregate-json.sh 2025-07-01 android-15-p8
../../scripts/generate-progressive-pageload.sh
../../scripts/copy-result-resources-into-places-for-display.sh
../../scripts/check-in-results.sh
cp index-1-col-android-15-p8.md ../../2025-06-30-p8.md

cd ../..
git add videos filmstrip pages

