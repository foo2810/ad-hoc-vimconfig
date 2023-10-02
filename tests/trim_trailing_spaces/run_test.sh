#/bin/bash

# Copyright (c) 2023 hogedamari
# Released under the MIT license
# License notice:
# https:#github.com/foo2810/ad-hoc-vimconfig/blob/main/LICENSE

BASEDIR="$(dirname $0)"
PREV_POS="$(pwd)"

cd "$BASEDIR"
OPTS=
if vim -h | grep -e "--not-a-term" > /dev/null; then
	OPTS="--not-a-term"
fi
vim $OPTS -fn -S test.vim sample_codes/text_sample.txt > /dev/null
test_status=$?
cd "${PREV_POS}"

exit $test_status

