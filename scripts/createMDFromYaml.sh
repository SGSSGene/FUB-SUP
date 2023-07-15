#!/usr/bin/env bash

input="$1"

g() {
    yq -r .${1} "${input}" | perl -p -e 's/\*/\\\*/g'
}

echo "# $(g name)"
echo ""
echo "| | |"
echo "|-|-|"
echo "|**Modul**                           | $(g name) |"
echo "|**Hochschule/Fachbereich/Institut** | $(g organizer) |"
echo "|**Modulverantwortung**              | $(g responsible) |"
echo "|**Zugangsvoraussetzungen**          | $(g requirements) |"
echo "|**Qualifikationsziele**             | $(g goals) |"
echo "|**Inhalte**                         | $(g content) |"
echo "|**Modulprüfung**                    | $(g exam) |"
echo "|**Modulsprache**                    | $(g language) |"
echo "|**Arbeitsaufwand (Stunden)**        | $(g total_work)|"
echo "|**Leistungspunkte (LP)**            | $(g credit_points) |"
echo "|**Dauer des Moduls**                | $(g duration) |"
echo "|**Häufigkeit des Angebots**         | $(g repeat) |"
echo "|**Verwendbarkeit**                  | $(g usability) |"

echo ""
echo "| Lehr- und Lernformen | Präsenzstudium <br> (SWS) | Pflicht zur regelmäßiger Teilnahme | Formen aktiver Teilnahme |"
echo "| ---------------------|---------------------------|------------------------------------|------------------------- |"

max=$(expr $(yq -r '.teachingunit[].type' "${input}" | wc -l) - 1)
h() {
    yq -r .teachingunit[$i].${1} "${input}" | perl -p -e 's/\*/\\\*/g'
}
for i in $(seq 0 $max); do
    echo "| $(h type) | $(h swstime) | $(h attendance) | $(h activity) |"
done

