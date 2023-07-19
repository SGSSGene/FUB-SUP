#!/usr/bin/env bash

set -Eeuo pipefail

degree=inf_msc_2014
url=https://www.imp.fu-berlin.de/fbv/pruefungsbuero/Studien--und-Pruefungsordnungen/0089c_SPO_2014.pdf

source scripts/convertHelper.sh

# extract front pages
for i in $(seq 99 106); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}_stopo.txt
clean_text result/${degree}_stopo.txt

# extract module description
(
    for i in $(seq 107 160); do
        echo "page: $i" >> $log
        get_module_description_page $i
    done

) > result/${degree}_module_descriptions.txt
