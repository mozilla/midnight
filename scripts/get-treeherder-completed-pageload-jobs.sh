#!/usr/bin/env bash

ISODATE=`date --iso`
SUFFIX="ci-anchor.json"

# Chrome results.

LINUX_URLC="https://sql.telemetry.mozilla.org/api/queries/103481/results.json?api_key=gGZtKjMWvDxX1ZowDO1ylPLpb7geLfydJOfPwacA"
WIN_URLC="https://sql.telemetry.mozilla.org/api/queries/103544/results.json?api_key=77QUfZNd45ckUuoTDv9thesptPNWyE2KC2rzdVTz"
DROID_URLC="https://sql.telemetry.mozilla.org/api/queries/103543/results.json?api_key=Pamth1ZDV82obmrj1BEiVcsFPrSVUy1fFK91FERE"

curl --fail --silent --show-error "${LINUX_URLC}" --output "$ISODATE-linux-chrome-$SUFFIX";

curl --fail --silent --show-error "${WIN_URLC}" --output "$ISODATE-win11-chrome-$SUFFIX";

curl --fail --silent --show-error "${DROID_URLC}" --output "$ISODATE-android-chrome-$SUFFIX";

# Firefox results.

LINUX_URLF="https://sql.telemetry.mozilla.org/api/queries/103627/results.json?api_key=wQwoUqUlDvCba60ir76jzS65jVktTRDfh2JLXktx"
WIN_URLF="https://sql.telemetry.mozilla.org/api/queries/103629/results.json?api_key=0vQ5Fr96IWnh13o30sVeJhNnjPTyh5itBX3mQIu3"
DROID_URLF="https://sql.telemetry.mozilla.org/api/queries/103628/results.json?api_key=A6nFeIVdQtW4lCwHS01CaL3n7nA6e6LbUqrUiGjy"

curl --fail --silent --show-error "${LINUX_URLF}" --output "$ISODATE-linux-firefox-$SUFFIX";

curl --fail --silent --show-error "${WIN_URLF}" --output "$ISODATE-win11-firefox-$SUFFIX";

curl --fail --silent --show-error "${DROID_URLF}" --output "$ISODATE-android-firefox-$SUFFIX";


