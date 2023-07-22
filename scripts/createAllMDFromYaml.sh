#!/usr/bin/env bash


input="${1}"
output="${2}"

mkdir -p ${output}_modules
cp ${input}/sop.md ${output}_sop.md

ct=$(yq "(. | length) - 1" ${input}/modules.yaml)

for i in $(seq 0 $ct); do
    export YQ_MODULE_IDX=$i
    echo -n "id: $i; "
    name=$(yq -r '.[env.YQ_MODULE_IDX | tonumber].name' ${input}/modules.yaml)
    echo ${name}
    ./scripts/createMDFromYaml.yq ${input}/modules.yaml > "${output}_modules/${name}.md"
done
