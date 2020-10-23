#!/bin/bash

# Init input
input=""

# check if argument 1 is a file/directory
if [ -f "$1" ]
then
    input="file"
elif [ -d "$1" ]
then
    input="dir"
else
    echo argument 1 '"'$1'"' is not file or a directory. Exiting.
    exit
fi

# check if second argument is valid
if [ ! -n $2 ] && [ "$2" != "require" ] && [ "$2" != "import" ]
then
    echo 'second argument must be either "require", "import", or nothing (defaults to require)'
    exit
fi

function replace() {
    if [ "$2" = require ] || [ ! -n "$2" ]          # Change Import to Require (default)
    then
        echo "import to require"
        sed -i -E 's|import ([^{,*]+?) from ('.+?')|const \1 = require(\2)|g' "$1"    # replace import x from 'x'
        sed -i -E 's|import \{ (.+?) \} from ('.+?')|const \1 = require(\2)|g' "$1"   # replace import { x } from 'x'
        sed -i -E 's|import \{(.+?)\} from ('.+?')|const \1 = require(\2)|g' "$1"     # replace import {x} from 'x'
        sed -i -E 's|import \* as (.+?) from ('.+?')|const \1 = require(\2)|g' "$1"   # replace import * as x from 'x'

        sed -i -E 's|export (.+?\(\) {)|\1' "$1"                                      # replace exported methods export 'x' function()
    elif [ "$2" = import ]                          # Change Require to Import
    then
        echo "require to import"
        sed -i -E 's|const (.+?) = require\(('.+?')\)|import \1 from \2|g' "$1"       # replace const x = require('x')
    fi
}

if [ "$input" = "file" ]
then
    replace "$1" "$2"
else
    cd $(realpath "$1")

    # Store Internal Field Separator var
    OIFS="$IFS"
    
    # Set IFS to new line
    IFS=$'\n'

    # get all javascript files
    FILES=$(find . -name "*.js");

    # loop through .js files and run replace function
    for file in $FILES; do replace "$file" $2; done

    # Set IFS back to original value
    IFS="$OIFS"
fi