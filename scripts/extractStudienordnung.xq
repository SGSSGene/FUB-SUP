#!/usr/bin/env -S xq -y -f
include "helperScript";
include "scripts/helperScript";

# Extract first Part, above Inhalte
[
.pdf2xml.page[]
    | (."@number" | tonumber) as $number
    | select((env.XQ_STARTPAGE | tonumber) <= $number and $number <= (env.XQ_ENDPAGE | tonumber))
#    | select(68 != $number and 69 != $number)
#    | select(19 != $number and 20 != $number)
#    | select(34 != $number and 35 != $number)
#    | select($number == 21)
#    | select($number == 8)
    | .text
    | convert
    | .[].text |= fixes
    | . as $data
    | ["Modul:",
       "Hochschule/Fachbereich/Institut:",
       "Modulverantwort",
       "Zugangsvoraussetzungen:",
       "Qualifikationsziele:",
       "Inhalte:",
       "Präsenzstudium",
#       "Modulprüfung:",
       "Modulsprache:",
       "Pflicht zu regelmäßiger Teilnahme:",
       "Arbeitszeitaufwand insgesamt:",
       "Dauer des Moduls",
       "Häufigkeit des Angebots",
       "Verwendbarkeit",
       "FU-Mitteilungen"] as $list
    | loop(0; ($list | length) - 1; . as $nbr | $data | fetch_section($list[$nbr]; $list[$nbr+1]))
    | (.[6] | extractTeachingUnit) as $tu
    | mergeSimilar
    | [.[] | .[].text
           | textcleanup
      ]
#    | $tu
    | .
    | (.[8] | sub(".*?: "; "")) as $attendance
    | {
        page: $number,
        name: (.[0] | removeTitle),
        organizer: (.[1] | removeTitle | gsub("\n"; " ")),
        responsible: (.[2] | removeTitle),
        requirements: (.[3] | removeTitle),
        goals: (.[4] | removeTitle | textcleanup | gsub("\n"; " ") | gsub(" [-–] "; "\n- ")),
        content: (.[5] | removeTitle | textcleanup | gsub("\n"; " ") | gsub(" [-–] "; "\n- ")),
        teachingunit: $tu.col2,
        workload: $tu.col4,
        exam: "!TODO",
#        exam: (.[7] | removeTitle | textcleanup | gsub("\n"; " ") | gsub("- (?<c>[a-zäöü])"; "\(.c)")),
        language: (.[7] | removeTitle),
        total_work: (.[9] | removeTitle | split(" ")[0] | tonumber),
        credit_points: (.[9] | removeTitle | split(" ")[-2] | tonumber),
        duration: (.[10] | removeTitle),
        repeat: (.[11] | removeTitle),
        usability: (.[12] | removeTitle),
        differentiated: "unknown !TODO"
    }
    | .teachingunit[] |= extractAttendance($attendance)
    | .
]
