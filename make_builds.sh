#! /bin/sh

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] [<destination_directory>]

        Create distributable zip files for all platforms from
        current source code.

        By default, save zip files in builds directory.

        List platforms by listing subdirectories in the
        executables_for_distributions/ folder, and use their
        name as platform name.

        Expects executables to be present directly in each
        platform directory.

        Example tree:

        executables_for_distributions
          |-linux_32
          |   |-phantomjs
          |-linux_64
          |   |-pantomjs


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


# Set up

_DIR_=$(dirname ${BASH_SOURCE[0]}})
EXECUTABLES_DIR="$_DIR_/executables_for_distributions"
SRC_DIR="$_DIR_/src"
OUTPUT_DIR="$_DIR_/builds"

if [ $# -ge 1 ]; then
	OUTPUT_DIR="$1"
fi


# Iterate on plaforms

PLATFORMS=$(ls -1 "$EXECUTABLES_DIR")

while read platform; do

	DEST="$OUTPUT_DIR/$platform"
	echo "Building for $platform"


	# Clean

	rm -rd "$DEST" 2>/dev/null
	mkdir "$DEST" 2>/dev/null


	# Copy source files

	echo "   Copying source files"

	rsync -a \
		--exclude=**/.DS_Store \
		--exclude=**/download_statements/debug/** \
		--exclude=**/utilities/phantomjs/phantomjs \
		"$SRC_DIR/" "$DEST"


	# Set debug to false in download_aba_statements.sh

	cat "$SRC_DIR/download_aba_statements.sh" | \
		sed 's/^DEBUG="true"$/DEBUG="false"/' >"$DEST/download_aba_statements.sh"


	# Copy executables

	echo "   Copying executables"

	cp "$EXECUTABLES_DIR/$platform/phantomjs" "$DEST/utilities/phantomjs/phantomjs"


	# Zip

	printf "   Zipping"

	( cd "$DEST" && zip -q -dg -r "acctools-$platform.zip" * --exclude "*/.DS_Store" )

	echo "   Done"

done <<< "$PLATFORMS"