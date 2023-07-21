#!/usr/bin/env bash

set -Eeuo pipefail

degree=inf_bsc_2023
url=https://www.imp.fu-berlin.de/fbv/pruefungsbuero/Studien--und-Pruefungsordnungen/StOPO_BSc_Inf_-2023.pdf

source scripts/convertHelper.sh

tail -f $log &

# extract front pages
echo "extracting sop" >> $log
for i in $(seq 2 8); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}_stopo.txt
clean_text result/${degree}_stopo.txt

# extract module description
echo "extracting module description" >> $log
(
    for i in $(seq 10 45); do
        echo "page: $i" >> $log
        get_module_description_page $i
        echo "---" # this creates a null entry on the last iteration
    done
) | yq -y -s '[.[] | select(type=="object")] | { # remove null entries
        formatversion: 1,
        modules: .}' \
    > result/${degree}_module_descriptions.yaml
echo "done" >> $log
kill %1
