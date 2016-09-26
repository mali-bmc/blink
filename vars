#!/bin/sh
ls
GIT_HASH=
args=$1;shift
GIT_HASH=$1;
echo $GIT_HASH


### TEST @2

## Test @3

###test merge 4

## Determine PR id from string
BASE_FORK=
PULL_REQ_ID=
if [[ "${BRANCH}" == "refs/heads/features" ]]; then
        # Enforced: refs/heads/features
        PULL_REQ_ID=refs/heads/features
        BASE_FORK=Conductor
else
        # Expected: refs/pull/<id>/head
        PULL_REQ_ID=$(echo ${BRANCH} | cut -f3 -d/)

        #a Query github for PR details to determine the repo the PR originated from
        BASE_FORK=$(curl -s -u ${GITHUB_TOKEN}:x-oauth-basic https://api.github.com/repos/Conductor/conductor/pulls/${PULL_REQ_ID} | jq --raw-output .head.repo.full_name | cut -f1 -d/)
fi




GITHUB_TOKEN="c04f75a2016bd1d8f11da49a1840ff1c2582bdf9";

curl -s -u ${GITHUB_TOKEN}:x-oauth-basic https://api.github.com/repos/mali-bmc/blink/commits/${GIT_HASH}/statuses


PR_SHA=$(curl -s -u ${GITHUB_TOKEN}:x-oauth-basic https://api.github.com/repos/Conductor/conductor/pulls/${PULL_REQ_ID} | jq --raw-output .head.sha)

PR_STATUS=$(curl -s -u ${GITHUB_TOKEN}:x-oauth-basic https://api.github.com/repos/Conductor/conductor/statuses/${PR_SHA} | jq --raw-output  '.[0].state')
if [[ ${PR_STATUS} == "success" ]]; then
          TC_SUCCESSFUL_BUILD=$(curl -s -u ${GITHUB_TOKEN}:x-oauth-basic https://api.github.com/repos/Conductor/conductor/statuses/${PR_SHA} | jq --raw-output  '.[0].description')
          echo "Teamcity has already reported the success status for the following build: ${TC_SUCCESSFUL_BUILD}"
          
          
