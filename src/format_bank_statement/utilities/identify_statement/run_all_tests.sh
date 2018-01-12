#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage: $SCRIPT_NAME [-h]

       Run all tests from identify_statement folder, that are registered
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


# Run tests

"$_DIR_/is_aba_statement/test/test.sh" || \
		ALL_GOOD=false
"$_DIR_/is_soge_statement/test/test.sh" || \
		ALL_GOOD=false
"$_DIR_/is_csv_file/test/test.sh" || \
		ALL_GOOD=false
"$_DIR_/is_pdf_file/test/test.sh" || \
		ALL_GOOD=false
"$_DIR_/is_cic_csv_statement/test/test.sh" || \
		ALL_GOOD=false
"$_DIR_/is_cic_pdf_statement/test/test.sh" || \
		ALL_GOOD=false

# Announce results

green='\033[1;32m'
red='\033[0;31m'
end_color='\033[0m'

if $ALL_GOOD; then
	printf $green
	echo "--"
	echo "All identify_statement tests passed successfully"
	echo $end_color
	exit 0
else
	printf $red
	echo "--"
	echo "Some identify_statement tests failed" $end_color
	exit 1
fi