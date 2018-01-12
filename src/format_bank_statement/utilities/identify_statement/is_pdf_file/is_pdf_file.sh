#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <input_file>

        Tests whether <input_file> is a PDF file, by looking
        at its extension, as well as its file type.

Options:
        -h  Display this help message

Exit code:
        0   if answer is yes
        1   otherwise

EXAMPLE:
        if $SCRIPT_NAME downloaded_file.pdf; then ...


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

if [ $# -lt 1 ]; then
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

FILE="$1"


# Check if file name finishes with .pdf

PDF_REGEX=".+\.pdf$"

if ! [[ "$FILE" =~ $PDF_REGEX ]]; then
	exit 1
fi


# Check that file is of PDF type

TYPE_REGEX=".+PDF document, version [0-9]+\.[0-9]+$"

if ! [[ $(file "$FILE") =~ $TYPE_REGEX ]]; then
	exit 1
fi

exit 0