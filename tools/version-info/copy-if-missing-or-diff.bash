#!/bin/bash

# This script copies the first argument to the second
# if the second doesn't exist, or its contents differ from the first.

if ! { [ -e $2 ] && diff -q $1 $2; } then
  cp $1 $2
fi
