#!/usr/bin/env bash

set -Eeuo pipefail

TMP=tmp/create_cross_links
rm -rf ${TMP}
mkdir -p ${TMP}/names

for major in $(ls data); do
    module_file=data/${major}/modules.yaml
    if [ ! -e ${module_file} ]; then continue; fi
    yq -r '.[].name' ${module_file} | sort > ${TMP}/names/${major}.txt
done

for major in $(ls ${TMP}/names); do
    for major2 in $(ls ${TMP}/names); do
        if [ ${major} = ${major2} ]; then continue; fi
        f1=${TMP}/names/${major}
        f2=${TMP}/names/${major2}

        major_file=$(echo $major | rev | cut -c 5- | rev)
        major2_file=$(echo $major2 | rev | cut -c 5- | rev)

        cat $f1 $f2 | sort | uniq -d | while read subject
        do

            export major=${major2_file}
            export cross_link=${major2_file}/modules/${subject}
            export subject=${subject}
            module_file=data/${major_file}/modules.yaml
            yq -z -Y -w 80 '[.[] |
                if .name == env.subject then
                    if .cross_link == null then
                        .cross_link |= []
                    end
                    | if [.cross_link[] | select(. == {major: env.major, subject: env.subject})] | length == 0 then
                        .cross_link += [{major: env.major, subject: env.subject}]
                    end
                end]' $module_file > $module_file.new
            ./scripts/prettyprinter.sh ${module_file}.new
            mv $module_file.new $module_file
            echo $module_file.new $module_file
        done
    done
done
