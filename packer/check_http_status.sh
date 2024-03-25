#!/bin/bash

# URL is passed as an argument
URL=$1
STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" "$URL")

if [ "$STATUS_CODE" -eq 200 ]; then
  echo "Service is up and running with status code 200."
  exit 0
else
  echo "Service check failed with status code: $STATUS_CODE."
  exit 1
fi
