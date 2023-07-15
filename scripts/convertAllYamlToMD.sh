#!/usr/bin/env bash
for i in  modules/inf_bsc_2023/*.yaml; do
    stemname=$(basename "$i" | rev | cut -b 6- | rev)
    echo $stemname
    ./scripts/createMDFromYaml.sh "modules/inf_bsc_2023/${stemname}.yaml" > "docs/bsc_inf_2023_modules/${stemname}.md"
done
