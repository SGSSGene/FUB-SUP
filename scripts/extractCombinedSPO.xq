#!/usr/bin/env -S xq -y -f
include "helperScript";


def fetch_section(_begin; _end):
    .
    | find(.text | startswith(_begin)) as $start_element
    | find(.text | startswith(_end)) as $end_element
    | filter((.top + .height < $end_element.top and .top >= $start_element.top) or
             ($start_element.text == "Modulprüfung:" and ((.text | startswith("Klausur"))
                                                           or (.text | startswith("Schriftliche Ausarbeitung"))
                                                           or (.text | startswith("Präsentation (ca. 15 Minuten"))
                                                           ))
            )
;

def removeTitle:
    . |= sub("^.*:[\n ]+"; "")
;

def loop(_begin; _end; f):
    if (_begin < _end) then
        [_begin | f] + loop(_begin+1; _end; f)
    else
        []
    end
;

def fixes:
    .
    | gsub(" +"; " ")
    | gsub("V-Modul:"; "Modul:")
    | gsub("Praxismodul:"; "Modul:")
    | gsub("Ergänzungsmodul:"; "Modul:")
    | gsub("Basismodul:"; "Modul:")
    | gsub("Aufbaumodul:"; "Modul:")
    | gsub("Vertiefungsmodul:"; "Modul:")
    | gsub("\n+"; "\n")
    | gsub("Verantwort"; "Modulverantwort")
    | gsub("Arbeitsaufwand insgesamt:"; "Arbeitszeitaufwand insgesamt:")
    | gsub("Arbeitsaufwand insgesamt"; "Arbeitszeitaufwand insgesamt:")
    | gsub("Fachbereich Mathematik und Informatik"; "Mathematik und Informatik")
    | gsub("Pflicht +zu +regelmäßigen +Teilnahme"; "Pflicht zu regelmäßiger Teilnahme")
    | gsub("Pflicht +zur +regelmäßigen +Teilnahme"; "Pflicht zu regelmäßiger Teilnahme")
    | gsub("Hochschule/Fachbereich:"; "Hochschule/Fachbereich/Institut:")
    | gsub("Hochschule/Fachbereiche:"; "Hochschule/Fachbereich/Institut:")
    | gsub("Hochschule/Fachbereich/Lehreinheit:"; "Hochschule/Fachbereich/Institut:")
    | gsub("Hochschule/Fachbereich\\(FB\\)/Lehreinheit\\(LE\\):"; "Hochschule/Fachbereich/Institut:")
    | gsub("Veranstaltungssprache:"; "Modulsprache:")
    | gsub("Aktuelle\\(r\\) Verantwortliche\\(r\\):"; "Modulverantwortliche/r:")
;

def mergeSimilar:
    . | [.[] | merge(.last.top+.last.height > .next.top;
                .
                | .last.text = .last.text + " " + .next.text
                | .last.height = ([.last.top + .last.height, .next.top + .next.height] | max) - .last.top
                | .last)
            | merge(true;
                .
                | .last.text = .last.text + "\n" + .next.text
                | .last.height = ([.last.top + .last.height, .next.top + .next.height] | max) - .last.top
                | .last)
      ]
;

def mergeSimilar2:
    . | [.[] | merge(.last.top+.last.height > .next.top;
                .
                | .last.text = .last.text + " " + .next.text
                | .last.height = ([.last.top + .last.height, .next.top + .next.height] | max) - .last.top
                | .last)
            | merge(.last.top+.last.height+5 > .next.top;
                .
                | .last.text = .last.text + "\n" + .next.text
                | .last.height = ([.last.top + .last.height, .next.top + .next.height] | max) - .last.top
                | .last)

      ]
;



def extractTeachingUnit:
    find(.text | startswith("Präsenzstudium")) as $col2
    | find(.text | startswith("Formen aktiver")) as $col3
    | find(.text | endswith("= SWS)")) as $row1
    | . as $data
    | $data | [ .[]
        | select(.left < $col2.left + $col2.width)
        | select(.top > ($row1 | .top + .height))] as $fcol2
    | $data | [ .[]
        | select(.left > $col2.left + $col2.width)
        | select(.left < $col3.left)
        | select(.top > ($row1 | .top + .height))] as $fcol3
    | $data | [ .[]
        | select(.left > $col3.left + $col3.width)
        | select(.top > ($row1 | .top + .height))] as $fcol4
    | (([$fcol3] | mergeSimilar2)[0] | .[] |= .text | [.[] | gsub("[\n ]+";" ") | select(startswith("Klausur") == false) | gsub("- (?<c>[a-zäöü])"; "\(.c)")] | join("\n")) as $activity
    | {
        col2: (([$fcol2] | mergeSimilar2)[0] | .[] |= .text | [.[] | gsub("[\n ]+"; " ")
                | {
                    type: (. | split(" ")[0:-1] | join(" ")),
                    swstime: (. | split(" ")[-1] | gsub(","; ".") | if . == "Stunden" then "9" else . end | tonumber),
                    attendance: "TODO: missing info",
                    activity: $activity
                   }
                ]),
        col4: (([$fcol4] | [.[] | sort_by(.top)] | mergeSimilar2)[0] | .[] |= .text | map(.
            |= {
                type: (. | split(" ")[0:-1] | join(" ") | gsub("\n"; " ")),
                time: (. | split(" ")[-1] | gsub(","; ".") | if . == "Rechner" then 0 else . | tonumber end)
            })),
        }
    | .
;


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
       "Modulprüfung:",
#       "und Prüfung",
       "Modulsprache:",
       "Pflicht zu regelmäßiger Teilnahme:",
       "Arbeitszeitaufwand insgesamt:",
       "Dauer des Moduls",
       "Häufigkeit des Angebots",
       "Verwendbarkeit",
       "FU-Mitteilungen"] as $list
    | loop(0; ($list | length) - 1; . as $nbr | $data | fetch_section($list[$nbr]; $list[$nbr+1]))
#    | .[7]
    | (.[6] | extractTeachingUnit) as $tu
    | mergeSimilar
    | [.[] | .[].text
           | textcleanup
      ]
    | .
    | (.[9] | sub(".*?: "; "")) as $attendance
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
        exam: (.[7] | removeTitle | textcleanup | gsub("\n"; " ") | gsub("- (?<c>[a-zäöü])"; "\(.c)")),
        language: (.[8] | removeTitle),
        total_work: (.[10] | removeTitle | split(" ")[0] | tonumber),
        credit_points: (.[10] | removeTitle | split(" ")[2] | tonumber),
        duration: (.[11] | removeTitle),
        repeat: (.[12] | removeTitle),
        usability: (.[13] | removeTitle)
    }
    | .teachingunit[] |= (
                            .type as $type
                            | .attendance |= $attendance
                            | .attendance |= if $attendance == "Ja" then "required"
                                           elif $attendance == "Teilnahme wird empfohlen" then "recommended"
                                           elif ($attendance | test($type + ": Ja")) then "required"
                                           elif ($attendance | test($type + " und [a-zA-Z]*: Ja")) then "required"
                                           elif ($attendance | test($type + ": Teilnahme wird empfohlen")) then "recommended"
                                           else
                                              "TODO: " + $attendance + ":: " + $type + ": Ja"
                                           end
                        )
]
