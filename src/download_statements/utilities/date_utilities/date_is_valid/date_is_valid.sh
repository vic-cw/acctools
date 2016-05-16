#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] <date>

        Assess whether <date> is a valid date in yyyy-mm-dd
        format.

        For example, rejects 2014-03-32, but rejection of
        2014-02-31 depends on the system: on UNIX, accepts 
        2014-02-31, while on Linux, rejects it.

        Does not print anything to standard output or error.

Exit code:
        0   if <date> is a valid date in yyyy-mm-dd format
        1   otherwise

Options:
        -h  Display this help message


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

DATE="$1"


# Test whether general format is valid

if [[ ! "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
	exit 1
fi

# Test whether available date command is UNIX or GNU date

GNU_DATE=$(date --version >/dev/null 2>&1 && echo true || echo false)

if $GNU_DATE ; then

	# Run checks

	if date -d "$DATE" >/dev/null 2>&1; then
		exit 0
	else
		exit 1
	fi

else
	OUTPUT=$(date -ujf"%Y-%m-%d" "$DATE" "+" 2>&1)
	if [ "$?" = 0 ] && [ -z "$OUTPUT" ]; then
		exit 0
	else
		exit 1
	fi
fi