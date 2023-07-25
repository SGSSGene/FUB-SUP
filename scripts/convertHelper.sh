# Helper function to convert SOP of the Freie Universität Berlin


# Does typical cleanups of text in a file
clean_text() {
    file="${1}"
    # remove trailing whitespaces
    perl -i -p -e 's/\s*\n/\n/' "${file}"
    # remove leading whitespaces
    perl -i -p -e 's/^\s*([^\s])/\1/' "${file}"
    # Lines starting with a "paragraph" symbol should have a specific formatting "§ 10 Title Of Pragraph"
    perl -i -p -e 's/^(§)\s*([0-9][0-9]?)\s\s*(.*)$/\1 \2 \3/' "${file}"
    # Reduce multiple spaces down to one
    perl -i -p -e 's/  */ /g' "${file}"


    # rewritting words that are written like "Ma-\nthematik" -> "Mathematik"
    perl -0777 -i -p -e 's/-\n\n*([a-z])/\1/g' "${file}"

    # erwritting words like "Antwort-\nWahl" -> "Antwort-Wahl"
    perl -0777 -i -p -e 's/-\n\n*([A-Z])/-\1/g' "${file}"

    # Write title of pragraph in the same line as the pragraph symbol
    perl -0777 -i -p -e 's/(§\s[0-9][0-9]?)\s*\n/\1 /g' "${file}"

    # Remove spaces between list items
    perl -0777 -i -p -e 's/\n–([^\n]*)\n\n+–/\n–\1\n–/g' "${file}"
    perl -0777 -i -p -e 's/\n–([^\n]*)\n\n+–/\n–\1\n–/g' "${file}"

    # replace unicode dashes, with ascii dashes
    perl -i -p -e 's/–/-/g' "${file}"
}

# receives a page that consist out of two columns
get_two_column_page() {
    page=$1
    pdftotext -fixed 16 ${input} $tmp/astext.txt -x 1 -y 240 -W 3200 -H 2900 -r 288 -f ${page} -l ${page}
    cat $tmp/astext.txt | cut -c 11-76 | iconv -c
    cat $tmp/astext.txt | cut -c 77- | iconv -c
}

# receives a page that consist out of two columns
get_one_column_page() {
    page=$1
    pdftotext -fixed 16 ${input} $tmp/astext.txt -x 1 -y 240 -W 3200 -H 2900 -r 288 -f ${page} -l ${page}
    cat $tmp/astext.txt
}


fix_spelling_mistakes() {
    # Mistakes in informatik bachelor 2023
    perl -i -p -e "s|ul: Dozent\*in des Moduls gemäß der Zuordnungsliste bei dem\*der Studiengangsverantwortlichen|Modulverantwortliche: Dozent*in des Moduls gemäß der Zuordnungsliste bei dem*der Studiengangsverantwortlichen|g" ${1}
    perl -i -p -e "s|ul: Freie Universität Berlin/Mathematik und Informatik/Informatik|Hochschule/Fachbereich/Lehreinheit: Freie Universität Berlin/Mathematik und Informatik/Informatik|g" ${1}
    perl -i -p -e "s|ul: Programmierpraktikum, Softwaretechnik|Zugangsvoraussetzungen: Programmierpraktikum, Softwaretechnik|g" ${1}
    perl -i -p -e "s|Veranstaltungssprache|Modulsprache:|g" ${1}
    perl -i -p -e "s|Freie Universität Berlin/ Mathematik und Informatik/Informatik|Freie Universität Berlin/Mathematik und Informatik/Informatik|g" ${1}
    perl -i -p -e "s|Erfolgreiche Absolvierung des Moduls „Wissenschaftliches Arbeiten in der Informatik“|Wissenschaftliches Arbeiten in der Informatik|g" ${1}
    perl -i -p -e "s|Bachelorstudiengang Informatik: Studienbereich ABV \(Fachnahe Zusatzqualifikation 5 LP|Bachelorstudiengang Informatik: Studienbereich ABV (Fachnahe Zusatzqualifikation 5 LP)|g" ${1}
}

get_module_description_page() {
    page=$1
    lastpage=${2:-$1}
    pdftotext -nopgbrk -fixed 16 ${input} $tmp/astext.txt -x 1 -y 240 -W 3200 -H 2900 -r 288 -f ${page} -l ${lastpage}
    fix_spelling_mistakes $tmp/astext.txt


    startlinenbr=$(cat $tmp/astext.txt | grep -P -n " (V-M|Praxism|M)odul:" | head -n 1 | cut -d ':' -f 1)
    linenbr=$(expr $(cat $tmp/astext.txt | grep -n "Lehr- und" | head -n 1 | cut -d ':' -f 1) - 1)

    # extract top Part: until the "Lehr- und Lernformen" boxes start
    head -n $linenbr $tmp/astext.txt | tail -n +${startlinenbr} > $tmp/front.txt
    clean_text $tmp/front.txt

    local front="${tmp}/front.txt"
    export JQ_NAME=$(cat ${front} | grep  "^Modul:" | cut -d ' ' -f 2-)
    export JQ_ORGANIZER=$(cat ${front} | grep  "^Hochschule" | cut -d ' ' -f 2-)
    export JQ_RESPONSIBLE=$(cat ${front} | grep  "^Modulverant" | cut -d ' ' -f 2-)
    export JQ_REQUIREMENTS=$(cat ${front} | grep  "^Zugangsvoraussetzung" | cut -d ' ' -f 2-)
    export JQ_GOALS=$(cat ${front} | grep  -Pzo '\nQualifikations(.*\n)+?Inhalte' | tr '\n' ' ' | tr '\0' '\n' | rev | cut -b 9- | rev | cut -d ' ' -f 3-)
    export JQ_CONTENT=$(cat ${front} | sed -n '/Inhalte:/,$p' | tail +2)

    # Extract the Part starting with "Modulprüfung"
    pdftotext ${input} -fixed 120 -r 2048 -f $page -l $lastpage /dev/stdout -bbox-layout > $tmp/teachingunits.xml

    XQPDFCOL=1 xq -f scripts/extractDescriptionPart2.xq $tmp/teachingunits.xml > $tmp/descPart2_left.json
    XQPDFCOL=2 xq -f scripts/extractDescriptionPart2.xq $tmp/teachingunits.xml > $tmp/descPart2_right.json

    export JQ_EXAM=$(jq -r '.[0]' $tmp/descPart2_right.json )
    export JQ_LANGUAGE=$(jq '.[1]' $tmp/descPart2_right.json)
    export JQ_TOTAL_WORK=$(jq -r '.[3] | split(" ") | .[0]' $tmp/descPart2_right.json)
    export JQ_CREDIT_POINTS=$(jq -r '.[3] | split(" ") | .[2]' $tmp/descPart2_right.json)
    export JQ_DURATION=$(jq '.[4]' $tmp/descPart2_right.json)
    export JQ_REPEAT=$(jq '.[5]' $tmp/descPart2_right.json)
    export JQ_USABILITY=$(jq -r '.[6]' $tmp/descPart2_right.json)

    # extract the "Lehr- und Lernformen" part
    export JQ_TU_TYPE=$(cat $tmp/teachingunits.xml | XQPDFCOL=1 xq -f scripts/extractTeachingUnits.xq)
    export JQ_TU_SWSTIME=$(cat $tmp/teachingunits.xml | XQPDFCOL=2 xq -f scripts/extractTeachingUnits.xq)
    export JQ_TU_PARTICIPATION=$(cat $tmp/teachingunits.xml | XQPDFCOL=3 xq -f scripts/extractTeachingUnits.xq)

    export JQ_TEACHINGUNIT=$(yq -n '{
        type: (env.JQ_TU_TYPE | fromjson),
        swstime: (env.JQ_TU_SWSTIME | fromjson),
        activity: (env.JQ_TU_PARTICIPATION | fromjson)
    } | .type |= map({type: .})
    # Hack, some entries have 260h written into them :-(
      | .swstime |= map({swstime: (try (. | tonumber) catch .)})
      | .activity |= map({activity: .})
      | [.type, .swstime, .activity]
      | transpose
      | map(add)
    ')
    export JQ_WL_NAME=$(cat $tmp/teachingunits.xml | XQPDFCOL=4 xq -f scripts/extractTeachingUnits.xq)
    export JQ_WL_HOURS=$(cat $tmp/teachingunits.xml | XQPDFCOL=5 xq -r -f scripts/extractTeachingUnits.xq)
    export JQ_WORKLOAD=$(yq -n '{
        type: (env.JQ_WL_NAME | fromjson),
        time: (env.JQ_WL_HOURS | fromjson)
    } | .type |= map({type: .})
      | .time |= map({time: . | tonumber})
      | [.type, .time]
      | transpose
      | map(add)
    ')
   yq -ny '{
        name: (env.JQ_NAME | tostring),
        organizer: env.JQ_ORGANIZER,
        responsible: env.JQ_RESPONSIBLE,
        requirements: env.JQ_REQUIREMENTS,
        goals: env.JQ_GOALS,
        content: env.JQ_CONTENT,
        exam: env.JQ_EXAM,
        teachingunit: (env.JQ_TEACHINGUNIT | fromjson),
        workload: (env.JQ_WORKLOAD | fromjson),
        language: (env.JQ_LANGUAGE | fromjson),
        total_work: (env.JQ_TOTAL_WORK | tonumber),
        credit_points: (env.JQ_CREDIT_POINTS | tonumber),
        duration: (env.JQ_DURATION | fromjson),
        repeat: (env.JQ_REPEAT | fromjson),
        usability: env.JQ_USABILITY
    }';
}

# Some setup lines
if [ ! -e caches/$degree.pdf ]; then
    mkdir -p caches
    wget $url -O caches/$degree.pdf
fi

input=caches/$degree.pdf
tmp=caches/$degree
#rm -rf $tmp
mkdir -p $tmp
mkdir -p result
log=${tmp}/log
rm -f $log
touch $log
