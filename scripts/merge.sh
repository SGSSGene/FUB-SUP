#!/usr/bin/env bash

i=$1

g() {
    cat tmp/mod_${1}.txt | head -n $i | tail -1 | tr -d '\n' | awk '{$1=$1}1'
}

h() {
    IFS=','; p=($s); unset IFS;
    echo ${p[$1]}
}

echo "formatversion: 1"
echo "name: \"$(g name)\""
echo "organizer: \"$(g organizer)\""
echo "responsible: \"$(g responsible)\""
echo "requirements: \"$(g requirements)\""
echo "goals: |"
echo "    $(g goals)"
echo "content: |"
echo "    $(g content)"
echo "exam: |"
echo "    $(g exam)"
echo "teachingunit:"
while read s; do
    echo "    - type: \"$(h 0)\""
    echo "      swstime: $(h 1)"
    echo "      attendance: \"$(h 2)\""
    echo "      activity: \"$(h 3)\""
done <<< $(cat lehrformen.txt | head -n $i | tail -1 | tr -d '\n' | awk '{$1=$1}1' | tr '|' '\n')

echo "language: \"$(g language)\""
echo "total_work: $(g total_work)"
echo "credit_points: $(g credit_points)"
echo "duration: \"$(g duration)\""
echo "repeat: \"$(g repeat)\""
echo "usability: |"
echo "    $(g usability)"
