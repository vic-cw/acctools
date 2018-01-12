#! /bin/bash

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] [-o] <input_file> [<output_file>]
        $SCRIPT_NAME -e [-h] <input_file>

DESCRIPTION
        Format specified csv file to make it ready for use in accounting
        software such as Wave accounting.

        Perform 2 tasks :
           - keep only transaction list in the file, remove everything else
           - convert from semicolon-delimited csv file to comma-delimited

        Accepts only PDF or csv files generated by Crédit Industriel et 
        Commercial (CIC), or csv files generated either by Société Générale or
        Advanced Bank of Asia.

        If <output_file> and -e are not provided, output to a file with same
        name as <input_file>, with "Reformatted " prefixed to file name.
        Example: /path/to/file.csv => /path/to/Reformatted file.csv

        In that case, if computed file name already exists, increment name
        until the name is available.

Arguments:
        <input_file>   Csv encoded file to process
        <output_file>  File to write result to [default: See above]

Options:
        -e             Print result to standard output, instead of file
        -o             If <output_file> already exists, overwrite
        -h             Display this help message

EXAMPLES
        $SCRIPT_NAME /path/to/file.csv
             Outputs result to /path/to/Reformatted file.csv

        $SCRIPT_NAME /path/to/file.csv /other/document.csv
             Outputs result to /other/document.csv

        $SCRIPT_NAME -e /path/to/file.csv
             Prints result to standard output

        $SCRIPT_NAME -o /path/to/file.csv /other/document.csv
             Outputs result to /other/document.csv, overwriting without asking for
             confirmation if /other/document.csv already exists


Project home page : https://github.com/vic-cw/acctools
_
EOF
)

shopt -s xpg_echo

ECHO=false
OUTPUT_FILE_SPECIFIED=false
OVERWRITE=false

_DIR_=$(dirname "${BASH_SOURCE[0]}")


# Read flags to set variables

while getopts ":eoh" OPT "$@" ; do
	case $OPT in
		e)
			ECHO=true
			;;
		o)
			OVERWRITE=true
			;;
		h)
			echo "$USAGE_MESSAGE" >&2
			exit 0
			;;
		\?)
			echo "Unknown flag -$OPTARG. \n$USAGE_MESSAGE" >&2
			exit 1
			;;
	esac
done
unset OPT
unset OPTARG


# Read arguments to set variables

shift $(( OPTIND - 1 ))

if [ $# = 0 ] ; then
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

INPUT_FILE="$1"
INPUT_FILE_FOLDER=$(dirname "$INPUT_FILE")
INPUT_FILE_BASENAME=$(basename "$INPUT_FILE")

if [ $# -ge 2 ] ;  then
	OUTPUT_FILE_SPECIFIED=true
	OUTPUT_FILE="$2"
fi


# Set output file if not specified

CSV_REGEX=".+\.csv$"

if ! "$ECHO" && ! "$OUTPUT_FILE_SPECIFIED" ; then
	if [[ "$INPUT_FILE_BASENAME" =~ $CSV_REGEX ]]; then
		OUTPUT_FILE="$INPUT_FILE_FOLDER/Reformated $INPUT_FILE_BASENAME"
	else
		OUTPUT_FILE="$INPUT_FILE_FOLDER/$(\
			$_DIR_/utilities/change_name_to_extension/change_name_to_extension.sh "$INPUT_FILE_BASENAME" csv)"
	fi
fi
unset INPUT_FILE_FOLDER
unset INPUT_FILE_BASENAME


# If writing to file, make sure there is no overwriting problem

if ! "$ECHO" && ! "$OVERWRITE" && [ -f "$OUTPUT_FILE" ] ; then

	# If output file was specified, only give option to cancel or overwrite

	if "$OUTPUT_FILE_SPECIFIED" ; then
		PROMPT="File $OUTPUT_FILE already exists. Overwrite (y), or cancel (c) ? "
		ANSWER=""
		while [ "$ANSWER" != "y" ] && [ "$ANSWER" != "c" ] && [ "$ANSWER" != "yes" ] && [ "$ANSWER" != "cancel" ] ; do
			read -p "$PROMPT" ANSWER
			ANSWER=$(echo "$ANSWER" | tr '[:upper:]' '[:lower:]')
		done
		if [ "$ANSWER" = "c" -o "$ANSWER" = "cancel" ] ; then
			exit 0
		fi
		unset ANSWER

	# If no output file was specified, increment filename until there is no overwrite

	else
		OUTPUT_FILE=$("$_DIR_/format_bank_statement/utilities/increment_file_name_to_next_available.sh" \
			"$OUTPUT_FILE")
	fi
fi


# Identify origin of file and dispatch to relevant processing script

if   "$_DIR_/format_bank_statement/utilities/identify_statement/is_aba_statement/is_aba_statement.sh" "$INPUT_FILE"; then
	RESULT=$("$_DIR_/format_bank_statement/format_aba_statement.sh" "$INPUT_FILE")

elif "$_DIR_/format_bank_statement/utilities/identify_statement/is_soge_statement/is_soge_statement.sh" "$INPUT_FILE"; then
	RESULT=$("$_DIR_/format_bank_statement/format_soge_statement.sh" "$INPUT_FILE")

elif "$_DIR_/format_bank_statement/utilities/identify_statement/is_cic_csv_statement/is_cic_csv_statement.sh" "$INPUT_FILE"; then
	RESULT=$("$_DIR_/format_bank_statement/format_cic_statement.sh" "$INPUT_FILE")

elif "$_DIR_/format_bank_statement/utilities/identify_statement/is_cic_pdf_statement/is_cic_pdf_statement.sh" "$INPUT_FILE"; then
	RESULT=$("$_DIR_/format_bank_statement/process_cic_pdf_statement.sh" "$INPUT_FILE")
else
	echo "Unidentified bank statement : $INPUT_FILE" >&2
	exit 1
fi
EXIT_CODE="$?"


# Redirect result to desired output

if "$ECHO" ; then
	echo "$RESULT"
elif [ "$EXIT_CODE" = 0 ]; then
	echo "$RESULT" > "$OUTPUT_FILE"
	echo "Result recorded in $OUTPUT_FILE"
fi

exit "$EXIT_CODE"
