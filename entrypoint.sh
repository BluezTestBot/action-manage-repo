#!/bin/sh

set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "Set GITHUB_TOKEN environment variable"
    exit 1
fi

/manage_repo.sh "$@"
