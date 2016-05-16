#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

	Usage: $SCRIPT_NAME [-h]

	If -h option is provided, displays this help message.

	Otherwise, runs all tests from format_bank_statement and its utilities, if registered in this script or in a subscript that
	runs all tests from a subdirectory.

	Exits with code 0 if all tests returned 0, 1 otherwise.

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

"$_DIR_/characterization_test/test.sh" "$_DIR_/../format_bank_statement.sh" || \
		ALL_GOOD=false

# Announce results

green='\033[1;32m'
red='\033[0;31m'
end_color='\033[0m'

if $ALL_GOOD; then
	printf $green
	echo "----------------------------------------------------"
	echo "All format_bank_statements tests passed successfully"
	echo "----------------------------------------------------" $end_color
	exit 0
else
	printf $red
	echo "----------------------------------------"
	echo "Some format_bank_statements tests failed"
	echo "----------------------------------------" $end_color
	exit 1
fi