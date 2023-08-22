#!/bin/bash

# Copyright (c) 2023 hogedamari
# Released under the MIT license
# License notice:
# https://github.com/foo2810/ad-hoc-vimconfig/blob/main/LICENSE


VIMRC_PATH=$(realpath ~/.vimrc)
VIMRC_URL="https://raw.githubusercontent.com/foo2810/ad-hoc-vimconfig/main/.vimrc"

if [ -f $VIMRC_PATH ]; then
    echo "$VIMRC_PATH already exists"
    if [ -z "$FORCE" ] || [ $FORCE -ne 1 ]; then
        cat << EOF
To override cofing, execute following command:
curl -fsSL https://raw.githubusercontent.com/foo2810/ad-hoc-vimconfig/main/install.sh | FORCE=1 bash

Abort
EOF
        exit 1
    fi
fi

curl -fsSo "$VIMRC_PATH" "$VIMRC_URL"

