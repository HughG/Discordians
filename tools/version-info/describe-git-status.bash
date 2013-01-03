#!/bin/bash

# Echo a single line describing the state of the working copy.

echo -n `git rev-parse --verify HEAD`
if ! git diff-index --quiet HEAD; then
    echo -n ", plus uncommitted changes"
fi
if git ls-files --others --exclude-standard --error-unmatch "./`git rev-parse --show-cdup`" >/dev/null 2>&1; then
    echo -n ", plus untracked files"
fi
echo
