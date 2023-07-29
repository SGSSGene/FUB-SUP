#!/usr/bin/env bash

set -Eeuo pipefail

degree=datasci_msc_2019
url=https://www.imp.fu-berlin.de/fbv/pruefungsbuero/Studien--und-Pruefungsordnungen/STOPO_MSc_Data-Science-2019.pdf

source scripts/convertHelper.sh

tail -f $log &

mkdir -p result/${degree}

# extract front pages
echo "extracting spo" >> $log
for i in $(seq 2 9); do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}/spo.md
#get_one_column_page 8 >> result/${degree}/spo.md

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
for i in 10; do
    echo "page: $i" >> $log
    get_two_column_page $i
done > result/${degree}/module_explanations.md
clean_text result/${degree}/module_explanations.md

# extract modules
pdftohtml -s -xml caches/${degree}.pdf caches/${degree}/prefix
#mergeModulePages 12 ${degree}
export XQ_STARTPAGE=11
export XQ_ENDPAGE=35
./scripts/extractCombinedSPO.xq caches/${degree}/prefix.xml > result/${degree}/modules.yaml

# create home teplate
echo "# Original
Dies ist eine inoffizielle Kopie der Studien- und Prüfungsordnung des Data Science Masters der FU-Berlin.
Das Original ist hier zu finden: [StO/PO 2019 (Master, 0590a)](${url}).

# Modifikation
Bei der Digitalisierung wurden viele kleinere Anpassungen gemacht. Folgende Abweichungen sind bekannt:

- Anlagen 2-4 fehlen
- Es fehlt der gesamte Abschitt auf Seite 253, wo auf andere Module verwiesen wird...

    > Für die folgenden drei Module wird auf die Studien- und
    > Prüfungsordnung für den Masterstudiengang Bioinfor matik der Fachbereiche Biologie, Chemie, Pharmazie
    > sowie Mathematik und Informatik der Freien Universität
    > Berlin und der Fakultät der Charité – Universitätsmedizin Berlin verwiesen
    >    – Modul: Maschinelles Lernen in der Bioinformatik (5 LP),
    >    – Modul: Analyse großer Datensätze in der Bioinformatik (5 LP),
    >    – Modul: Netzwerkanalyse (10 LP).
    > Für die folgenden neun Module wird auf die Studien- und Prüfungsordnung für den Masterstudiengang Informatik des Fachbereichs Mathematik und Informatik der
    > Freien Universität Berlin verwiesen:
    > – Modul: Verteilte Systeme (5 LP),
    > – Modul: Mobilkommunikation (5 LP),
    > – Modul: Telematik (10 LP),
    > – Modul: Mustererkennung (5 LP),
    > – Modul: Rechnersicherheit (10 LP),
    > – Modul: Mustererkennung (5 LP),
    > – Modul: Netzbasierte Informationssysteme (5 LP),
    > – Modul: Mustererkennung (5 LP),
    > – Modul: Spezielle Aspekte der Datenverwaltung (5LP).



" > result/${degree}/home.md
