#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <script> <true_directory> <false_directory>

        Run <script> on all files inside <true_directory> and <false_directory>,
        check that exit code of <script> is 0 for all files in <true_directory>
        and non 0 for all files in <false_directory>.

Options:
        -h  Display this help message

Exit code:
        0   if exit code was correct each time
        1   otherwise

EXAMPLE:
        $SCRIPT_NAME ../is_aba_statement/is_aba_statement.sh \
        ../is_aba_statement/test/true \
        ../is_aba_statement/test/false


Project home page : https://github.com/vic-cw/acctools
_
EOF
)

shopt -s xpg_echo

# Check for call of help

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


# Read arguments

if [ $# -lt 3 ]; then
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

SCRIPT="$1"
TRUE_DIRECTORY="$2"
FALSE_DIRECTORY="$3"


# Set up

green='\033[1;32m'
red='\033[0;31m'
end_color='\033[0m'


# Conduct tests

TRUE_FILES=$(ls -1 "$TRUE_DIRECTORY" )
FALSE_FILES=$(ls -1 "$FALSE_DIRECTORY" )

TOTAL_TEST_COUNT=0
SUCCESSFUL_TEST_COUNT=0

while read file; do
	if [ -z "$file" ]; then
		continue
	fi
	TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))
	printf "."
	if "$SCRIPT" "$TRUE_DIRECTORY/$file"; then
		SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))
	else
		echo
		printf $red
		echo "Wrong answer of $SCRIPT for file $TRUE_DIRECTORY/$file"
		printf $end_color
	fi
done <<<"$TRUE_FILES"

while read file; do
	if [ -z "$file" ]; then
		continue
	fi
	TOTAL_TEST_COUNT=$(( TOTAL_TEST_COUNT + 1 ))
	printf "."
	if ! "$SCRIPT" "$FALSE_DIRECTORY/$file"; then
		SUCCESSFUL_TEST_COUNT=$(( SUCCESSFUL_TEST_COUNT + 1 ))
	else
		echo
		printf $red
		echo "Wrong answer of $SCRIPT for file $FALSE_DIRECTORY/$file"
		printf $end_color
	fi
done <<<"$FALSE_FILES"


# Display results

FAILED_TEST_COUNT=$(( TOTAL_TEST_COUNT - SUCCESSFUL_TEST_COUNT ))
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