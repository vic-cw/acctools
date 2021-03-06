#! /bin/bash

SCRIPT_NAME=`basename "$0"`

USAGE_MESSAGE=$(cat <<EOF

	Usage: $SCRIPT_NAME [-h] <command>

	If -h option is provided, displays this help message.

	Otherwise, runs a series of tests on <command>, to assert whether it does a good job at checking whether its provided argument
	matches one of the following once trimmed from spaces and tabs : c, C, cancel, Cancel, CANCEL

	Exits with code 0 if all tests passed successfully, 1 otherwise

EOF
)

shopt -s xpg_echo

# Test for call of help

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

echo "Running tests on $COMMAND"

# Start tests

TOTAL_TEST_COUNT=0
SUCCESSFUL_TEST_COUNT=0
FAILED_TEST_COUNT=0

# Test with no argument provided

printf "."
TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))

OUTPUT=$("$COMMAND")
RESULT="$?"

if [ -z "$OUTPUT" ] && [ "$RESULT" = 1 ]; then
	SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))
else
	FAILED_TEST_COUNT=$(( FAILED_TEST_COUNT + 1 ))
	echo "\nTest failed for case of no argument provided. Expected no output, and exit code 1. "
	echo "Actual output was : "
	echo "$OUTPUT"
	echo "and actual exit code $RESULT"
fi

# Test other cases

DATA=$(cat <<EOF
c
0
C
0
cancel
0
Cancel
0
CANCEL
0
 c 
0
	c	
0
 C 
0
	C	
0
   cancel   
0
	cancel	
0
 Cancel 
0
	Cancel	
0
 CANCEL 
0
	CANCEL	
0
cancele
1
o
1
O
1
overwrite
1
Overwrite
1
OVERWRITE
1
 o 
1
	o	
1
 O 
1
	O	
1
  overwrite   
1
	overwrite	
1
 Overwrite 
1
	Overwrite	
1
 OVERWRITE 
1
	OVERWRITE	
1
ov
1
Ov
1
oc
1
ca
1
Ca
1
co
1
chocolate
1
y
1
yes
1
Y
1
YES
1
n
1
no
1
N
1
NO
1
EOF
)

IFS=''
while read user_answer; do
	read expected_result
	printf "."
	TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))

	OUTPUT=$("$COMMAND" "$user_answer")
	RESULT="$?"
	
	if [ -z "$OUTPUT" ] && [ "$RESULT" = "$expected_result" ]; then
		SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))
	else
		FAILED_TEST_COUNT=$(( FAILED_TEST_COUNT + 1 ))
		echo "\nTest failed for input \"$user_answer\". Expected empty output and exit code $expected_result."
		echo "Instead, exit code was $RESULT and output was : "
		echo "$OUTPUT"
	fi
done <<< "$DATA"
unset IFS

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
