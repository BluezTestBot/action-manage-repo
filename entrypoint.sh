#!/bin/bash

set -e

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Set GITHUB_TOKEN environment variable"
    exit 1
fi

if [ "$FOR_UPSTREAM_BRANCH" = 'none' ]; then
    /manage_repo.sh "$@"
else
    /manage_repo_for_upstream.sh "$@"
fi
