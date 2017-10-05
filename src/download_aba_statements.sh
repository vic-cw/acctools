#! /bin/bash

DEFAULT_CUT_OFF_DATE=14
DEFAULT_FILE_BASE_NAME="ABA Bank Statement - "
DEBUG="true"

FILE_EXTENSIONS="csv pdf xlsx"

SCRIPT_NAME=`basename "$0"`

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] [-c <cut_off_date>] [-d <output_directory>] [-f <filename>]
        $SCRIPT_NAME [-h] [-d <output_directory>] [-f <filename>] <end_date>
        $SCRIPT_NAME [-h] [-d <output_directory>] [-f <filename>] <start_date> <end_date>

DESCRIPTION
        Try to download Advanced Bank of Asia (ABA) bank statements and write them to files.

        If no argument is provided, compute end date as the latest ${DEFAULT_CUT_OFF_DATE}th day of the month prior to the \
current date,
        and compute start date as the $(( DEFAULT_CUT_OFF_DATE + 1 ))th day of the month prior to the end date.

        If only one argument is provided, assume it to be the end date, and compute start date as the day following
        the day with the same day number as the end date, one month before. For example, if end date is 2015-03-14,
        then start date is computed as 2015-02-15. If end date is 2015-03-31, then start date is computed as 2015-03-01.

        If -d and -f options are not provided, store files in the following locations : 
            <current_working_directory>/$DEFAULT_FILE_BASE_NAME<start_date> to <end_date>/$DEFAULT_FILE_BASE_NAME<start_date> \
to <end_date>.csv
            <current_working_directory>/$DEFAULT_FILE_BASE_NAME<start_date> to <end_date>/$DEFAULT_FILE_BASE_NAME<start_date> \
to <end_date>.pdf
            <current_working_directory>/$DEFAULT_FILE_BASE_NAME<start_date> to <end_date>/$DEFAULT_FILE_BASE_NAME<start_date> \
to <end_date>.xlsx

Arguments:
        <end_date>              End date of the statements to download, in format yyyy-mm-dd
        <start_date>            Start date of the statements to download, in format yyyy-mm-dd

Options:
        -c <cut_off_date>       Day of the month at which to compute end date [default: $DEFAULT_CUT_OFF_DATE]
        -d <output_directory>   Directory in which to create a subdirectory to store all downloaded files [default: working directory]
        -f <filename>           Name for created directory and for files names. Extension is appended. [default: see above]
        -h                      Display this help message

Exit code:
        0     if everything goes well
        1     if arguments provided are wrong
        2     if username, password or CAP card token are wrong
        3     if password has an incorrect format
        100   if request to bank website times out

EXAMPLES
        $SCRIPT_NAME -c 10 -d ~/Downloads
              Computes the latest day with day number equal to 10, and downloads the statements for the month ending on that day.
              For example, if called on 22nd March 2014, writes the following files :
              ~/Downloads/${DEFAULT_FILE_BASE_NAME}2014-02-11 to 2014-03-10/${DEFAULT_FILE_BASE_NAME}2014-02-11 to 2014-03-10.csv
              ~/Downloads/${DEFAULT_FILE_BASE_NAME}2014-02-11 to 2014-03-10/${DEFAULT_FILE_BASE_NAME}2014-02-11 to 2014-03-10.pdf
              ~/Downloads/${DEFAULT_FILE_BASE_NAME}2014-02-11 to 2014-03-10/${DEFAULT_FILE_BASE_NAME}2014-02-11 to 2014-03-10.xlsx

        $SCRIPT_NAME -f "Bank statement October" 2014-10-31
              Downloads statements from 1st October 2014 to 31st October 2014 and writes them in :
              <current working directory>/Bank statement October/Bank statement October.csv
              <current working directory>/Bank statement October/Bank statement October.pdf
              <current working directory>/Bank statement October/Bank statement October.xlsx


Project home page : https://github.com/vic-cw/acctools
_
EOF
)

shopt -s xpg_echo

# Check for call of help

while getopts ":h" opt; do
	case "$opt" in 
		h)
			echo "$USAGE_MESSAGE" >&2
			exit 0
			;;
	esac
done


# Interpret arguments provided

_DIR_=$(dirname "${BASH_SOURCE[0]}")
UTILITIES_DIR="$_DIR_/download_statements/utilities"

INTERPRETED_ARGUMENTS=$("$UTILITIES_DIR/generate_variables_from_arguments/generate_variables_from_arguments.sh" \
	$DEFAULT_CUT_OFF_DATE \
	$UTILITIES_DIR/generate_end_date_from_today/generate_end_date_from_today.sh \
	$UTILITIES_DIR/generate_start_date/generate_start_date.sh \
	"$DEFAULT_FILE_BASE_NAME" \
	"$@"
)
INTERPRETED_ARGUMENTS_RESULT="$?"

if [ "$INTERPRETED_ARGUMENTS_RESULT" = 1 ]; then
	echo  >&2
	echo "$INTERPRETED_ARGUMENTS\n" >&2
	echo "$USAGE_MESSAGE" >&2
	exit 1
fi

IFS=$'\n' read -d '' -r OUTPUT_DIRECTORY BASENAME START_DATE END_DATE <<< "$INTERPRETED_ARGUMENTS"

unset INTERPRETED_ARGUMENTS
unset INTERPRETED_ARGUMENTS_RESULT
unset UTILITIES_DIR


# Reformat arguments

GNU_DATE=$(date --version >/dev/null 2>&1 && echo true || echo false)

START_DATE=$($GNU_DATE && date -d "$START_DATE" "+%d/%m/%Y" \
                      || date -ujf"%Y-%m-%d" "$START_DATE" "+%d/%m/%Y" 2>/dev/null)
END_DATE=$($GNU_DATE && date -d "$END_DATE" "+%d/%m/%Y" \
                    || date -ujf"%Y-%m-%d" "$END_DATE" "+%d/%m/%Y" 2>/dev/null)
FILES_BASE_PATH="$OUTPUT_DIRECTORY/$BASENAME/$BASENAME"
unset OUTPUT_DIRECTORY
unset BASENAME


# Check for non writable files

NON_WRITABLE_FILES=$(for ext in $FILE_EXTENSIONS; do
	FILE_NAME="$FILES_BASE_PATH.$ext"
	if [ -a "$FILE_NAME" ] && [ ! -w "$FILE_NAME" ]; then
		echo "$FILE_NAME"
	fi
done)

if [ ! -z "$NON_WRITABLE_FILES" ]; then
	echo "Error: cannot write to one or more destination files.\n" \
		   "Please provide another destination or set correct write permissions : " >&2
	echo "$NON_WRITABLE_FILES" | sed 's/^/   /' >&2
	exit 1
fi


# Check for files already existing

EXISTING_FILES=$(for ext in $FILE_EXTENSIONS; do
	FILE_NAME="$FILES_BASE_PATH.$ext"
	if [ -a  "$FILE_NAME" ]; then
		echo "$FILE_NAME"
	fi
done)

if [ ! -z "$EXISTING_FILES" ]; then
	echo "One or more destination files already exist : "
	echo "$EXISTING_FILES" | sed 's/^/   /'
	printf "Overwrite (o), or cancel (c) ? "

	read user_answer

	UTILITIES_CONFIRMATION_DIR="$_DIR_/download_statements/utilities/user_confirmation"
	while ! "$UTILITIES_CONFIRMATION_DIR/is_valid_confirmation/is_valid_confirmation.sh" "$user_answer"; do
		printf "Didn't understand your answer. Please type in \"o\" to overwrite, or \"c\" to cancel : "
		read user_answer
	done

	if "$UTILITIES_CONFIRMATION_DIR/is_cancel_answer/is_cancel_answer.sh" "$user_answer"; then
		exit 1
	fi
fi


# Get credentials from user

read -p "Username: " username

printf "Password: "

stty_orig=`stty -g`
stty -echo
read passwd
stty $stty_orig

echo

read -p "CAP card token: " token


# Start

echo "Starting..."

PATH="$_DIR_/utilities/phantomjs:$_DIR_/download_statements/utilities/casperjs/bin:$PATH" \
casperjs \
       "$_DIR_/download_statements/download_aba_statements.js" \
       "--username=$username" \
       "--pwd=$passwd" \
       "--token=$token" \
       "--start-date=$START_DATE" \
       "--end-date=$END_DATE" \
       "--file-base-name=$FILES_BASE_PATH" \
       "--vdebug=$DEBUG"

CASPER_EXIT_CODE="$?"

exit $CASPER_EXIT_CODE
