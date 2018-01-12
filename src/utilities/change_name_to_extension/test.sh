#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <script_to_test>

        Run tests against <script_to_test> to determine whether it
        correctly changes a given file name to a given file extension.

Options:
        -h  Display this help message

Exit code:
        0   if all tests pass successfully
        1   otherwise

EXAMPLE:
        $SCRIPT_NAME change_name_to_extension.sh


Project home page : https://github.com/vic-cw/acctools
_
EOF
)

shopt -s xpg_echo

### Check for call of help

while getopts "h" opt; do
	case $opt in
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


### Read argument

if [ $# -lt 1 ]; then
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

SCRIPT="$1"


# Test cases :
# - invalid input
#     - wrong format extension
#     - empty filename
# - corner cases
#     - one character long extension
#     - extension same as existing one
# - normal cases
#     - file name without extension
#     - file name with existing extension

ALL_GOOD=true
TOTAL_TEST_COUNT=0
SUCCESSFUL_TEST_COUNT=0

## Invalid input : expect non zero exit code

# Test non ascii extension

if "$SCRIPT" filename été 2>/dev/null; then
	ALL_GOOD=false
	echo "Wrong answer of $SCRIPT when given an extension with non ASCII characters" >&2
else
	SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))
fi
TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))

# Test long extension

if "$SCRIPT" filename longext 2>/dev/null; then
	ALL_GOOD=false
	echo "Wrong answer of $SCRIPT when given an extension longer than 6 characters" >&2
else
	SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))	
fi
TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))

# Test empty file name

if "$SCRIPT" "" mp3 2>/dev/null; then
	ALL_GOOD=false
	echo "Wrong answer of $SCRIPT when given an empty file name" >&2
else
	SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))	
fi
TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))


## Corner cases

# One character long extension

OUTPUT=$( "$SCRIPT" filename a 2>/dev/null)
RESULT="$?"

if [ "$OUTPUT" != "filename.a" ] || [ "$RESULT" != 0 ]; then
	ALL_GOOD=false
	echo "Wrong answer of $SCRIPT when given a one character long extension" >&2
else
	SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))	
fi
TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))


# Extension same as existing one

OUTPUT=$( "$SCRIPT" filename.csv csv 2>/dev/null)
RESULT="$?"

if [ "$OUTPUT" != filename.csv ] || [ "$RESULT" != 0 ]; then
	ALL_GOOD=false
	echo "Wrong answer of $SCRIPT when given an extension similar to initial file name" >&2
else
	SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))	
fi
TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))


## Normal cases

# File name without extension

OUTPUT=$( "$SCRIPT" filename pdf 2>/dev/null)
RESULT="$?"

if [ "$OUTPUT" != "filename.pdf" ] || [ "$RESULT" != 0 ]; then
	ALL_GOOD=false
	echo "Wrong answer of $SCRIPT when given a file name without extension" >&2
else
	SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))	
fi
TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))


# File name with extension

OUTPUT=$("$SCRIPT" filename.pdf csv 2>/dev/null)
RESULT="$?"

if [ "$OUTPUT" != "filename.csv" ] || [ "$RESULT" != 0 ]; then
	ALL_GOOD=false
	echo "Wrong answer of $SCRIPT when given a file name with an extension" >&2
else
	SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))	
fi
TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))


### Display results

FAILED_TEST_COUNT=$(( TOTAL_TEST_COUNT - SUCCESSFUL_TEST_COUNT ))
green='\033[1;32m'
red='\033[0;31m'
end_color='\033[0m'

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
