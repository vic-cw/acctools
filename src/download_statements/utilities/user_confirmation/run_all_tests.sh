#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

	Usage: $SCRIPT_NAME [-h]

	If -h option is provided, displays this help message.

	Otherwise, runs all tests from user_confirmation, if registered in this script.

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

"$_DIR_/is_cancel_answer/test.sh" "$_DIR_/is_cancel_answer/is_cancel_answer.sh" || \
	 ALL_GOOD=false
echo
"$_DIR_/is_overwrite_answer/test.sh" \
     "$_DIR_/is_overwrite_answer/is_overwrite_answer.sh" || \
     ALL_GOOD=false
echo
"$_DIR_/is_valid_confirmation/test.sh" \
	 "$_DIR_/is_valid_confirmation/is_valid_confirmation.sh" || \
	 ALL_GOOD=false


# Announce results

green='\033[1;32m'
red='\033[0;31m'
end_color='\033[0m'

if $ALL_GOOD; then
	echo $green
	echo "All user_confirmation tests passed successfully\n" $end_color
	exit 0
else
	echo $red
	echo "Some user_confirmation tests failed\n" $end_color
	exit 1
fi