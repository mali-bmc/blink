#!/bin/sh
echo "first line"
##Change Creds
##Fix

## Don't kickoff a Teamcity build if a succesful one has already ran against the PR.
PULL_REQ_ID=$1

PR_SHA=$(curl -s -u mali-bmc:Gridapp123 https://api.github.com/repos/Conductor/conductor/pulls/${PULL_REQ_ID})

PR_STATUS=$(curl -s -u mali-bmc:Gridapp123  https://api.github.com/repos/Conductor/conductor/statuses/${PR_SHA}|grep success)
if [[ ${PR_STATUS} == "success" ]]; then
	  TC_SUCCESSFUL_BUILD=$(curl -s -u mali-bmc:Gridapp123 https://api.github.com/repos/Conductor/conductor/statuses/${PR_SHA})
	  echo "Teamcity has already reported the success status for the following build: ${TC_SUCCESSFUL_BUILD}"

#TC_SUCCESS_BUILD=$(curl -s -u ${GITHUB_TOKEN}:x-oauth-basic https://api.github.com/repos/Conductor/conductor/statuses/$i | jq --raw-output '.[] | select(.state=="success") | .description')

	exit 0
else 
echo "this is the else part";

echo ${PR_SHA};
curl -s -u mali-bmc:Gridapp123  https://api.github.com/repos/Conductor/conductor/statuses/${PR_SHA};

curl -s -u mali-bmc:Gridapp123 https://api.github.com/repos/Conductor/conductor/statuses/${PR_SHA};

fi
  
