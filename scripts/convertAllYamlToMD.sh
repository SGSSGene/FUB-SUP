#!/usr/bin/env bash

sop=$1 # example inf_bsc_2023

mkdir -p docs/${sop}_modules
for i in  modules/${sop}/*.yaml; do
    stemname=$(basename "$i" | rev | cut -b 6- | rev)
    ./scripts/createMDFromYaml.sh "modules/${sop}/${stemname}.yaml" > "docs/${sop}_modules/${stemname}.md"

done
