#/bin/bash

SCRIPT_NAME=`basename "$0"`

USAGE_MESSAGE=$(cat <<EOF

	Usage: $SCRIPT_NAME [-h] <user_answer>

	If -h option is provided, displays this help message.

	Otherwise, looks at whether user_answer, once trimmed for trailing and leadings spaces and tabs, is one of the following :
	   - o, O, overwrite, Overwrite, OVERWRITE
	   - c, C, cancel, Cancel, CANCEL

   	Exits with code 0 if it is the case, 1 otherwise
EOF
)

shopt -s xpg_echo

# Test for call of help

while getopts "h" opt; do
	case "$opt" in
		h)
			echo "$USAGE_MESSAGE"
			exit 0
			;;
		\?)
			echo "$USAGE_MESSAGE"
			exit 1
			;;
	esac
done

# Read argument

if [ $# -lt 1 ]; then
	exit 1
fi

INPUT="$1"

_DIR_=$(dirname "${BASH_SOURCE[0]}")

if "$_DIR_/../is_overwrite_answer/is_overwrite_answer.sh" "$INPUT" || \
	"$_DIR_/../is_cancel_answer/is_cancel_answer.sh" "$INPUT"; then
	exit 0
else
	exit 1
fi
