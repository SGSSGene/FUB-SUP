#!/usr/bin/env bash

set -Eeuo pipefail

name="lehramtsbezogene Informatik Bachelors"
degree=lehrinf_bsc_2014
url=https://www.imp.fu-berlin.de/fbv/pruefungsbuero/Studien--und-Pruefungsordnungen/StOPO_Lehramt-Inf_-2014.pdf

source scripts/convertHelper.sh

tail -f $log &

mkdir -p result/${degree}

# extract front pages
echo "extracting spo" >> $log
for i in $(seq 1 7); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}/spo.md
get_one_column_page 8 >> result/${degree}/spo.md

clean_text result/${degree}/spo.md
cat result/${degree}/spo.md \
    | awk '{print "    " $0}' \
    | perl -pne 's/^    §\s*/## § /' \
    | perl -pne 's/^    \(([1-9][0-9]?)\)/\1./g' \
    | perl -pne 's/^    $//g' \
    | perl -0777 -pne 's/\n\n/\n/g' \
    | perl -0777 -pne 's/\n##/\n\n##/g' \
    | perl -0777 -pne 's/\n    (\([1-9][0-9]? LP\))/\1/g' \
    > result/${degree}/spo.md.tmp
mv result/${degree}/spo.md.tmp result/${degree}/spo.md


# extract module description
echo "extracting module explanations" >> $log
for i in 9; do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}/module_explanations.md
clean_text result/${degree}/module_explanations.md

# extract modules
pdftohtml -s -xml caches/${degree}.pdf caches/${degree}/prefix
mergeModulePages 12 ${degree}
export XQ_STARTPAGE=10
export XQ_ENDPAGE=14
./scripts/extractCombinedSPO.xq caches/${degree}/prefix.xml > result/${degree}/modules.yaml

# create home teplate
echo "# Original
Dies ist eine inoffizielle Kopie der Studien- und Prüfungsordnung des ${name} der FU-Berlin.
Das Original ist hier zu finden: [StO/PO 2014 (Bachelor, 0087c)](${url}).

# Modifikation
Bei der Digitalisierung wurden viele kleinere Anpassungen gemacht. Folgende Abweichungen sind bekannt:

- Anlagen 2-4 fehlen
" > result/${degree}/home.md
