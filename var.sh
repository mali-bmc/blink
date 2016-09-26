#!/usr/bin/bash
##Change Creds
##Fix
GIT-USER="mali-bmc"
PWD="Gridapp123"
BRANCH=
TC_HOST=
TC_USER=
TC_PASS=
MATCHES=()
TC_BUILD_NOT=
PR_SHA==

##Test t etst test
function usage() {
  echo $1
  echo "Usage:"
  echo "-t, --github-token   The github token to query the API with"
  echo "-b, --branch         The branch to trigger TeamCity jobs for, using one of 'refs/heads/features', 'refs/pull/<pr_id>/head', or '<pr_id>'"
  echo "-s, --tc-host		 The TeamCity host to query the API for. Defaults to 'teamcity.conductor.com'"
  echo "-u, --tc-user        The TeamCity user to query the API with"
  echo "-p, --tc-pass        The TeamCity user's password to query the API with"
  echo "-m, --match          A <github_org>:<tc_job> combination where <tc_job> should be triggered if the 'branch' originated from <github_org>"
  echo "-n, --tc-not-match   The TeamCity job to trigger if the organization does not exist in the aforementioned 'match' list"
  echo "-h, --help           Displays this usage information."
  exit 1
}

##test
## Capture arguments
while [[ $1 ]]; do
	arg=$1; shift
	case ${arg} in
		-t|--github-token)  GITHUB_TOKEN=$1     ;  shift ;;
		-b|--branch)        BRANCH=$1           ;  shift ;;
		-s|--tc-host)       TC_HOST=$1          ;  shift ;;
		-u|--tc-user)       TC_USER=$1          ;  shift ;;
		-p|--tc-pass)       TC_PASS=$1          ;  shift ;;
		-m|--match)         MATCHES+=($1)       ;  shift ;;
		-n|--not-match)     TC_BUILD_NOT=$1     ;  shift ;;
		-h|--help)          usage               ;;
	esac
done


## All variables must be defined
#if [[ -z ${GITHUB_TOKEN} || -z ${BRANCH} || -z ${TC_USER} || -z ${TC_PASS} || -z ${MATCHES} || -z ${TC_BUILD_NOT} ]]; then
#	echo "All parameters are required. Please check that you have set them properly."
#	usage
#fi


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

	# Query github for PR details to determine the repo the PR originated from
	BASE_FORK=$(curl -s -u ${GIT-USER}:${PWD} https://api.github.com/repos/Conductor/conductor/pulls/${PULL_REQ_ID} | jq --raw-output .head.repo.full_name | cut -f1 -d/)
fi


## Validate $PULL_REQ_ID
if [[ -z ${BASE_FORK} || "${BASE_FORK}" == "null" ]]; then
	echo "Source fork could not be determined"
	exit 1
fi
echo "Source organization for branch [ ${PULL_REQ_ID} ]: ${BASE_FORK}"


## Kickoff teamcity plan if source repository matches
TC_BUILD=${TC_BUILD_NOT}
for i in "${MATCHES[@]}"
do
	ORG=$(echo ${i} | cut -f1 -d:)
	if [[ "${ORG}" == "${BASE_FORK}" ]]; then
		TC_BUILD=$(echo ${i} | cut -f2 -d:)
		break
	fi
done

## Don't kickoff a Teamcity build if a succesful one has already ran against the PR.

PR_SHA=$(curl -s -u ${GITHUB_TOKEN}:x-oauth-basic https://api.github.com/repos/Conductor/conductor/pulls/${PULL_REQ_ID} | jq --raw-output .head.sha)

PR_STATUS=$(curl -s -u ${GIT-USER}:${PWD} https://api.github.com/repos/Conductor/conductor/statuses/${PR_SHA} | jq --raw-output  '.[0].state')
if [[ ${PR_STATUS} == "success" ]]; then
	  TC_SUCCESSFUL_BUILD=$(curl -s -u ${GIT-USER}:${PWD} https://api.github.com/repos/Conductor/conductor/statuses/${PR_SHA} | jq --raw-output  '.[0].description')
	  echo "Teamcity has already reported the success status for the following build: ${TC_SUCCESSFUL_BUILD}"

#TC_SUCCESS_BUILD=$(curl -s -u ${GITHUB_TOKEN}:x-oauth-basic https://api.github.com/repos/Conductor/conductor/statuses/$i | jq --raw-output '.[] | select(.state=="success") | .description')

	exit 0
fi
  
## If there are already builds running for this PR they should be cancelled. 
#RUNNING_BUILD_NAMES=($(curl -s "http://${TC_USER}:${TC_PASS}@${TC_HOST}:8111/httpAuth/app/rest/builds?locator=branch:${PULL_REQ_ID},running:true" -H "Accept: application/json" | jq --raw-output .build[].buildTypeId))
#NUMBER_OF_RUNNING_BUILDS=${#RUNNING_BUILD_NAMES[*]}
#if [[ $NUMBER_OF_RUNNING_BUILDS -gt 1 ]]; then 
#	NUM_BUILDS_TO_CANCEL=$((${NUMBER_OF_RUNNING_BUILDS}-1))
#	echo "Canceling ${NUM_BUILDS_TO_CANCEL} builds that are already running for the PR"
#	for i in `seq 1 $NUMBER_OF_RUNNING_BUILDS`
#	do 
#		BUILD_TYPE=${RUNNING_BUILD_NAMES[i-1]}
#		if [[ "${BUILD_TYPE}" != "PreMergeWorkflows_Router" ]]; then								  
#			curl -s -X POST "http://${TC_USER}:${TC_PASS}@${TC_HOST}:8111/httpAuth/app/rest/builds/branch:${PULL_REQ_ID},running:true,buildType:id:${BUILD_TYPE}" -d "<buildCancelRequest comment='This build was cancelled because a new commit was pushed to the branch. Another Complete Workflow that includes the new commit will be triggered.' readdIntoQueue='false' />" -H "Content-Type: application/xml"
#		fi
#	done
#fi

## Trigger build for the PR
echo "Triggering TeamCity job: ${TC_BUILD}"
#curl -s "http://${TC_USER}:${TC_PASS}@${TC_HOST}:8111/httpAuth/action.html?add2Queue=${TC_BUILD}&branchName=${PULL_REQ_ID}"
