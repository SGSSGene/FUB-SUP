def merge(pred; f):
    . | reduce .[] as $next ([];
        . | if (length == 0) then [$next]
        elif ({last: .[-1], next: $next} | pred) then
            .[-1] = ({last: .[-1], next: $next} | f) | .
        else
            . + [$next]
        end)
;

def convert:
    map(.text =
            if has("b") then .b
            elif has("a") then .a
            elif has("#text") then ."#text"
            else "" end
#            else "has no text field: " + (. | tojson) end
    ) | map(. as {"@top": $top,
          "@height": $height,
          "@left": $left,
          "@width": $width,
          "text": $text}
        | {
            top: ($top | tonumber),
            height: ($height | tonumber),
            left: ($left | tonumber),
            width: ($width | tonumber),
            text: $text
        })
;
def textcleanup:
    .
    | sub("^ *"; "") # remove leading whitespaces
    | gsub("●"; "-") # remove leading whitespaces
    | sub("[\n ]*$"; "") # remove trailing whitespaces
    | gsub("-\n+(?<c1>[a-zäöü])"; "\(.c1)") # remove word wrapping
;

def find(pred):
    .[] | select(pred)
;

def filter(pred):
    [.[] | select(pred)]
;


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
    | gsub("^Verantwort[a-z]*(/[a-z]*)?:"; "Modulverantwortung:")
    | gsub("Arbeitsaufwand insgesamt:?"; "Arbeitszeitaufwand insgesamt:")
    | gsub("Fachbereich Mathematik und Informatik"; "Mathematik und Informatik")
    | gsub("Pflicht +zur +regelmäßiger +Teilnahme:?"; "Pflicht zu regelmäßiger Teilnahme:")
    | gsub("Pflicht +zu +regelmäßigen +Teilnahme:?"; "Pflicht zu regelmäßiger Teilnahme:")
    | gsub("Pflicht +zur +regelmäßigen +Teilnahme:?"; "Pflicht zu regelmäßiger Teilnahme:")
    | gsub("[Rr]egelmäßige Teilnahme:?"; "Pflicht zu regelmäßiger Teilnahme:")
    | gsub("Teilnahme wird dringend empfohlen"; "Teilnahme wird empfohlen")
    | gsub("Hochschule/Zentraleinrichtung:"; "Hochschule/Fachbereich/Institut:")
    | gsub("Hochschule/Einrichtung:"; "Hochschule/Fachbereich/Institut:")
    | gsub("Hochschule/Fachbereich:"; "Hochschule/Fachbereich/Institut:")
    | gsub("Hochschule/Fachbereiche:"; "Hochschule/Fachbereich/Institut:")
    | gsub("Hochschule/FachbereichLehreinheit:"; "Hochschule/Fachbereich/Institut:")
    | gsub("Hochschule/Hochschule/Fachbereich/Lehreinheit:"; "Hochschule/Fachbereich/Institut:")
    | gsub("Hochschule/Fachbereich/Lehreinheit:"; "Hochschule/Fachbereich/Institut:")
    | gsub("Hochschule/Fachbereich\\(FB\\)/Lehreinheit\\(LE\\):"; "Hochschule/Fachbereich/Institut:")
    | gsub("Veranstaltungssprache:?"; "Modulsprache:")
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
    .
    | find(.text | startswith("Präsenzstudium")) as $col2
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
                    swstime: (if endswith(" 270 Stunden") then "9" else split(" ")[-1] | gsub(","; ".") end | tonumber),
                    attendance: "TODO: missing info",
                    activity: $activity
                   }
                ]),
        col4: (([$fcol4] | [.[] | sort_by(.top)] | mergeSimilar2)[0] | .[] |= .text | map(.
            |= (. | gsub("^(?<c1>[ a-zA-ZäüöÄÜÖ-]*) (?<c2>[0-9]+) (?<c3>[ a-zA-ZäüöÄÜÖ-]*)$"; "\(.c1) \(.c3) \(.c2)") | {
                type: (. | split(" ")[0:-1] | join(" ") | gsub("\n"; " ")),
                time: (. | split(" ")[-1] | gsub(","; ".") | if . == "Rechner" then 0 else . | tonumber end)
            }))),
        }
    | .
;


def extractAttendance(attendance):
    .type as $type
    | .attendance |= attendance
    | .attendance |= if attendance == "Ja" then "required"
                   elif attendance == "Teilnahme wird empfohlen" then "recommended"
                   elif attendance == "Teilnahme wird dringend empfohlen" then "recommended"
                   elif (attendance | test($type + ": Ja")) then "required"
                   elif (attendance | test($type + " und [a-zA-Z]*: Ja")) then "required"
                   elif (attendance | test($type + ": Teilnahme wird empfohlen")) then "recommended"
                   elif (attendance | test($type + ": Teilnahme wird dringend empfohlen")) then "recommended"

                   else
                      "TODO: " + attendance + ":: " + $type + ": Ja"
                   end
;
