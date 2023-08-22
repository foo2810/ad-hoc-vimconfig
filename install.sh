#!/bin/bash

# Copyright (c) 2023 hogedamari
# Released under the MIT license
# License notice:
# https://github.com/foo2810/ad-hoc-vimconfig/blob/main/LICENSE


VIMRC_PATH=$(realpath ~/.vimrc)
VIMRC_URL="https://raw.githubusercontent.com/foo2810/ad-hoc-vimconfig/main/.vimrc"

select_yes_no() {
    local ans
    local yes_pattern
    local no_pattern

    yes_pattern="^yes$|^YES$|^Yes$|^y$|^Y$"
    no_pattern="^no$|^NO$|^No$|^n$|^N$"
    while true; do
        read ans
        if [[ $ans =~ $yes_pattern ]]; then
            return 0
        fi
        if [[ $ans =~ $no_pattern ]]; then
            return 1
        fi
        echo "Invalid answer. Please retry."
    done
}

if [ -f $VIMRC_PATH ]; then
    echo "$VIMRC_PATH already exists"
    echo "Are you sure to override ${VIMRC_PATH} ?"
    if ! select_yes_no; then
        exit 0
    fi
fi

curl -fsSo "$VIMRC_PATH" "$VIMRC_URL"

