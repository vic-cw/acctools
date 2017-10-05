#! /bin/bash

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h]

        Run all tests in subdirectories, by calling scripts
        in subdirectories which are in turn responsible for
        running all tests in their own subdirectories.

Exit code:
        0   if all tests exit with code 0
        1   if at least one test exits with another code

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


# Run tests

_DIR_=$(dirname "${BASH_SOURCE[0]}")

echo
echo "Running tests from format_bank_statement\n"

"$_DIR_/format_bank_statement/run_all_tests.sh"
FORMAT_TESTS_EXIT_CODE="$?"

echo
echo "Running tests from download_bank_statement\n"
"$_DIR_/download_statements/run_all_tests.sh"
DOWNLOAD_TESTS_EXIT_CODE="$?"


# Announce results

green='\033[1;32m'
red='\033[0;31m'
end_color='\033[0m'

if [ "$FORMAT_TESTS_EXIT_CODE" = 0 ] && [ "$DOWNLOAD_TESTS_EXIT_CODE" = 0 ]; then
	printf $green
	echo "*****************************************************"
	echo "All tests passed successfully"
	echo "*****************************************************" $end_color
	exit 0
else
	printf $red
	echo "*****************************************************"
	echo "Some tests failed"
	echo "*****************************************************" $end_color
	exit 1
fi
