#!/usr/bin/env bash

file="${1}"

extractSection() {
    local begin=${1}
    local end=${2}
    local idx=${3}
    local file=${4}
    local out=${5}

    local start_line=$(grep -n "^${begin}" ${file} | cut -f 1 -d ':' | tail +${idx} | head -n 1)
    local end_line=$(grep -n "^${end}" ${file} | cut -f 1 -d ':' | tail +${idx} | head -n 1)
    head -n ${start_line} ${file} > ${out}.p1
    tail +$(expr $start_line + 1) $file | head -n $(expr ${end_line} - ${start_line} - 1) | perl -p -e 's|^    ||' > ${out}.p2
    tail +${end_line} $file > ${out}.p3
}

formatSection() {
    local begin=${1}
    local end=${2}
    local idx=${3}
    local input=${4}
    extractSection "${begin}" "${end}" ${idx} "${input}" "${input}"
    mdformat --number --wrap 76 ${input}.p2
    if [ $(cat ${input}.p2 | head -n 1 | grep "^-" | wc -l) -eq 1 ]; then
        mv ${input}.p2 ${input}.p4
        echo "" | cat - ${input}.p4 > ${input}.p2
    fi
    perl -i -p -e 's|^(.)|    \1|g' ${input}.p2
    cat ${input}.p1 ${input}.p2 ${input}.p3 > tmp.part
    rm ${input}.{p1,p2,p3}
}

#perl -0777 -p -e 's|\n  goals: '"'"'(.*)'"'"'\n  content:|\1\n    content:|g' "${file}"
cat "${file}" \
 | ./scripts/fixTypicalStuff.yq \
 | perl -p -e 's|^    >   |       |g' \
 > tmp.part

l=$(yq ". | length" tmp.part)
for i in $(seq 1 ${l}); do
    echo "module i: $i/$l"
    formatSection "  goals: |" "  content: |" $i tmp.part
    formatSection "  content: |" "  teachingunit:" $i tmp.part
    formatSection "  exam: |" "  language:" $i tmp.part
    formatSection "  usability: |" "  differentiated:" $i tmp.part
done
cp tmp.part ${file}



# | perl -0777 -p -e 's|\n  goals: '"'"'(.*(\n.*?)*?)'"'"'\n  content:|\n  goals: \|\n    \1\n  content:|g' \
# | perl -0777 -p -e 's|\n  content: '"'"'(.*(\n.*?)*?)'"'"'\n  teachingunit:|\n  content: \|\n    \1\n  teachingunit:|g' \
# | perl -0777 -p -e 's|\n  usability: '"'"'(.*(\n.*?)*?)'"'"'\n  differentiated:|\n  usability: \|\n    \1\n  differentiated:|g' \
# | perl -0777 -p -e 's|\n  goals: ([^\|].*(\n.*?)*?)\n  content:|\n  goals: \|\n    \1\n  content:|g' \
# | perl -0777 -p -e 's|\n  content: ([^\|].*(\n.*?)*?)\n  teachingunit:|\n  content: \|\n    \1\n  teachingunit:|g' \
# | perl -0777 -p -e 's|\n  usability: ([^\|].*(\n.*?)*?)\n  differentiated:|\n  usability: \|\n    \1\n  differentiated:|g' \

