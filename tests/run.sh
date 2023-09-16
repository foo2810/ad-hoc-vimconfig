#/bin/bash

BASEDIR=$(dirname $0)
FAIL=0

# Toggle comment
echo "Test toggle comment: start"
if ${BASEDIR}/toggle_comments/run_test.sh; then
	echo "Test toggle comment: PASS"
else
	echo "Test toggle comment: FAIL"
	FAIL=$((FAIL + 1))
fi

# Trim trailing spaces
echo "*********"
echo "Test trim trailing spaces: start"
if ${BASEDIR}/trim_trailing_spaces/run_test.sh; then
	echo "Test trim trailing spaces: PASS"
else
	echo "Test  trim trailing spaces: FAIL"
	FAIL=$((FAIL + 1))
fi

echo "*********"
if [ $FAIL -eq 0 ]; then
	echo "All tests pass"
	exit 0
else
	echo "Some tests fail"
	exit 1
fi
