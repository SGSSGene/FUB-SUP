#!/usr/bin/env bash

set -Eeuo pipefail

year=2023
degree=bioinf_bsc_2023
url=https://www.imp.fu-berlin.de/fbv/pruefungsbuero/Studien--und-Pruefungsordnungen/StOPO_BSc_Bioinf_2023.pdf

source scripts/convertHelper.sh

tail -f $log &

mkdir -p result/${degree}

# extract front pages
echo "extracting sop" >> $log
for i in $(seq 1 5); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}/spo.md
get_one_column_page 6 >> result/${degree}/spo.md
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
for i in 7; do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}/module_explanations.md
clean_text result/${degree}/module_explanations.md


# extract module description
#
#(
#    for i in $(seq 8 23); do
#        echo "page: $i" >> $log
#        get_module_description_page $i
#    done
#) > result/${degree}/module_descriptions.txt
#
# extract modules
echo "extracting module descriptions"
pdftohtml -s -xml caches/${degree}.pdf caches/${degree}/prefix
#xq -x '.pdf2xml.page[5].text[54]."#text" |= "Selbststudium"' caches/${degree}/prefix.xml > caches/${degree}/prefix2.xml
#cp caches/${degree}/prefix2.xml caches/${degree}/prefix.xml
#mergeModulePages 3 ${degree}
#mergeModulePages 96 ${degree}
#mergeModulePages 94 ${degree}
#mergeModulePages 92 ${degree}
export XQ_STARTPAGE=8
export XQ_ENDPAGE=23
./scripts/extractCombinedSPO.xq caches/${degree}/prefix.xml > result/${degree}/modules.yaml
echo "doing some pretty formatting" >> $log
./scripts/fixTypicalStuff.sh result/${degree}/modules.yaml
./scripts/extractIfModuleisDifferentiated.yq result/${degree}/modules.yaml

# create home template
echo "# Original
Dies ist eine inoffizielle Kopie der Studien- und Prüfungsordnung der Allgeimenen Berufsvorbereitung der Bachelor-Studiengänge der FU-Berlin.
Das Original ist hier zu finden: [StO/PO ${year}](${url}).

# Modifikation
Bei der Digitalisierung wurden viele kleinere Anpassungen gemacht. Folgende Abweichungen sind bekannt:

- Anlage 2 der Studienordnung fehlt
- Anlage 2 und 3 aus Prüfungsordnung fehlt
" > result/${degree}/home.md
