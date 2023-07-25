#!/usr/bin/env bash

set -Eeuo pipefail

degree=phy_bsc_2012
url=https://www.imp.fu-berlin.de/fbv/pruefungsbuero/Studien--und-Pruefungsordnungen/StOPO_Bsc_Physik_-2012.pdf

source scripts/convertHelper.sh

# extract front pages
for i in $(seq 2 5) $(seq 25 27); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}_spo.txt
clean_text result/${degree}_spo.txt


# extract module description
#(
#    for i in $(seq 7 28); do
#        echo "page: $i" >> $log
#        get_module_description_page $i
#    done
#    #!TODO module on page 68/69 needs extraction by hand
##    get_module_description_page 68 69
#) > result/${degree}_module_descriptions.txt
