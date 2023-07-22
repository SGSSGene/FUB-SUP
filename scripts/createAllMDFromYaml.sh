#!/usr/bin/env bash


input="${1}"
output="${2}"

ct=$(yq "(. | length) - 1" $input)

for i in $(seq 0 $ct); do
    export YQ_MODULE_IDX=$i
    echo -n "id: $i; "
    name=$(yq -r '.[env.YQ_MODULE_IDX | tonumber].name' ${input})
    echo ${name}
    ./scripts/createMDFromYaml.yq ${input} > "${output}/${name}.md"
done
