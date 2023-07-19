#!/usr/bin/env bash

set -Eeuo pipefail

degree=bioinf_msc_2019
url=https://www.imp.fu-berlin.de/fbv/pruefungsbuero/Studien--und-Pruefungsordnungen/STOPO_MSc_Bioinf_-2019.pdf

source scripts/convertHelper.sh

# extract front pages
for i in $(seq 2 10); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}_stopo.txt
clean_text result/${degree}_stopo.txt

# extract module description
(
    for i in $(seq 11 47); do
        echo "page: $i" >> $log
        get_module_description_page $i
    done
) > result/${degree}_module_descriptions.txt
