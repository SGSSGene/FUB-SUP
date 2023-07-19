[
    .html.body.doc.page
        | (env.XQPDFCOL | tonumber) as $col
#        | try (.[0].flow = .[0].flow + .[1].flow | . = .[0] | .) catch .
        | .flow
        | .[].block |= ([.] | flatten)
        | .[].block[].line |= ([.] | flatten)
        | .[].block[].line[].word |= ([.] | flatten)
        | walk(if type == "object" and has("@yMin") then ."@xMin" |= (. | tonumber) else . end)
        | walk(if type == "object" and has("@yMax") then ."@xMax" |= (. | tonumber) else . end)
        | walk(if type == "object" and has("@yMin") then ."@yMin" |= (. | tonumber) else . end)
        | walk(if type == "object" and has("@yMax") then ."@yMax" |= (. | tonumber) else . end)
        | . as $flows
        | (.[].block[].line[].word[] | select(."#text"=="Modulprüfung:") | ."@yMin" | . - 600) as $yMin
        | .[].block[]
        | [ .line[]
                | select(."@yMin" >= $yMin)
                | select(."@xMax" <= 6400 or $col != 1)
                | select(."@xMin" > 6400 or $col != 2)
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
