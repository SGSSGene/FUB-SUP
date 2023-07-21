#!/usr/bin/env bash

set -Eeuo pipefail

degree=inf_bsc_2014
url=http://www.fu-berlin.de/service/zuvdocs/amtsblatt/2014/ab352014.pdf#G2261551

source scripts/convertHelper.sh

tail -f $log &

# extract front pages
echo "extracting sop" >> $log
for i in $(seq 54 63); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}_stopo.txt
clean_text result/${degree}_stopo.txt

# extract module description
echo "extracting module description" >> $log
(
    for i in $(seq 64 67) $(seq 70 94); do
        echo "page: $i" >> $log
        get_module_description_page $i
        echo "---" # this creates a null entry on the last iteration
    done
    #!TODO module on page 68/69 needs extraction by hand
#    get_module_description_page 68 69
) | yq -y -s '[.[] | select(type=="object")] | { # remove null entries
        formatversion: 1,
        modules: .}' \
    > result/${degree}_module_descriptions.yaml
