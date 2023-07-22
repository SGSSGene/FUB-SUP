[
..
| select(type=="object" and has("line"))
| .line |= ([.] | flatten)
| .line[].word |= ([.] | flatten)
| .line[].word |= ([.[]."#text"] | join(" "))
| .line |= ([.[].word] | join(" "))
| .line
    ] as $flows
#    | $flows | index("Modul: Datenstrukturen und Datenabstraktion") as $start
    | [$flows[] | startswith("Modul: ") ] | indices(true) | .[env.XQMODULEID | tonumber] as $start
    | [$flows[$start:-1][] | startswith("Leistungspunkte:") ] | index(true) as $finish
    | $flows[$start:$start + $finish + 1]
| .
#| {$start, $finish}
#| ["test"] | .[] | startswith("t")
#| .[] | startswith("Modul")
