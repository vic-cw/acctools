#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h]

        Read csv file from standard input, keep only
        list of transactions, remove everything else,
        and print result to standard output.

        Accept only csv files translated from Boursorama website.

Options:
        -h  Display this help message

Exit code:
        0   if everything goes well
        1   otherwise

EXAMPLE:
        $SCRIPT_NAME bank_statement.csv > trimmed_bank_statement.csv


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

DATE_REGEX="[0-3][0-9]/[0-1][0-9]/[0-9][0-9][0-9][0-9]"
AMOUNT_REGEX="([0-9]|[0-9][0-9]|[0-9][0-9][0-9])( [0-9][0-9][0-9])*,[0-9][0-9]"
NUMBER_REGEX="[0-9]+"
TRANSACTION_REGEX="$DATE_REGEX,$DATE_REGEX,.+,.+,.+,.+,\"-?$AMOUNT_REGEX\",$NUMBER_REGEX,.+,\"-?$AMOUNT_REGEX\""

while read line; do
	if [[ "$line" =~ $TRANSACTION_REGEX ]]; then
		echo "$line"
		while read line; do
			echo "$line"
		done
		break
	fi
done


exit 0