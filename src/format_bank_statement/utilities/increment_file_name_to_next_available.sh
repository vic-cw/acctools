#! /bin/sh

shopt -s xpg_echo

FILE="$1"

while [ -f "$FILE" ] ; do
	OUTPUT_FOLDER=$(dirname "$FILE")
	FILE_NAME=$(basename "$FILE")
	FILE_REAL_NAME="${FILE_NAME%%.*}"
	if [ "$FILE_REAL_NAME" = "$FILE_NAME" ] ; then
		FILE_EXTENSION="" 
	else 
		FILE_EXTENSION=".${FILE_NAME#*.}"
	fi

	PATTERN_GREP="^$FILE_REAL_NAME ([0-9]*)$FILE_EXTENSION"
	PATTERN_SED="$FILE_REAL_NAME (\([0-9]*\))$FILE_EXTENSION"

	MAX_EXISTING_INDEX=$(cd "$OUTPUT_FOLDER" ; ls -1  | grep "$PATTERN_GREP" | sed "s/$PATTERN_SED/\1/" | sort -nr | head -1)
	INDEX_FOR_OUR_FILE=$(($MAX_EXISTING_INDEX+1))

	FILE="$OUTPUT_FOLDER/$FILE_REAL_NAME ($INDEX_FOR_OUR_FILE)$FILE_EXTENSION"
done

echo "$FILE"