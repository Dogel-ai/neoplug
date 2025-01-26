#!/bin/bash

PLUG_DIR="/home/dogiel/.config/nvim/lua/plugins"

usage() {
    echo "Usage: neoplug <new/list/open/remove/archive/recover> <name>"
    echo "  -p,  --priority  <int>"
    echo "  -nl, --no-lazy"
    [[ -n "$1" ]] && echo "$1"
    exit 2
}

[[ $# -lt 2 ]] && usage "Insufficient arguments (expected 2, got $#)"

op="$1"

[[ "$op" != "new" && "$op" != "open" && "$op" != "list" && "$op" != "remove" && "$op" != "archive" && "$op" != "recover" ]] && usage "Invalid operation."

PLUG_NAME="$2"

NO_LAZY_FLAG=''
PRIORITY_FLAG=''

isint_Case() { case ${1#[-+]} in ''|*[!0-9]*) return 1;;esac;}
isntSuffix() { case $1 in *"$2") return 1;; esac }

# Check if filename ends in .lua
if isntSuffix $PLUG_NAME .lua; then
    PLUG_NAME=$PLUG_NAME.lua
fi

PLUG_FILE=$PLUG_DIR/$PLUG_NAME

# Check for NO_LAZY flag on 3 and 4 positions
if [ "$3" = "-nl" -o "$3" = "--no-lazy" -o "$4" = "-nl" -o "$4" = "--no-lazy" -o "$5" = "-nl" -o "$5" = "--no-lazy" ]; then
    NO_LAZY_FLAG="true"
fi

# Check for PRIORITY flag on 3 and 4 positions
if [ "$3" = "-p" -o "$3" = "--priority" ]; then
    if [ "$4" = "" ] || ! isint_Case "$4"; then
        usage "Invalid priority value"
    fi
    PRIORITY_FLAG="$4"
fi

if [ "$4" = "-p" -o "$4" = "--priority" ]; then
    if [ "$5" = "" ] || ! isint_Case "$5"; then
        usage "Invalid priority value"
    fi
    PRIORITY_FLAG="$5"
fi




if [ $op = "open" ]; then
    #nvim $PLUG_FILE
    if test -f "$PLUG_FILE"; then
        nvim $PLUG_FILE
    else
        echo "Plugin \"$PLUG_NAME\" not found."
        echo "Would you like to create it? (Y/n)"
    fi
fi

if [ $op = "list" ]; then
    echo "list"
fi

if [ $op = "new" ]; then
    touch $PLUG_FILE

    echo "return {
    {
        \"name/$2\"," > $PLUG_FILE
    if [ "$NO_LAZY_FLAG" = "true" ]; then
        echo "        lazy = false," >> $PLUG_FILE
    fi
    if [ "$PRIORITY_FLAG" != '' ]; then
        echo "        priority = $PRIORITY_FLAG," >> $PLUG_FILE
    fi
    echo "        config = function()
            -- params
        end,
    },
}" >> $PLUG_FILE
fi

if [ $op = "remove" ]; then
    rm $PLUG_FILE
fi

if [ $op = "archive" ]; then
    if [ ! -d "$PLUG_DIR/../neoplug_archive" ]; then
        mkdir $PLUG_DIR/../neoplug_archive/
    fi
    mv $PLUG_FILE $PLUG_DIR/../neoplug_archive/
fi

if [ $op = "recover" ]; then
    mv $PLUG_DIR/../neoplug_archive/$PLUG_NAME $PLUG_DIR
fi
