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



