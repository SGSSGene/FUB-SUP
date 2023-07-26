#!/usr/bin/env bash

set -Eeuo pipefail

name="lehramtsbezogene Physik Bachelors"
degree=lehrphy_bsc_2015
url=https://www.imp.fu-berlin.de/fbv/pruefungsbuero/Studien--und-Pruefungsordnungen/StOPO-2015.pdf

source scripts/convertHelper.sh

tail -f $log &

mkdir -p result/${degree}

# extract front pages
echo "extracting spo" >> $log
for i in $(seq 2 7); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}/spo.md
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
for i in 8; do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}/module_explanations.md
clean_text result/${degree}/module_explanations.md

# extract modules
pdftohtml -s -xml caches/${degree}.pdf caches/${degree}/prefix
# merge pages
xq -x '.pdf2xml.page[9].text[]."@top" |= ((. | tonumber) + 10000 | tostring) | .pdf2xml.page[8].text = .pdf2xml.page[8].text + .pdf2xml.page[9].text' caches/${degree}/prefix.xml > caches/${degree}/prefix.xml.tmp
xq -x 'del(.pdf2xml.page[9])
       | .pdf2xml.page[8].text |= del(.[0, 1])' caches/${degree}/prefix.xml.tmp > caches/${degree}/prefix.xml
#mv caches/${degree}/prefix.xml.tmp caches/${degree}/prefix.xml

export XQ_STARTPAGE=9
export XQ_ENDPAGE=21
./scripts/extractCombinedSPO.xq caches/${degree}/prefix.xml > result/${degree}/modules.yaml

# create home teplate
echo "
# Original
Dies ist eine inoffizielle Kopie der Studien- und Prüfungsordnung des ${name} der FU-Berlin.
Das Original ist hier zu finden: [StO/PO 2015 (Bachelor)](${url}).

# Modifikation
Bei der Digitalisierung wurden viele kleinere Anpassungen gemacht. Folgende Abweichungen sind bekannt:

- Anlagen 2-4 fehlen
" > result/${degree}/home.md
