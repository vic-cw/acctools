#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <command>

        Run <command> on a series of dates, to assess
        whether it does a good job at validating or 
        rejecting dates.

Exit code:
        0   if all tests passed successfully
        1   otherwise

Options:
        -h  Display this help message


Project home page : https://github.com/vic-cw/acctools
_
EOF
)

shopt -s xpg_echo

# Check for call of help

while getopts "h" opt; do
	case "$opt" in
		h)
			echo "$USAGE_MESSAGE" >&2
			exit 0
			;;
		\?)
			echo "$USAGE_MESSAGE" >&2
			exit 1
			;;
	esac
done


# Read argument

if [ $# -lt 1 ]; then
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

COMMAND="$1"

echo "Running tests on '$COMMAND'"

# Set up tests

TOTAL_TEST_COUNT=0
SUCCESSFUL_TEST_COUNT=0
FAILED_TEST_COUNT=0

REJECT_DATA=$(cat <<EOF

cow
yesterday
8374998505
1 January 2000
1st January 2000
January 1st 2000
Jan 1st 2000
1 Jan 2000
01/01/2000
01-01-2000
01 01 2000
2000 01 01
2000/01/01
01/01/00
01-01-00
01 01 00
00 01 01
00/01/01
2000-23-03
2000-03-32
2000-03-1
2000-13-01
2000-13-0100
2000-13-1000
2000-13-1234
EOF
)

VALID_DATA=$(cat <<EOF
2000-01-01
1975-12-25
2037-08-27
EOF
)

# Non-specified behavior, because depending on the platform :
# 2000-02-30
# 2000-04-00

# Run tests

while read DATE; do
	printf "."
	TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))

	"$COMMAND" "$DATE" >/dev/null 2>&1
	RESULT="$?"

	if [ "$RESULT" = 1 ]; then
		SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))
	else
		FAILED_TEST_COUNT=$(( FAILED_TEST_COUNT + 1 ))
		echo "\nTest failed for input '$DATE'. Expected result was a rejection, but was declared valid\n"
	fi

done <<<"$REJECT_DATA"

while read DATE; do
	printf "."
	TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))

	"$COMMAND" "$DATE" >/dev/null 2>&1
	RESULT="$?"

	if [ "$RESULT" = 0 ]; then
		SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))
	else
		FAILED_TEST_COUNT=$(( FAILED_TEST_COUNT + 1 ))
		echo "\nTest failed for date '$DATE'. Expected result was to declare valid, but exit code was '$RESULT'\n"
	fi

done <<<"$VALID_DATA"


# Announce results

green='\033[1;32m'
red='\033[0;31m'
end_color='\033[0m'

echo

if [ $TOTAL_TEST_COUNT = $SUCCESSFUL_TEST_COUNT ]; then
	printf $green
	echo "All $TOTAL_TEST_COUNT tests passed successfully" $end_color
	exit 0
else
	printf $red
	echo "FAILURE" $end_color
	echo
	echo "$SUCCESSFUL_TEST_COUNT tests passed successfully, $FAILED_TEST_COUNT tests failed"
	echo
	exit 1
fi