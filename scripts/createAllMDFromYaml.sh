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
#    link=$(yq -r 'sort_by(.name) | .[env.YQ_MODULE_IDX | tonumber].link' ${input}/modules.yaml)
    echo ${name}

#    if [ "${link}" == "null" ]; then
        ./scripts/createMDFromYaml.yq ${input}/modules.yaml ${linkmodules} tmp.yaml > "${output}/modules/${name}.md"
#    else
#        echo "  -> ${link}/${name}"
#        nidx=$(yq -y 'sort_by(.name) | [.[].name]' data/${link}/modules.yaml | grep -n "^- ${name}$" | cut -d ':' -f 1)
#        export YQ_MODULE_IDX=$nidx
#        ./scripts/createMDFromYaml.yq data/${link}/modules.yaml > "${output}/modules/${name}.md"
#    fi
done
