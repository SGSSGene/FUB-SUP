..
| select(type=="object" and has("line"))
#| .line |= ([.] | flatten)
#| .line[].word |= ([.] | flatten)
#| .line[].word |= ([.[]."#text"] | join(" "))
#| .line |= ([.[].word] | join(" "))
#| .line

#| .line[].word
#| .line[].word
| .

