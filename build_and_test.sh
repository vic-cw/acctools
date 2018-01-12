#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] (macosx|linux_32|linux_64)

        Build project for specified platform and runs test from generated build.

        Write build in builds directory.

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
		\?)
			echo "$USAGE_MESSAGE" >&2
			exit 1
			;;
	esac
done

# Check arguments

if [ $# -lt 1 ]; then
    echo "$USAGE_MESSAGE" >&2
    exit 1
fi


_DIR_=$(dirname ${BASH_SOURCE[0]}})

"$_DIR_/build_and_run.sh" "$1" "run_all_tests.sh"

exit $?