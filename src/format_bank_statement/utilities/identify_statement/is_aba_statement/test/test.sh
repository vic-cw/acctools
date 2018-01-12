#! /bin/sh

_DIR_=$(dirname "${BASH_SOURCE[0]}")

"$_DIR_"/../../test_helper/test_helper.sh "$_DIR_/../is_aba_statement.sh" "$_DIR_/true" "$_DIR_/false"