#!/usr/bin/env bash

path="${1}"
input="data/${path}"
output="docs/${path}"

export YQ_TAG=${path}

mkdir -p ${output}/modules

ct=$(yq "(. | length) - 1" ${input}/modules.yaml)

yq -y '[.[] | select(has("link")) | .link] | sort_by(.) | unique | reduce .[] as $e ({ct: 1}; .[$e] = .ct | .ct |= . + 1)' ${input}/modules.yaml > tmp.yaml
linkmodules=$(yq -r '[.[] | select(has("link")) | .link] | sort_by(.) | unique | .[] | "data/" + . + "/modules.yaml"' ${input}/modules.yaml)

for i in $(seq 0 $ct); do
    export YQ_MODULE_IDX=$i
    echo -n "id: $i; "
    name=$(yq -r 'sort_by(.name) | .[env.YQ_MODULE_IDX | tonumber].name' ${input}/modules.yaml)
    echo ${name}

    ./scripts/createMDFromYaml.yq ${input}/modules.yaml ${linkmodules} tmp.yaml > "${output}/modules/${name}.md"
done

# generate home.md
if [ -e ${input}/home.md.mustache ]; then
    rm -rf ${output}/home.md
    yq '[.[] | if .modification == null then null else . end] | sort_by(.page)' ${input}/modules.yaml \
        | mustache - ${input}/home.md.mustache > ${output}/home.md
fi

# generate spo.md
if [ -e ${input}/spo.md.mustache ]; then
    rm -rf ${output}/spo.md
    yq 'def merge(a; b):
      a as $a | b as $b |
        if ($a|type) == "object" and ($b|type) == "object" then
            reduce ([$a,$b]|add|keys_unsorted[]) as $k (
                {};
                .[$k] = merge( $a[$k]; $b[$k])
            )
        elif ($a|type) == "array" and ($b|type) == "array" then
            $a + $b
        elif
            $b == null then $a
        else
            $b
        end
    ;
    def mergeAll:
        . | reduce .[] as $item (
            {};
            merge(.; $item)
        )
    ;
    { tags: [.[] | . as $e | .tags[] | {(.): [$e]}] | mergeAll | with_entries(.value = (.value | sort_by(.page))) | with_entries(.key = (.key | gsub(" ";"_"))),
      name: [.[] | . as $e | {(.name | gsub(" ";"_")): $e}] | mergeAll
    }' ${input}/modules.yaml \
        | mustache - ${input}/spo.md.mustache > ${output}/spo.md
fi
