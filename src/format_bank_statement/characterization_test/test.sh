#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

	Usage: $SCRIPT_NAME [-h] <command>

	If -h option is provided, displays this help message.

	Otherwise, runs <command> on a series of input files, and compares output to the corresponding expected file.
	Adds the \"-e\" option on <command>, to make it echo its output instead of saving it.
	Checks whether output matches exactly the file with the same name as the input file, in the "expected" folder.

	Exits with code 0 if all outputs were similar to expected files, 1 otherwise.

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

SCRIPT="$1"

echo "Running tests on $SCRIPT : \n"


# Setup for tests

TOTAL_TEST_COUNT=0
SUCCESSFUL_TEST_COUNT=0
FAILED_TEST_COUNT=0

_DIR_=$(dirname "${BASH_SOURCE[0]}")
INPUT_DIRECTORY="$_DIR_/input"
EXPECTED_DIRECTORY="$_DIR_/expected"

green='\033[1;32m'
red='\033[0;31m'
end_color='\033[0m'


# Run tests

FILES=$(ls -1 "$INPUT_DIRECTORY")
while read file; do
	TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))

	ACTUAL=$($SCRIPT -e "$INPUT_DIRECTORY/$file")
	EXPECTED=$(cat "$EXPECTED_DIRECTORY/$file")

	if [ "$ACTUAL" = "$EXPECTED" ]; then
		SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))
		printf $green
		echo "Success : " $end_color "$file"
	else
		FAILED_TEST_COUNT=$(( FAILED_TEST_COUNT + 1 ))
		printf $red
		echo "Failure for $file :\n"
		echo "Actual : $end_color\n"
		echo "$ACTUAL\n" | sed 's/^/      /'
		echo "${green}Expected : $end_color\n"
		echo "$EXPECTED\n" | sed 's/^/      /'
	fi
done <<< "$FILES"


# Display results

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