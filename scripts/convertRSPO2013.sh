#!/usr/bin/env bash

set -Eeuo pipefail

degree=rspo_2012
url=http://www.fu-berlin.de/service/zuvdocs/amtsblatt/2013/ab322013.pdf

source scripts/convertHelper.sh

# extract front pages
for i in $(seq 2 11); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}.txt
clean_text result/${degree}.txt
