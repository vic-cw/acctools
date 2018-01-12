#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <input_file>

        Tests whether <input_file> seems to be a csv statement from
        Advanced Bank of Asia (ABA).

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



# Check that first line is either typical first line, or typical headers

ABA_NORMAL_FIRST_LINE="Account\ [0-9]{9,12}\ Posted\ Operations"
ABA_HEADERS="^Operation\ Date\ and\ Time\;Operation\ Amount\;Operation\ Description\;\
Amount\ in\ account\ currency\;Debit/Credit\ Date\;Remain\ amount"

{
	read first_line
	read second_line
} < "$FILE"


if  ! [[ "$first_line" =~ $ABA_HEADERS ]]; then
	if ! [[ "$first_line" =~ $ABA_NORMAL_FIRST_LINE ]] || ! [[ "$second_line" =~ $ABA_HEADERS ]]; then
		exit 1
	fi
fi

exit 0