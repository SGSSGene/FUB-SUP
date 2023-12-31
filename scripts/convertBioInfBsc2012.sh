#!/usr/bin/env bash

set -Eeuo pipefail

degree=bioinf_bsc_2012
url=https://www.imp.fu-berlin.de/fbv/pruefungsbuero/Studien--und-Pruefungsordnungen/StOPO_BSc_Bioinf_-2012.pdf

source scripts/convertHelper.sh

# extract front pages
for i in $(seq 1 5); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}_sto.txt
clean_text result/${degree}_sto.txt

# extract front pages
for i in $(seq 23 25); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}_po.txt
clean_text result/${degree}_po.txt


# extract module description
#(
#    for i in $(seq 7 28); do
#        echo "page: $i" >> $log
#        get_module_description_page $i
#    done
#    #!TODO module on page 68/69 needs extraction by hand
##    get_module_description_page 68 69
#) > result/${degree}_module_descriptions.txt
