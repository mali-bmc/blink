#!/bin/sh
ls
GIT_HASH=
GIT_HASH=$1;
echo $GIT_HASH

BRANCH=$3

echo "The branch is $BRANCH";

### TEST @2

## Test @3

###test merge 4

GITHUB_TOKEN="c04f75a2016bd1d8f11da49a1840ff1c2582bdf9";

curl -s -u ${GITHUB_TOKEN}:x-oauth-basic https://api.github.com/repos/mali-bmc/blink/commits/${GIT_HASH}/statuses
