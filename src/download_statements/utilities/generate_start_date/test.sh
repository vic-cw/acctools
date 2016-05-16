#! /bin/sh

SCRIPT_NAME=`basename "$0"`

USAGE_MESSAGE=$(cat <<EOF

	Usage: $SCRIPT_NAME [-h] <command>

	If -h option is provided, displays this help message.

	Otherwise, runs <command> on a series of tests to assert whether it does a correct job at computing
	and outputing a start date from a given end date.

	Start date is assumed to be computed as the day following the day with the same day number one month before,
	except in case end date is the last day of the month, in which case start date is computed as the first day of the month.

	Examples :
		2015-03-14 => 2015-02-15
		2015-03-31 => 2015-03-01
		2015-03-30 => 2015-03-01
		2015-03-27 => 2015-02-28

EOF
)

shopt -s xpg_echo

# Read options

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

echo "Running tests on \"$COMMAND\""


# Define expected data

DATA=$(cat <<"EOF"
2015-03-14 0 2015-02-15
2015-03-31 0 2015-03-01
2015-03-30 0 2015-03-01
2015-03-27 0 2015-02-28
2015-03-01 0 2015-02-02
2015-01-30 0 2014-12-31
2015-01-03 0 2014-12-04
2015-04-30 0 2015-04-01
chocolate 1 
20140123 1 
2014/01/23 1 
2014-13-23 1 
2014-0-23 1 
2014-123-45 1 
2014-12-32 1 
20145-01-23 1 
2014-12-1000 1 
2014-12-1001 1 
EOF
)


# Run tests

TOTAL_TEST_COUNT=0
SUCCESSFUL_TEST_COUNT=0
FAILED_TEST_COUNT=0


while read end_date expected_exit_code expected_start_date; do
	printf "."
	TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))

	actual_start_date=$($COMMAND "$end_date" 2>/dev/null)
	exit_code="$?"
	if [ "$expected_exit_code" = "$exit_code" ] && [ "$expected_start_date" = "$actual_start_date" ]; then
		SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))
	else
		FAILED_TEST_COUNT=$(( FAILED_TEST_COUNT + 1 ))
		echo
		echo "Test failed for end date \"$end_date\". Expected result was \"$expected_start_date\"" \
			"and actual result was \"$actual_start_date\"." \
			"Expected exit code was $expected_exit_code and actual exit code was $exit_code."
		echo
	fi
done <<< "$DATA"


# Display results

green='\033[1;32m'
red='\033[0;31m'
end_color='\033[0m'

echo
if [ $TOTAL_TEST_COUNT -eq $SUCCESSFUL_TEST_COUNT ]; then
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