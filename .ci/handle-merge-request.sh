#!/bin/bash

set -xe

export TOKEN=$1
export CI_MERGE_REQUEST_PROJECT_ID=$2
export CI_MERGE_REQUEST_IID=$3
export CI_MERGE_REQUEST_SOURCE_BRANCH_NAME=$4

export SPEC_NAME=gitlab-merge-requests-Guix-HPC-$CI_MERGE_REQUEST_SOURCE_BRANCH_NAME-$CI_MERGE_REQUEST_IID
export NR=1000

send_gitlab_comment() {
    curl --location --request POST "https://gitlab.inria.fr/api/v4/projects/$CI_MERGE_REQUEST_PROJECT_ID/merge_requests/$CI_MERGE_REQUEST_IID/notes" --header "PRIVATE-TOKEN: $TOKEN" --header "Content-Type: application/json" --data-raw "{ \"body\": \"$1\" }"
}

# Wait a few seconds for Cuirass to create the jobset after the webhook request
sleep 30

export ID=$(curl https://guix.bordeaux.inria.fr/api/evaluations\?nr=1\&spec=$SPEC_NAME | jq ".[].id")

if test -z $ID ; then
    export NSEC=120
    echo "Unable to get an evaluation, testing again in $NSEC seconds"
    sleep $NSEC
    export ID=$(curl https://guix.bordeaux.inria.fr/api/evaluations\?nr=1\&spec=$SPEC_NAME | jq ".[].id")
fi

export URL="https://guix.bordeaux.inria.fr/eval/$ID"

if test -z $ID ; then
    send_gitlab_comment "Unable to get an evaluation ID for $SPEC_NAME."
    exit 1
fi

send_gitlab_comment "Starting new evaluation at [$URL]($URL)."

echo "Waiting for the jobset to be evaluated..."
while test $(curl "https://guix.bordeaux.inria.fr/api/evaluation?id=$ID" | jq ".status") -eq -1 ; do
    sleep 120
done

# Exit if the evaluation failed
if test $(curl "https://guix.bordeaux.inria.fr/api/evaluation?id=$ID" | jq ".status") -ne 0 ; then
    echo "Evaluation failed"
    send_gitlab_comment "Evaluation $ID failed."
    exit 1
fi

echo "Waiting for the packages to be built..."
while test $(curl "https://guix.bordeaux.inria.fr/api/queue?evaluation=$ID&nr=$NR" | jq "length") -ne 0 ; do
    sleep 120
done

echo "Finished building packages, if any."
export JSON=$(curl "https://guix.bordeaux.inria.fr/api/latestbuilds?evaluation=$ID&nr=$NR")
export STATUS=$(echo $JSON | jq "map(select(.buildstatus != 0 and .weather == 1)) | length")
export NBUILDS=$(echo $JSON | jq "length")
export SUCCEEDED=$(echo $JSON | jq "map(select(.buildstatus == 0) | .nixname) | join(\", \")" | sed -e 's/"//g')
export SUCCEEDED="${SUCCEEDED:-None}"
export NEWLY_FAILED=$(echo $JSON | jq "map(select(.buildstatus != 0 and .weather == 1) | .nixname) | join(\", \")" | sed -e 's/"//g')
export NEWLY_FAILED="${FAILED:-None}"
export STILL_FAILING=$(echo $JSON | jq "map(select(.buildstatus != 0 and .weather != 1) | .nixname) | join(\", \")" | sed -e 's/"//g')
export STILL_FAILING="${STILL_FAILING:-None}"

send_gitlab_comment "*Number of packages rebuilt* (eval $ID): $NBUILDS packages rebuilt."

if [ $NBUILDS -ne 0 ] ; then
    send_gitlab_comment "*Succeeded builds* (eval $ID): $SUCCEEDED."
    send_gitlab_comment "*Newly failed builds* (eval $ID): $NEWLY_FAILED."
    send_gitlab_comment "*Builds still failing* (eval $ID, for information only): $STILL_FAILING."
fi

exit $STATUS
