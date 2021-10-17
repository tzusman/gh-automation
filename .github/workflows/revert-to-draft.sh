#!/bin/bash

set -e

if [[ $# -eq 0 ]]; then
  echo 'Usage: ./revert-to-draft.sh [PR ID]'
  exit 1
fi

MUTATION='
  mutation($id: String!) {
    convertPullRequestToDraft(input: { pullRequestId: $id }) {
      pullRequest {
        id
        number
        isDraft
      }
    }
  }
'
gh api graphql -F id="$1" -f query="${MUTATION}" >/dev/null
