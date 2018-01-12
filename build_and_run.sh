#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] (macosx|linux_32|linux_64) <executable>

        Build project for specified platform and run <executable>
        from generated build.

        <executable> is interpreted as a relative path from build
        directory. Structure is similar to path from within the
        "src" directory.

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

if [ $# -lt 2 ]; then
    echo "$USAGE_MESSAGE" >&2
    exit 1
fi


_DIR_=$(dirname ${BASH_SOURCE[0]}})
OUTPUT_DIR="$_DIR_/builds"

"$_DIR_/make_builds.sh" -z "$1" && \
"$OUTPUT_DIR/$1/$2"

exit $?