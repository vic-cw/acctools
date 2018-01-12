#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h]

        Read text representation of pdf from standard input, trim it to 
        keep only list of transactions, and print result in csv format to 
        standard output.

        Accepts only text extracted using 'pdftotext -table' from pdf files 
        generated by CIC.

Options:
        -h  Display this help message

Exit code:
        0   if everything goes well
        1   otherwise

EXAMPLE:
        cat transformed_pdf.txt | $SCRIPT_NAME >statement.csv


Project home page : https://github.com/vic-cw/acctools
_
EOF
)

shopt -s xpg_echo

# Check for call of help

while getopts "eh" opt; do
	case $opt in
		h)
			echo "$USAGE_MESSAGE" >&2
			exit 0
			;;
                e)
                        # Ignore, enable it to be specified for testing purposes
                        ;;
		\?)
			echo "$USAGE_MESSAGE" >&2
			exit 1
			;;
	esac
done

_DIR_=$(dirname "${BASH_SOURCE[0]}")

java -cp "$_DIR_/../../../utilities/acctools.jar" \
   eu.combal_weiss.victor.acctools.formatting.cic.pdf.ConvertCicPdfTextToCsv
