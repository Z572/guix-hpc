#!/bin/bash

export TOKEN=$1
export CI_MERGE_REQUEST_PROJECT_ID=$2
export CI_MERGE_REQUEST_IID=$3
export CI_MERGE_REQUEST_SOURCE_BRANCH_NAME=$4
export CI_PROJECT_NAME=$5

export SPEC_NAME=gitlab-merge-request-$CI_PROJECT_NAME-$CI_MERGE_REQUEST_SOURCE_BRANCH_NAME
export NR=1000
export ID=$(curl https://guix.bordeaux.inria.fr/api/evaluations\?nr=1\&spec=$SPEC_NAME | jq ".[].id")
export URL="https://guix.bordeaux.inria.fr/eval/$ID"

curl --location --request POST "https://gitlab.inria.fr/api/v4/projects/$CI_MERGE_REQUEST_PROJECT_ID/merge_requests/$CI_MERGE_REQUEST_IID/notes" --header "PRIVATE-TOKEN: $TOKEN" --header "Content-Type: application/json" --data-raw "{ \"body\": \"Starting new evaluation at [$URL]($URL).\" }"

while test $(curl "https://guix.bordeaux.inria.fr/api/latestbuilds?evaluation=$ID&nr=$NR" | jq "map(select(.finished == 0)) | length") -ne 0 ; do
    sleep 120
done

export JSON=$(curl "https://guix.bordeaux.inria.fr/api/latestbuilds?evaluation=$ID&nr=$NR")
export STATUS=$(echo $JSON | jq "map(select(.buildstatus != 0)) | length")
export SUCCEEDED=$(echo $JSON | jq "map(select(.buildstatus == 0) | .nixname) | join(\", \")" | sed -e 's/"//g')
export FAILED=$(echo $JSON | jq "map(select(.buildstatus != 0) | .nixname) | join(\", \")" | sed -e 's/"//g')

curl --location --request POST "https://gitlab.inria.fr/api/v4/projects/$CI_MERGE_REQUEST_PROJECT_ID/merge_requests/$CI_MERGE_REQUEST_IID/notes" --header "PRIVATE-TOKEN: $TOKEN" --header "Content-Type: application/json" --data-raw "{ \"body\": \"*Suceeded*: $SUCCEEDED.\" }"
curl --location --request POST "https://gitlab.inria.fr/api/v4/projects/$CI_MERGE_REQUEST_PROJECT_ID/merge_requests/$CI_MERGE_REQUEST_IID/notes" --header "PRIVATE-TOKEN: $TOKEN" --header "Content-Type: application/json" --data-raw "{ \"body\": \"*Failed*: $FAILED.\" }"

exit $STATUS
