#! /bin/sh

SCRIPT_NAME=`basename "$0"`

USAGE_MESSAGE=$(cat <<EOF

	Usage: $SCRIPT_NAME [-h] <user_answer>

	If -h option is provided, displays this help message.

	Otherwise, looks at whether user_answer, once trimmed for trailing and leadings spaces and tabs, is one of the following :
	   - o, O, overwrite, Overwrite, OVERWRITE

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

TRIMMED_INPUT=$(echo $INPUT)
case "$TRIMMED_INPUT" in 
	o)
		exit 0 ;;
	O)
		exit 0 ;;
	overwrite)
		exit 0 ;;
	Overwrite)
		exit 0 ;;
	OVERWRITE)
		exit 0 ;;
esac

exit 1