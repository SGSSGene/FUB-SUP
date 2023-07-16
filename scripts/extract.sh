#!/usr/bin/env bash


input=modules.txt

#rm -rf tmp
mkdir -p tmp
# Some error corrections for inf bsc 2023
perl -i -p -e "s|^ul: Dozent\*in des Moduls gemäß der Zuordnungsliste bei dem\*der Studiengangsverantwortlichen|Modulverantwortliche: Dozent*in des Moduls gemäß der Zuordnungsliste bei dem*der Studiengangsverantwortlichen|g" ${input}
perl -i -p -e "s|^ul: Freie Universität Berlin/Mathematik und Informatik/Informatik|Hochschule/Fachbereich/Lehreinheit: Freie Universität Berlin/Mathematik und Informatik/Informatik|g" ${input}
perl -i -p -e "s|^ul: Programmierpraktikum, Softwaretechnik|Zugangsvoraussetzungen: Programmierpraktikum, Softwaretechnik|g" ${input}
perl -i -p -e "s|^Veranstaltungssprache|Modulsprache:|g" ${input}
perl -i -p -e "s|Freie Universität Berlin/ Mathematik und Informatik/Informatik|Freie Universität Berlin/Mathematik und Informatik/Informatik|g" ${input}
perl -i -p -e "s|Erfolgreiche Absolvierung des Moduls „Wissenschaftliches Arbeiten in der Informatik“|Wissenschaftliches Arbeiten in der Informatik|g" ${input}
perl -i -p -e "s|Bachelorstudiengang Informatik: Studienbereich ABV \(Fachnahe Zusatzqualifikation 5 LP|Bachelorstudiengang Informatik: Studienbereich ABV (Fachnahe Zusatzqualifikation 5 LP)|g" ${input}

cat ${input} | grep  "^Modul:" | cut -d ' ' -f 2- > tmp/mod_name.txt
cat ${input} | grep  "^Hochschule" | cut -d ' ' -f 2- > tmp/mod_organizer.txt
cat ${input} | grep  "^Modulverant" | cut -d ' ' -f 2- > tmp/mod_responsible.txt
cat ${input} | grep  "^Zugangsvoraussetzung" | cut -d ' ' -f 2- > tmp/mod_requirements.txt
cat ${input} | grep  -Pzo '\nQualifikations(.*\n)+?Inhalte' | tr '\n' ' ' | tr '\0' '\n' | rev | cut -b 9- | rev | cut -d ' ' -f 3- > tmp/mod_goals.txt
cat ${input} | grep  -Pzo '\nInhalte:(.*\n)+?Lehr- und' | tr '\n' ' ' | tr '\0' '\n' | rev | cut -b 11- | rev | cut -d ' ' -f 3- > tmp/mod_content.txt
cat ${input} | grep  -Pzo '\nModulsprache:(.*\n)+?(Pflicht|\s\sArbei|\s\s–\n\nImp)' | tr '\n' ' ' | tr '\0' '\n' | rev | cut -b 9- | rev | cut -d ' ' -f 4- > tmp/mod_language.txt
cat ${input} | grep  -Pzo '\nModulprüfung:(.*\n)+?Modulsprache' | tr '\n' ' ' | tr '\0' '\n'  | rev | cut -d ' ' -f 3- | rev | cut -d ' ' -f 3- > tmp/mod_exam.txt
cat ${input} | grep  -P "Arbeits(zeit)?aufwand insgesamt:" -A 3 | grep "Stunden" | cut -d ' ' -f 1 > tmp/mod_total_work.txt
cat ${input} | grep "^Dauer des Moduls:" -A 3 | awk 'NR % 5 == 3' > tmp/mod_duration.txt
cat ${input} | grep "^Häufigkeit des Angebots:" -A 3 | awk 'NR % 5 == 3' > tmp/mod_repeat.txt
cat ${input} | grep  -Pzo '\nVerwendbarkeit:(.*\n)+?(\n[0-9][0-9][0-9]\n|\nFU-M)' | tr '\n' ' ' | tr '\0' '\n' | rev | cut -b 7- | rev | cut -d ' ' -f 4- > tmp/mod_usability.txt
cat ${input} | grep -P "^[1-9][0-9]? LP$" | cut -d ' ' -f 1 > tmp/mod_credit_points.txt
