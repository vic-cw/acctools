#! /bin/bash

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <input_file>

        Test whether <input_file> seems to be a pdf statement from
        Crédit Industriel et Commercial (CIC).

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


# Check if file is pdf

_DIR_=$(dirname "${BASH_SOURCE[0]}")

if ! "$_DIR_/../is_pdf_file/is_pdf_file.sh" "$FILE"; then
	exit 1
fi


# Check if first line is correct, and if there is an opening transaction list

FIRST_LINE_REGEX=" *Crédit +Industriel +et +Commercial *"
FIRST_LINE_REGEX="${FIRST_LINE_REGEX//[^[:ascii:]]/}"

START_LINE_REGEX=" *Date +Date +valeur +Opération +Débit +euros +Crédit +euros *"
START_LINE_REGEX="${START_LINE_REGEX//[^[:ascii:]]/}"


"$_DIR_/../../../../utilities/pdftotext/pdftotext" -table "$FILE" /dev/stdout | \
java -cp "$_DIR_/../../../../utilities/jars/acctools.jar" \
   eu.combal_weiss.victor.acctools.formatting.cic.pdf.IsCicPdfText

if [ "${PIPESTATUS[1]}" != "0" ]; then
	exit 1
fi

exit 0