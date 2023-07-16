#!/usr/bin/env bash

# One way of calling this script, is inside a loop:
#
#     for i in $(seq 36); do
#       filename=$(cat tmp/mod_name.txt | head -n $i | tail -1 | tr -d '\n' | awk '{$1=$1}1')
#         ./scripts/merge.sh $i scripts/inf_bsc_2023 > "inf_bsc_2023_mods/${filename}.yaml"
#     done

i=$1
f1=$2

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
done <<< $(cat ${f1}_teachingunit.txt | head -n $i | tail -1 | tr -d '\n' | awk '{$1=$1}1' | tr '|' '\n')
echo "workload:"
while read s; do
    echo "    - type: \"$(h 0)\""
    echo "      time: $(h 1)"
done <<< $(cat ${f1}_workload.txt | head -n $i | tail -1 | tr -d '\n' | awk '{$1=$1}1' | tr '|' '\n')

echo "language: \"$(g language)\""
echo "total_work: $(g total_work)"
echo "credit_points: $(g credit_points)"
echo "duration: \"$(g duration)\""
echo "repeat: \"$(g repeat)\""
echo "usability: |"
echo "    $(g usability)"
