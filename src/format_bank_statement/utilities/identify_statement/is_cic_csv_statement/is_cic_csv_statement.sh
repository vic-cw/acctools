#! /bin/bash

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <input_file>

        Tests whether <input_file> seems to be a csv statement from
        Crédit Industriel et Commercial (CIC).

Options:
        -h  Display this help message

Exit code:
        0   if answer is yes
        1   otherwise

EXAMPLE:
        if $SCRIPT_NAME downloaded_file.csv; then ...


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


# Check if file is csv

_DIR_=$(dirname "${BASH_SOURCE[0]}")

if ! "$_DIR_/../is_csv_file/is_csv_file.sh" "$FILE"; then
	exit 1
fi

# Check first line

FIRST_LINE_FORMAT="Date d'opération,Date de valeur,Montant,Libellé,Solde"
FIRST_LINE_FORMAT="${FIRST_LINE_FORMAT//[^[:ascii:]]/}"

FIRST_LINE=$(head -n 1 "$FILE")
FIRST_LINE="${FIRST_LINE//[^[:ascii:]]/}"
FIRST_LINE=$(echo "$FIRST_LINE" | tr -d '\r')

if [ "$FIRST_LINE" != "$FIRST_LINE_FORMAT" ]; then
	exit 1
fi

exit 0