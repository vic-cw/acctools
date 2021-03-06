#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <input_file>

        Turn pdf file <input_file> into csv list of transactions ready for use 
        in accounting software such as Wave accounting, and print result to 
        standard output.

        Keep only transaction list from the file, remove everything else.

        Accepts only pdf files generated by CIC.

Options:
        -h  Display this help message

Exit code:
        0   if everything goes well
        1   otherwise

EXAMPLE:
        $SCRIPT_NAME downloaded_file.pdf >reformatted_file.csv


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


# Proceed

_DIR_=$(dirname "${BASH_SOURCE[0]}")

"$_DIR_/"../utilities/pdftotext/pdftotext -table "$FILE" /dev/stdout | \
"$_DIR_/"utilities/convert_cic_pdf_text_to_csv/convert_cic_pdf_text_csv.sh

exit 0