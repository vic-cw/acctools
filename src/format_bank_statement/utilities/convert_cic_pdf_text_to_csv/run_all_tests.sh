#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage: $SCRIPT_NAME [-h]

       Run all tests from convert_cic_pdf_text_to_csv folder, 
       that are registered either in this script or in a subscript that runs
       all tests from a subdirectory.

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

"$_DIR_/characterization_test/test.sh" "$_DIR_/convert_cic_pdf_text_to_csv.sh" || \
		ALL_GOOD=false

# Announce results

green='\033[1;32m'
red='\033[0;31m'
end_color='\033[0m'

if $ALL_GOOD; then
	printf $green
	echo "--"
	echo "All convert_cic_pdf_text_to_csv tests passed successfully"
	echo $end_color
	exit 0
else
	printf $red
	echo "--"
	echo "Some convert_cic_pdf_text_to_csv tests failed" $end_color
	exit 1
fi