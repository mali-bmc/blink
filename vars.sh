#!/bin/sh
ls
GIT_HASH=
args=$1;shift
GIT_HASH=$1;
echo $GIT_HASH

GITHUB_TOKEN="86ef83265008f464358f319f96b5a45d976ca2c2";

curl -s -u ${GITHUB_TOKEN}:x-oauth-basic https://api.github.com/repos/mali-bmc/blink/commits/${GIT_HASH}/statuses
