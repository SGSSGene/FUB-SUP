#!/usr/bin/env bash

set -Eeuo pipefail

degree=datasci_msc_2021
url=https://www.imp.fu-berlin.de/fbv/pruefungsbuero/Studien--und-Pruefungsordnungen/SPO_MSc_Data_Science-2021.pdf

source scripts/convertHelper.sh

# extract front pages
for i in $(seq 2 8); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}_spo.txt
    echo "page: 9" >> $log
    get_one_column_page 9 >> result/${degree}_spo.txt
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
