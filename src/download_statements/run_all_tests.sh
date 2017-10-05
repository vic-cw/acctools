#! /bin/bash

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage: $SCRIPT_NAME [-h]

       Run all tests from download_bank_statement and its utilities, that are registered
       either in this script or in a subscript that runs all tests from a subdirectory.

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


# Set up

ALL_GOOD=true

_DIR_=$(dirname "${BASH_SOURCE[0]}")
UTILITIES_FOLDER="$_DIR_/utilities"


# Run tests

"$UTILITIES_FOLDER/generate_end_date_from_date/test.sh" \
     "$UTILITIES_FOLDER/generate_end_date_from_date/generate_end_date_from_date.sh" || \
     ALL_GOOD=false
echo
"$UTILITIES_FOLDER/generate_start_date/test.sh" \
     "$UTILITIES_FOLDER/generate_start_date/generate_start_date.sh" || \
     ALL_GOOD=false
echo
"$UTILITIES_FOLDER/generate_variables_from_arguments/test.sh" \
     "$UTILITIES_FOLDER/generate_variables_from_arguments/generate_variables_from_arguments.sh" \
     "$UTILITIES_FOLDER/generate_end_date_from_today/generate_end_date_from_today.sh" \
     "$UTILITIES_FOLDER/generate_start_date/generate_start_date.sh" \
     "ABA bank statement - test - " || \
     ALL_GOOD=false
echo
"$UTILITIES_FOLDER/user_confirmation/run_all_tests.sh" || \
	   ALL_GOOD=false
echo
"$UTILITIES_FOLDER/date_utilities/run_all_tests.sh" || \
     ALL_GOOD=false
echo
mocha "$UTILITIES_FOLDER/js/tests" || \
     ALL_GOOD=false


# Announce results

green='\033[1;32m'
red='\033[0;31m'
end_color='\033[0m'

if $ALL_GOOD; then
	printf $green
	echo "------------------------------------------------------"
	echo "All download_bank_statements tests passed successfully"
	echo "------------------------------------------------------" $end_color
	exit 0
else
	printf $red
	echo "-------------------------------------------"
	echo "Some download_bank_statements tests failed."
	echo "-------------------------------------------" $end_color
	exit 1
fi
