#!/usr/bin/env bash

path="${1}"
input="data/${path}"
output="docs/${path}"

mkdir -p ${output}/modules

ct=$(yq "(. | length) - 1" ${input}/modules.yaml)

for i in $(seq 0 $ct); do
    export YQ_MODULE_IDX=$i
    echo -n "id: $i; "
    name=$(yq -r '.[env.YQ_MODULE_IDX | tonumber].name' ${input}/modules.yaml)
    echo ${name}
    ./scripts/createMDFromYaml.yq ${input}/modules.yaml > "${output}/modules/${name}.md"
done
