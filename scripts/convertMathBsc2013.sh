#!/usr/bin/env bash

set -Eeuo pipefail

degree=math_bsc_2013
url=https://www.imp.fu-berlin.de/fbv/pruefungsbuero/Studien--und-Pruefungsordnungen/STOPO_BSc_-Mathe-2013.pdf

source scripts/convertHelper.sh

# extract front pages
echo "extracting spo" >> $log
for i in $(seq 1 5) $(seq 40 41); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}_spo.txt
echo "page: 42" >> $log
get_one_column_page 42 >> result/${degree}_spo.txt

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
