#! /bin/bash

USAGE_MESSAGE=$(cat <<"EOF"

	Usage: test.sh [-h] <command>

	If -h option is provided, displays this help message.

	Otherwise, runs <command> on a series of tests, to assert whether it does a correct job
	at printing a calculated end date from a reference date.

	End date is supposed to be returned as the latest day strictly prior to a reference date,
	with a day number equal to a given integer.

	Returns true if all tests passed successfully, false otherwise.

EOF
)

shopt -s xpg_echo

# Read options

while getopts "h" opt; do
	case "$opt" in
		h)
			echo "$USAGE_MESSAGE"
			exit 0
			;;
		\?)
			echo "$USAGE_MESSAGE"
			exit 1
			;;
	esac
done

# Read argument

if [ $# -lt 1 ]; then
	echo "$USAGE_MESSAGE"
	exit 1
fi

COMMAND="$1"

echo "Running tests on \"$COMMAND\""


# Define expected data

DATA=$(cat <<"EOF"
2015-03-23 14 0 2015-03-14
2015-03-23 1 0 2015-03-01
2015-03-23 01 0 2015-03-01
2015-04-23 31 0 2015-03-31
2015-04-23 25 0 2015-03-25
2015-04-23 23 0 2015-03-23
2015-03-15 15 0 2015-02-15
2015-03-23 30 0 2015-02-28
2015-05-23 31 0 2015-04-30
2015-01-23 25 0 2014-12-25
2015-03-23 32 1 
2015-03-23 0 1 
2015-03-23 -10 1 
2015-03-23 100 1 
2015-03-23 ab 1 
2015-03-23 chocolate 1 
2015-03-23 32ab 1 
2015-03-23 12ab 1 
2015-13-23 14 1 
2015-12-32 14 1 
2015-13-23 0 1 
2015-12-32 -10 1 
2015-02-30 ab 1 
2015-06-1647 14 1
2015-06-1647 12ab 1 
EOF
)


# Run tests

TOTAL_TEST_COUNT=0
SUCCESSFUL_TEST_COUNT=0
FAILED_TEST_COUNT=0


while read date cut_off_date expected_exit_code expected_end_date; do
	printf "."
	TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))

	actual_end_date=$($COMMAND "$cut_off_date" "$date" 2>/dev/null)
	exit_code="$?"
	if [ "$expected_exit_code" = "$exit_code" ] && [ "$expected_end_date" = "$actual_end_date" ]; then
		SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))
	else
		FAILED_TEST_COUNT=$(( FAILED_TEST_COUNT + 1 ))
		echo
		echo "Test failed for date \"$date\" and cut-off date \"$cut_off_date\"." \
			"Expected result was \"$expected_end_date\" and actual result was \"$actual_end_date\"." \
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
