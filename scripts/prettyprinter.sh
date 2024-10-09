#!/usr/bin/env bash

set -Eeuo pipefail

yq -y -z -w 80 '[.[]
    | if .requirements != null and .requirements != "TODO" then .requirements |= ("__yq_style_|__" + .) end
    | if .goals != null and .goals != "TODO" then .goals |= ("__yq_style_|__" + .) end
    | if .content != null then .content |= ("__yq_style_|__" + .) end
    | if .exam != null and .exam != "TODO" then .exam |= ("__yq_style_|__" + .) end
    | if .duration and .duration != "TODO" then .duration |= ("__yq_style_.|\"__" + .) end
    | if .repeat and .repeat != "TODO" then .repeat |= ("__yq_style_.|\"__" + .) end
    | if .usability and .usability != "TODO" then .usability |= ("__yq_style_|__" + .) end
    | if .teachingunit != null then
        .teachingunit |= [.[]
            | .activity |= ("__yq_style_|__" + .)
        ]
    end
    | if .modification != null then
        .modification |= [.[]
            | . |= ("__yq_style_.|\"__" + .)
        ]
    end
    | if .tags != null then
        .tags |= [.[]
            | . |= ("__yq_style_.\"__" + .)
        ]
    end
]' $1 > $1.new
cat $1.new | perl -p -e 's/^  content: \|2$/  content: |/' > $1
rm $1.new

