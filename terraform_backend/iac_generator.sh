#!/bin/bash

BUCKET_SUFFIX=$1

if [ -z "$BUCKET_SUFFIX" ]; then
  echo "Error: BUCKET_SUFFIX environment variable is not set."
  exit 1
fi

sed "s/...replace.../$BUCKET_SUFFIX/g" iam.template > iam.json
echo "s3_suffix = \"$BUCKET_SUFFIX\"" > terraform.tfvars
