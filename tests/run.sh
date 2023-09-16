#/bin/bash

BASEDIR=$(dirname $0)
FLG=0

# Toggle comment
echo "Test toggle comment: start"
if ${BASEDIR}/toggle_comments/run_test.sh; then
	echo "Test toggle comment: PASS"
else
	echo "Test toggle comment: FAIL"
	FLG=1
fi

# Trim trailing spaces
echo "*********"
echo "Test trim trailing spaces: start"
if ${BASEDIR}/trim_trailing_spaces/run_test.sh; then
	echo "Test trim trailing spaces: PASS"
else
	echo "Test  trim trailing spaces: FAIL"
	FLG=1
fi

echo "*********"
if [ $FLG -eq 0 ]; then
	echo "All tests pass"
else
	echo "Some tests fail"
fi
