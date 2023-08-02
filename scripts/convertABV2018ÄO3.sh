#!/usr/bin/env bash

set -Eeuo pipefail

degree=abv_2018_aeo3
url=https://www.fu-berlin.de/service/zuvdocs/amtsblatt/2022/ab182022.pdf#G2157029

source scripts/convertHelper.sh

tail -f $log &

mkdir -p result/${degree}

# extract front pages
#echo "extracting spo" >> $log
#for i in $(seq 2 7); do
#    echo "page: $i" >> $log
#    get_two_column_page $i
#done > result/${degree}/spo.md
#clean_text result/${degree}/spo.md

#cat result/${degree}/spo.md \
#    | awk '{print "    " $0}' \
#    | perl -pne 's/^    §\s*/## § /' \
#    | perl -pne 's/^    \(([1-9][0-9]?)\)/\1./g' \
#    | perl -pne 's/^    $//g' \
#    | perl -0777 -pne 's/\n\n/\n/g' \
#    | perl -0777 -pne 's/\n##/\n\n##/g' \
#    | perl -0777 -pne 's/\n    (\([1-9][0-9]? LP\))/\1/g' \
#    > result/${degree}/spo.md.tmp
#mv result/${degree}/spo.md.tmp result/${degree}/spo.md


# extract module description
#echo "extracting module explanations" >> $log
#for i in 8; do
#    echo "page: $i" >> $log
#    get_two_column_page $i
#done > result/${degree}/module_explanations.md
#clean_text result/${degree}/module_explanations.md

# extract modules
pdftohtml -s -xml caches/${degree}.pdf caches/${degree}/prefix
xq -x '.pdf2xml.page[5].text[28]."#text" |= "Modulprüfung:" |
       .pdf2xml.page[6].text[61]."#text" |= "Modulprüfung:"' caches/${degree}/prefix.xml > caches/${degree}/prefix2.xml
cp caches/${degree}/prefix2.xml caches/${degree}/prefix.xml
mergeModulePages 5 ${degree}
#mergeModulePages 96 ${degree}
#mergeModulePages 94 ${degree}
#mergeModulePages 92 ${degree}
export XQ_STARTPAGE=5
export XQ_ENDPAGE=7
./scripts/extractCombinedSPO.xq caches/${degree}/prefix.xml > result/${degree}/modules.yaml

## create home template
#echo "# Original
#Dies ist eine inoffizielle Kopie der Studien- und Prüfungsordnung der Allgeimenen Berufsvorbereitung der Bachelor-Studiengänge der FU-Berlin.
#Das Original ist hier zu finden: [StO/PO SoSe 2018](${url}).
#
## Modifikation
#Bei der Digitalisierung wurden viele kleinere Anpassungen gemacht. Folgende Abweichungen sind bekannt:
#
#- Anlage 2 fehlt
#" > result/${degree}/home.md
