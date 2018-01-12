#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <initial_name> <extension>

        Output file name made of initial name, with extension either added
        or changed to <extension>.

Options:
        -h  Display this help message

Exit code:
        0   if everything goes well
        1   otherwise

EXAMPLE:
        $SCRIPT_NAME statement.pdf csv


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


# Read argument

if [ $# -lt 2 ]; then
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

NAME="$1"
EXT="$2"

# Check arguments

EXTENSION_REGEX="^[a-zA-Z0-9]{1,6}$"

if ! [[ "$EXT" =~ $EXTENSION_REGEX ]]; then
	echo "Erro: Wrong extension provided to $SCRIPT_NAME : $EXT" >&2
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

if [ -z "$NAME" ]; then
	echo "Error: Empty file name provided to $SCRIPT_NAME" >&2
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

# Process

# TODO : detect system and use "-r" if on GNU

STRIPPED_NAME=$(echo "$NAME" | sed -E 's_(.+)\.[a-zA-Z0-9]{1,6}$_\1_' )

echo "$STRIPPED_NAME.$EXT"

exit 0