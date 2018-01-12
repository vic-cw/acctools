#! /bin/bash

SCRIPT_NAME=$(basename "$0")

USAGE_MESSAGE=$(cat <<EOF

Usage:  $SCRIPT_NAME [-h] [-z] (all|macosx|linux_32|linux_64) [<destination_directory>]

        Create distributable zip file from current source code for specified
        platform.

        By default, save zip files in builds directory.

        If "all" is chosen, list platforms by 
        listing subdirectories in the executables_for_distributions/ 
        folder, and use their name as platform name.

        Expects executables to be present directly in each
        platform directory.

        Example tree:

        executables_for_distributions
          |-linux_32
          |   |-phantomjs
          |-linux_64
          |   |-pantomjs

        Options:
          -z      Skip zipping


Project home page : https://github.com/vic-cw/acctools
_
EOF
)

shopt -s xpg_echo

# Check for call of help

ZIP=true

while getopts ":hz" opt; do
	case "$opt" in 
		h)
			echo "$USAGE_MESSAGE" >&2
			exit 0
			;;
                z)
                        ZIP=false
                        shift
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

# Set up

_DIR_=$(dirname ${BASH_SOURCE[0]}})
EXECUTABLES_DIR="$_DIR_/executables_for_distributions"
SRC_DIR="$_DIR_/src"
OUTPUT_DIR="$_DIR_/builds"
JAR_FILE="$OUTPUT_DIR/acctools.jar"

if [ "$1" = "all" ]; then
    PLATFORMS=$(ls -1 "$EXECUTABLES_DIR")
else
    PLATFORMS="$1"
fi;

if [ $# -ge 2 ]; then
	OUTPUT_DIR="$2"
fi

# Compile Java

echo "Compiling Java"
JAVA_TEMP_DIR="$OUTPUT_DIR/java"
mkdir -p "$JAVA_TEMP_DIR"
JAVA_CLASSES_DIR="$JAVA_TEMP_DIR/classes"
mkdir -p "$JAVA_CLASSES_DIR"
JAVA_SRC_DIR="$SRC_DIR/java"
JAVA_FILE_LIST="$JAVA_TEMP_DIR/files"
find "$JAVA_SRC_DIR" -name '*.java' > "$JAVA_FILE_LIST"
javac -d "$JAVA_CLASSES_DIR" "@$JAVA_FILE_LIST"

echo "Building jar"
cp "$JAVA_SRC_DIR/manifest.mf" "$JAVA_CLASSES_DIR"
cp -R "$JAVA_SRC_DIR/resources/"* "$JAVA_CLASSES_DIR"
OLD_WD="$(pwd)"
cd "$JAVA_CLASSES_DIR"
find . -name '.DS_Store' -type f -delete
jar cvfm "acctools.jar" manifest.mf ./
cd "$OLD_WD"
mv "$JAVA_CLASSES_DIR/acctools.jar" "$JAR_FILE"

echo "Cleaning up Java temp files"
rm -Rf "$JAVA_TEMP_DIR"

# Iterate on plaforms

while read platform; do

	DEST="$OUTPUT_DIR/$platform"
	echo "Building for $platform"


	# Clean

	rm -rd "$DEST" 2>/dev/null
	mkdir -p "$DEST" 2>/dev/null


	# Copy source files

	echo "   Copying source files"

	rsync -a \
		--exclude=**/.DS_Store \
		--exclude=**/download_statements/debug/** \
		--exclude=**/utilities/phantomjs/phantomjs \
                --exclude=java \
		"$SRC_DIR/" "$DEST"


	# Set debug to false in download_aba_statements.sh

	cat "$SRC_DIR/download_aba_statements.sh" | \
		sed 's/^DEBUG="true"$/DEBUG="false"/' >"$DEST/download_aba_statements.sh"


	# Copy executables

	echo "   Copying executables"

	mkdir -p "$DEST/utilities/phantomjs"
	cp "$EXECUTABLES_DIR/$platform/phantomjs" "$DEST/utilities/phantomjs/phantomjs"
        cp "$JAR_FILE" "$DEST/utilities/acctools.jar"

	# Zip

        if $ZIP; then
            printf "   Zipping"

            ( cd "$DEST" && zip -q -dg -r "acctools-$platform.zip" * --exclude "*/.DS_Store" )
            mv "$DEST/acctools-$platform.zip" "$OUTPUT_DIR"
        fi;

	echo "   Done"

done <<< "$PLATFORMS"


# Clean up jar file

rm -f "$JAR_FILE"
