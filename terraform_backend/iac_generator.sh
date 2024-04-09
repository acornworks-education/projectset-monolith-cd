#!/bin/bash

BUCKET_SUFFIX=$1

if [ -z "$BUCKET_SUFFIX" ]; then
  echo "Error: BUCKET_SUFFIX environment variable is not set."
  exit 1
fi

sed "s/...replace.../$BUCKET_SUFFIX/g" s3.template > s3.tf
sed "s/...replace.../$BUCKET_SUFFIX/g" iam.template > iam.json
