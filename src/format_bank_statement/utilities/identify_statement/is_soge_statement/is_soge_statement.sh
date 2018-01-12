#! /bin/bash

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <input_file>

        Tests whether <input_file> seems to be a csv statement from
        Société Générale.

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


# Check first 3 lines

DATE_REGEX="[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]"
AMOUNT_REGEX="([0-9]|[0-9][0-9]|[0-9][0-9][0-9])(\.[0-9][0-9][0-9])*(,[0-9][0-9])?"

NORMAL_FIRST_LINE="=\"[0-9]{16}\";$DATE_REGEX;$DATE_REGEX;$AMOUNT_REGEX;$DATE_REGEX;$AMOUNT_REGEX EUR"
THIRD_LINE_FORMAT="Date de l'opération;Libellé;Détail de l'écriture;Montant de l'opération;Devise"
THIRD_LINE_FORMAT="${THIRD_LINE_FORMAT//[^[:ascii:]]/}"

{
	read first_line
	read second_line
	read third_line
} < "$FILE"

second_line=$(echo $second_line | tr -d " \t\n\r")
third_line="${third_line//[^[:ascii:]]/}"
third_line=$(echo "$third_line" | tr -d '\r')


if  ! [[ "$first_line" =~ $NORMAL_FIRST_LINE ]] || \
	! [ -z "$second_line" ] || \
	! [ "$third_line" == "$THIRD_LINE_FORMAT" ]; then
	exit 1
fi

exit 0