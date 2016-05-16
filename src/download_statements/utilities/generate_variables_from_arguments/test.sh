#! /bin/sh

SCRIPT_NAME=`basename "$0"`

USAGE_MESSAGE=$(cat <<EOF

	Usage: $SCRIPT_NAME [-h] <command> <end_date_generator> <start_date_generator> <files_base_name>

	If -h option is provided, displays this help message.

	Otherwise, runs <command> on a series of test cases, to assert whether it does a correct job
	at parsing command line arguments intended for a download_statement command, and outputing 
	the relevant variables. 

	<end_date_generator> is used to calculate the expected end date when no end date is provided as 
	parameter to <command>. Similarly, <start_date_generator> is used to calculate the expected start 
	date when none is provided as parameter to <command>.


	Returns true if all tests passed successfully, false otherwise.


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


# Read arguments

if [ $# -lt 4 ]; then
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

COMMAND="$1"
END_DATE_GENERATOR="$2"
START_DATE_GENERATOR="$3"
FILES_BASE_NAME="$4"

echo "Running tests on \"$COMMAND\", with end date generator \"$END_DATE_GENERATOR\", start date generator \"$START_DATE_GENERATOR\" \
and files base name \"$FILES_BASE_NAME\""


# Set up

TOTAL_TEST_COUNT=0
SUCCESSFUL_TEST_COUNT=0
FAILED_TEST_COUNT=0


# Test wrong calls of secondary script

WRONG_CALL_DATA=$(cat <<EOF

14 $END_DATE_GENERATOR $START_DATE_GENERATOR
0 $END_DATE_GENERATOR $START_DATE_GENERATOR $FILES_BASE_NAME
32 $END_DATE_GENERATOR $START_DATE_GENERATOR $FILES_BASE_NAME
chocolate $END_DATE_GENERATOR $START_DATE_GENERATOR $FILES_BASE_NAME
EOF
)

while read arguments; do
	printf "."
	TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))

	OUTPUT=$("$COMMAND" $arguments)
	EXIT_CODE="$?"

	TRIMMED_OUTPUT=$(echo $OUTPUT)
	USAGE_REGEX='^[ 	]*Usage: .*'
	if [ "$EXIT_CODE" = 1 ] && [[ "$TRIMMED_OUTPUT" =~ $USAGE_REGEX ]]; then
		SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))
	else
		FAILED_TEST_COUNT=$(( FAILED_TEST_COUNT + 1 ))
		echo
		echo "Test failed for input : $arguments"
		echo "Expected exit code 1, actual exit code was $EXIT_CODE"  | sed 's/^/    /'
		echo "Expected output as usage message, actual output was : "  | sed 's/^/    /'
		echo "$OUTPUT"  | sed 's/^/         /'
		echo
	fi

done <<< "$WRONG_CALL_DATA"

# Test wrong calls of main script

WRONG_ARGUMENTS_DATA=$(cat <<EOF
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" -x
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" -d
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" -f
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" -f -c 15
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" -c 0
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" -c 32
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" -c chocolate
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" -c 14/02/2013
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" -c 2013-02-14
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" chocolate
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" 42
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" 14/02/2013
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" 14-02-2013
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" 2013/02/14
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" 13/02/14
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" 14/02/13
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" 2013-02-14 chocolate
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" 2013-02-14 42
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" 2013-02-14 14/02/2013
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" 2013-02-14 14-02-2013
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" 2013-02-14 2013/02/14
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" 2013-02-14 13/02/14
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME" 2013-02-14 14/02/13
10 $END_DATE_GENERATOR $START_DATE_GENERATOR "$FILES_BASE_NAME"  2013-02-14 2013-02-13
EOF
)

while read arguments; do
	printf "."
	TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))

	OUTPUT=$("$COMMAND" $arguments 2>&1)
	EXIT_CODE="$?"

	IFS=$'\n' read -d '' -ra OUTPUT_ARRAY <<< "$OUTPUT"
	OUTPUT_LENGTH=${#OUTPUT_ARRAY[@]}
	TRIMMED_OUTPUT=$(echo $OUTPUT)
	ERROR_REGEX='^Error: .*'

	if [ "$EXIT_CODE" = 1 ] && \
		[[ "$TRIMMED_OUTPUT" =~ $ERROR_REGEX ]] && \
		[ "$OUTPUT_LENGTH" = 1 ]; then
		SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))
	else
		FAILED_TEST_COUNT=$(( FAILED_TEST_COUNT + 1 ))
		echo
		echo "Test failed for input : $arguments"
		echo "Expected exit code 1, actual exit code was $EXIT_CODE"  | sed 's/^/    /'
		echo "Expected output as error message, actual output was : "  | sed 's/^/    /'
		echo "$OUTPUT"  | sed 's/^/         /'
		echo
	fi

done <<< "$WRONG_ARGUMENTS_DATA"


# Test successful cases

DEFAULT_CUT_OFF_DATE=14

DEFAULT_END_DATE=$($END_DATE_GENERATOR $DEFAULT_CUT_OFF_DATE)
DEFAULT_START_DATE=$($START_DATE_GENERATOR "$DEFAULT_END_DATE")

EXAMPLE_CUT_OFF_DATE=10

EXAMPLE_END_DATE=$($END_DATE_GENERATOR $EXAMPLE_CUT_OFF_DATE)
EXAMPLE_START_DATE=$($START_DATE_GENERATOR "$EXAMPLE_END_DATE")

SPECIFIED_END_DATE="2014-03-12"
COMPUTED_SPECIFIED_START_DATE=$($START_DATE_GENERATOR "$SPECIFIED_END_DATE")

SPECIFIED_START_DATE="2014-02-27"

DATA=$(cat <<EOF

$PWD
$FILES_BASE_NAME$DEFAULT_START_DATE to $DEFAULT_END_DATE
$DEFAULT_START_DATE
$DEFAULT_END_DATE
   -d dir
dir
$FILES_BASE_NAME$DEFAULT_START_DATE to $DEFAULT_END_DATE
$DEFAULT_START_DATE
$DEFAULT_END_DATE
   -d dir/
dir
$FILES_BASE_NAME$DEFAULT_START_DATE to $DEFAULT_END_DATE
$DEFAULT_START_DATE
$DEFAULT_END_DATE
   -d /path/to/dir
/path/to/dir
$FILES_BASE_NAME$DEFAULT_START_DATE to $DEFAULT_END_DATE
$DEFAULT_START_DATE
$DEFAULT_END_DATE
   -d /path/to/dir/
/path/to/dir
$FILES_BASE_NAME$DEFAULT_START_DATE to $DEFAULT_END_DATE
$DEFAULT_START_DATE
$DEFAULT_END_DATE
   -d path/to/dir
path/to/dir
$FILES_BASE_NAME$DEFAULT_START_DATE to $DEFAULT_END_DATE
$DEFAULT_START_DATE
$DEFAULT_END_DATE
   -d path/to/dir/
path/to/dir
$FILES_BASE_NAME$DEFAULT_START_DATE to $DEFAULT_END_DATE
$DEFAULT_START_DATE
$DEFAULT_END_DATE
   -f awesomefile
$PWD
awesomefile
$DEFAULT_START_DATE
$DEFAULT_END_DATE
   -c $EXAMPLE_CUT_OFF_DATE
$PWD
$FILES_BASE_NAME$EXAMPLE_START_DATE to $EXAMPLE_END_DATE
$EXAMPLE_START_DATE
$EXAMPLE_END_DATE
   -d dir -f awesomefile
dir
awesomefile
$DEFAULT_START_DATE
$DEFAULT_END_DATE
   -d dir -c $EXAMPLE_CUT_OFF_DATE
dir
$FILES_BASE_NAME$EXAMPLE_START_DATE to $EXAMPLE_END_DATE
$EXAMPLE_START_DATE
$EXAMPLE_END_DATE
   -f awesomefile -c $EXAMPLE_CUT_OFF_DATE
$PWD
awesomefile
$EXAMPLE_START_DATE
$EXAMPLE_END_DATE
   -d dir -f awesomefile -c $EXAMPLE_CUT_OFF_DATE
dir
awesomefile
$EXAMPLE_START_DATE
$EXAMPLE_END_DATE
   $SPECIFIED_END_DATE
$PWD
$FILES_BASE_NAME$COMPUTED_SPECIFIED_START_DATE to $SPECIFIED_END_DATE
$COMPUTED_SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   -d dir $SPECIFIED_END_DATE
dir
$FILES_BASE_NAME$COMPUTED_SPECIFIED_START_DATE to $SPECIFIED_END_DATE
$COMPUTED_SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   -f awesomefile $SPECIFIED_END_DATE
$PWD
awesomefile
$COMPUTED_SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   -c 11 $SPECIFIED_END_DATE
$PWD
$FILES_BASE_NAME$COMPUTED_SPECIFIED_START_DATE to $SPECIFIED_END_DATE
$COMPUTED_SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   -d dir -f awesomefile $SPECIFIED_END_DATE
dir
awesomefile
$COMPUTED_SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   -d dir -c 11 $SPECIFIED_END_DATE
dir
$FILES_BASE_NAME$COMPUTED_SPECIFIED_START_DATE to $SPECIFIED_END_DATE
$COMPUTED_SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   -f awesomefile -c 11 $SPECIFIED_END_DATE
$PWD
awesomefile
$COMPUTED_SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   -d dir -f awesomefile -c 11 $SPECIFIED_END_DATE
dir
awesomefile
$COMPUTED_SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   $SPECIFIED_START_DATE $SPECIFIED_END_DATE
$PWD
$FILES_BASE_NAME$SPECIFIED_START_DATE to $SPECIFIED_END_DATE
$SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   -d dir $SPECIFIED_START_DATE $SPECIFIED_END_DATE
dir
$FILES_BASE_NAME$SPECIFIED_START_DATE to $SPECIFIED_END_DATE
$SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   -f awesomefile $SPECIFIED_START_DATE $SPECIFIED_END_DATE
$PWD
awesomefile
$SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   -c 11 $SPECIFIED_START_DATE $SPECIFIED_END_DATE
$PWD
$FILES_BASE_NAME$SPECIFIED_START_DATE to $SPECIFIED_END_DATE
$SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   -d dir -f filename $SPECIFIED_START_DATE $SPECIFIED_END_DATE
dir
filename
$SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   -d dir -c 11 $SPECIFIED_START_DATE $SPECIFIED_END_DATE
dir
$FILES_BASE_NAME$SPECIFIED_START_DATE to $SPECIFIED_END_DATE
$SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   -f awesomefile -c 11 $SPECIFIED_START_DATE $SPECIFIED_END_DATE
$PWD
awesomefile
$SPECIFIED_START_DATE
$SPECIFIED_END_DATE
   -d dir -f awesomefile -c 11 $SPECIFIED_START_DATE $SPECIFIED_END_DATE
dir
awesomefile
$SPECIFIED_START_DATE
$SPECIFIED_END_DATE
EOF
)


while read input; do

	read expected_directory
	read expected_basename
	read expected_start_date
	read expected_end_date

	printf "."
	TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))

	ACTUAL_RESULT=$("$COMMAND" "$DEFAULT_CUT_OFF_DATE" "$END_DATE_GENERATOR" "$START_DATE_GENERATOR" "$FILES_BASE_NAME" $input)
	ACTUAL_EXIT_CODE="$?"

	IFS=$'\n' read -d '' -r -a ACTUAL_VARIABLES <<< "$ACTUAL_RESULT"

	actual_directory=${ACTUAL_VARIABLES[0]}
	actual_basename=${ACTUAL_VARIABLES[1]}
	actual_start_date=${ACTUAL_VARIABLES[2]}
	actual_end_date=${ACTUAL_VARIABLES[3]}

	if [ "$actual_directory" = "$expected_directory" ] && \
		[ "$actual_basename" = "$expected_basename" ] && \
		[ "$actual_start_date" = "$expected_start_date" ] && \
		[ "$actual_end_date" = "$expected_end_date" ] && \
		[ "$ACTUAL_EXIT_CODE" = 0 ]; then

		SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))
	else
		FAILED_TEST_COUNT=$(( FAILED_TEST_COUNT + 1 ))
		echo
		echo "Test failed for input : $input"
		echo "Expected output was : "  | sed 's/^/    /'
		echo "$expected_directory\n$expected_basename\n$expected_start_date\n$expected_end_date"  | sed 's/^/       /'
		echo "with exit code \"0\""  | sed 's/^/    /'
		echo "Instead, output was :"  | sed 's/^/    /'
		echo "$ACTUAL_RESULT"  | sed 's/^/       /'
		echo "with exit code \"$ACTUAL_EXIT_CODE\""  | sed 's/^/    /'
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