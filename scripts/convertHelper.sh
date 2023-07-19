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
    pdftotext -fixed 16 ${input} tmp/astext.txt -x 1 -y 240 -W 3200 -H 2900 -r 288 -f ${page} -l ${page}
#    cat tmp/astext.txt
    cat tmp/astext.txt | cut -c 11-75
    cat tmp/astext.txt | cut -c 76-
}

get_module_description_page() {
    page=$1
    lastpage=${2:-$1}
    pdftotext -nopgbrk -fixed 16 ${input} tmp/astext.txt -x 1 -y 240 -W 3200 -H 2900 -r 288 -f ${page} -l ${lastpage}
    startlinenbr=$(cat tmp/astext.txt | grep -n " Modul:" | head -n 1 | cut -d ':' -f 1)
    linenbr=$(expr $(cat tmp/astext.txt | grep -n "Lehr- und" | head -n 1 | cut -d ':' -f 1) - 1)

    # extract top Part: until the "Lehr- und Lernformen" boxes start
    head -n $linenbr tmp/astext.txt | tail -n +${startlinenbr} > tmp/front.txt
    clean_text tmp/front.txt
    cat tmp/front.txt

    # Extract the Part starting with "Modulprüfung"
    pdftotext -nopgbrk -fixed 120 ${input} -r 2048 -f $page -l $lastpage /dev/stdout -bbox-layout > tmp/teachingunits.xml

    XQPDFCOL=1 xq -r -f scripts/extractDescriptionPart2.xq tmp/teachingunits.xml > tmp/descPart2_left.txt
    XQPDFCOL=2 xq -r -f scripts/extractDescriptionPart2.xq tmp/teachingunits.xml > tmp/descPart2_right.txt

    for i in $(seq 1 7); do
        cat tmp/descPart2_left.txt | head -n $i | tail -n 1
        cat tmp/descPart2_right.txt | head -n $i | tail -n 1
    done

    # extract the "Lehr- und Lernformen" part
    echo "units:";
    cat tmp/teachingunits.xml | XQPDFCOL=1 xq -r -f scripts/extractTeachingUnits.xq
    echo "sws:";
    cat tmp/teachingunits.xml | XQPDFCOL=2 xq -r -f scripts/extractTeachingUnits.xq
    echo "active participation:";
    cat tmp/teachingunits.xml | XQPDFCOL=3 xq -r -f scripts/extractTeachingUnits.xq
    echo "work_load_name:";
    cat tmp/teachingunits.xml | XQPDFCOL=4 xq -r -f scripts/extractTeachingUnits.xq
    echo "work_load_hours:";
    cat tmp/teachingunits.xml | XQPDFCOL=5 xq -r -f scripts/extractTeachingUnits.xq
}
