#! /bin/bash

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <input_file>

        Filter data in csv file <input_file> to keep only
        transaction list, remove everything else, and print
        result to standard output.

        Accepts only csv files generated by Société Générale.

        If <input_file> is not of the expected format, no output
        is generated.

Options:
        -h  Display this help message

Exit code:
        0   if everything goes well
        1   if file does not fit expected format

EXAMPLE:
        $SCRIPT_NAME downloaded_file.csv >trimmed_file.csv


Project home page : https://github.com/vic-cw/acctools
_
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


# Read argument

if [ $# -lt 1 ]; then
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

FILE="$1"


# Set up

START_CUT_OFF=false

START_LINE_REGEX="Date de l'opération;Libellé;Détail de l'écriture;Montant de l'opération;Devise"
START_LINE_REGEX="${START_LINE_REGEX//[^[:ascii:]]/}"


# Parse file

while read line || [ -n "$line" ]; do

	# Do not output until header line has been met

	if ! "$START_CUT_OFF" ; then
		normalized_line="${line//[^[:ascii:]]/}"
		if [[ "$normalized_line" =~ $START_LINE_REGEX ]]; then
			START_CUT_OFF=true
		fi

	# Output once header line has been met

	else
		echo "$line"
	fi
done <"$FILE"

if [ "$START_CUT_OFF" = false ]; then
	echo "Error: wrong file format of file '$FILE'" >&2
	exit 1
fi
