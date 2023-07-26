#!/usr/bin/env bash

set -Eeuo pipefail

degree=lehrinf_bsc_2015
url=https://www.imp.fu-berlin.de/fbv/pruefungsbuero/Studien--und-Pruefungsordnungen/StOPO_Lehramt-Inf_2015.pdf

source scripts/convertHelper.sh

tail -f $log &

mkdir -p result/${degree}

# extract front pages
echo "extracting spo" >> $log
for i in $(seq 2 9); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}/spo.md
clean_text result/${degree}/spo.md
cat result/lehrinf_bsc_2015/spo.md \
    | awk '{print "    " $0}' \
    | perl -pne 's/^    §\s*/## § /' \
    | perl -pne 's/^    \(([1-9][0-9]?)\)/\1./g' \
    | perl -pne 's/^    $//g' \
    | perl -0777 -pne 's/\n\n/\n/g' \
    | perl -0777 -pne 's/\n##/\n\n##/g' \
    | perl -0777 -pne 's/\n    (\([1-9][0-9]? LP\))/\1/g' \
    > result/lehrinf_bsc_2015/spo.md.tmp
mv result/lehrinf_bsc_2015/spo.md.tmp result/lehrinf_bsc_2015/spo.md


# extract module description
echo "extracting module explanations" >> $log
for i in 10; do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}/module_explanations.md
clean_text result/${degree}/module_explanations.md

# extract modules
pdftohtml -s -xml caches/${degree}.pdf caches/${degree}/prefix
XQ_STARTPAGE=11
XQ_ENDPAGE=14
./scripts/extractCombinedSPO.xq caches/${degree}/prefix.xml > result/${degree}/modules.yaml
