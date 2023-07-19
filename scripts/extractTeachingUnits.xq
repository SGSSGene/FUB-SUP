[
    .html.body.doc.page.flow
        | (env.XQPDFCOL | tonumber) as $col
        | .[].block |= ([.] | flatten)
        | .[].block[].line |= ([.] | flatten)
        | .[].block[].line[].word |= ([.] | flatten)
        | walk(if type == "object" and has("@yMin") then ."@xMin" |= (. | tonumber) else . end)
        | walk(if type == "object" and has("@yMax") then ."@xMax" |= (. | tonumber) else . end)
        | walk(if type == "object" and has("@yMin") then ."@yMin" |= (. | tonumber) else . end)
        | walk(if type == "object" and has("@yMax") then ."@yMax" |= (. | tonumber) else . end)
        | . as $flows
        | (.[].block[].line[].word[] | select(."#text"=="SWS)") | ."@yMax") as $yMin
        | (.[].block[].line[].word[] | select(."#text"=="Modulprüfung:") | ."@yMin" ) as $yMax
        | .[].block[]
        | [ .line[]
                | select(."@yMin" >= $yMin)
                | select(."@yMax" <= $yMax)
                | select(."@xMax" <= 4000 or $col != 1)
                | select(."@xMin" > 4000 and ."@xMax" <= 6400 or $col != 2)
                | select(."@xMin" > 6400 and ."@xMax" <= 10515 or $col != 3)
                | select(."@xMin" > 10515 and ."@xMax" < 14500 or $col != 4)
                | select(."@xMin" > 14500 or $col != 5)
                | .word[]
            ]
        | select(length>0)
] | flatten | sort_by(."@yMin") | reduce .[] as {"@yMin": $min, "@yMax": $max, "#text": $text} ([]; .
                                                   | if length == 0 then [{"min": $min, "max": $max, "text": $text}]
                                                     elif .[-1].max+40 > $min then
                                                        .[-1].text |= (. + " " + $text)
                                                        | .[-1].max  |= ([$max, .] | max)
                                                     else
                                                        . + [{"max": $max, "min": $min, "text": $text}]
                                                     end)
| .[].text | sub("- (?<c1>[a-z])"; "\(.c1)")
