#!/usr/bin/env zsh

# Sets modules to '.differentiated = false` for all Modules with 'exam == "Kein"' or 'exam == "Keine"'
#
for f in data/**/modules.yaml; do
echo $f;
yq -i -Y '. | [.[] | if type == "object" and has("exam") and (.exam | test("Keine?\n?")) then .differentiated = false else . end]' $f;
perl -i -p -e 's/^  content: \|2/  content: \|/' $f;
done
