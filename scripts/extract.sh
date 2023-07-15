#!/usr/bin/env bash


input=modules.txt

#rm -rf tmp
mkdir -p tmp
cat ${input} | grep  "^Modul:" | cut -d ' ' -f 2- > tmp/mod_name.txt
cat ${input} | grep  "^Hochschule" | cut -d ' ' -f 2- > tmp/mod_organizer.txt
cat ${input} | grep  "^Modulverant" | cut -d ' ' -f 2- > tmp/mod_responsible.txt
cat ${input} | grep  "^Zugangsvoraussetzung" | cut -d ' ' -f 2- > tmp/mod_requirements.txt
cat ${input} | grep  -Pzo '\nQualifikations(.*\n)+?Inhalte' | tr '\n' ' ' | tr '\0' '\n' | rev | cut -b 9- | rev | cut -d ' ' -f 3- > tmp/mod_goals.txt
cat ${input} | grep  -Pzo '\nInhalte:(.*\n)+?Lehr- und' | tr '\n' ' ' | tr '\0' '\n' | rev | cut -b 11- | rev | cut -d ' ' -f 3- > tmp/mod_content.txt
cat ${input} | grep  -Pzo '\n(Modul|Veranstaltungs)sprache:(.*\n)+?(Pflicht|\s\sArbei|\s\s–\n\nImp)' | tr '\n' ' ' | tr '\0' '\n' | rev | cut -b 9- | rev | cut -d ' ' -f 4- > tmp/mod_language.txt
cat ${input} | grep  -Pzo '\nModulprüfung:(.*\n)+?((Modul|Veranstaltungs)sprache)' | tr '\n' ' ' | tr '\0' '\n'  | rev | cut -d ' ' -f 3- | rev | cut -d ' ' -f 3- > tmp/mod_exam.txt
cat ${input} | grep  -P "Arbeits(zeit)?aufwand insgesamt:" -A 3 | grep "Stunden" | cut -d ' ' -f 1 > tmp/mod_total_work.txt
cat ${input} | grep "^Dauer des Moduls:" -A 3 | awk 'NR % 5 == 3' > tmp/mod_duration.txt
cat ${input} | grep "^Häufigkeit des Angebots:" -A 3 | awk 'NR % 5 == 3' > tmp/mod_repeat.txt
cat ${input} | grep  -Pzo '\nVerwendbarkeit:(.*\n)+?(\n[0-9][0-9][0-9]\n|\nFU-M)' | tr '\n' ' ' | tr '\0' '\n' | rev | cut -b 7- | rev | cut -d ' ' -f 4- > tmp/mod_usability.txt
cat ${input} | grep -P "^[1-9][0-9]? LP$" | cut -d ' ' -f 1 > tmp/mod_credit_points.txt
