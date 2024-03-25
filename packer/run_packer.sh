#!/bin/bash

# Function to ensure we return to the original directory
function finish {
  cd "$CURR_PATH"
}
trap finish EXIT

# Check if an AWS profile is passed as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <aws-profile>"
    exit 1
fi

AWS_PROFILE=$1
export AWS_PROFILE

CURR_PATH=$(pwd)
cd ..
./gradlew bootJar

JAR_PATH=$(cat ./build/path.txt)
cd $CURR_PATH
cp $JAR_PATH monolith.jar

packer init .
packer build packer.pkr.hcl

export AMI_ID=$(aws ec2 describe-images \
    --owners self \
    --filters "Name=name,Values=monolith-ami-*" \
    --query "Images | sort_by(@, &CreationDate) | [-1].ImageId" \
    --output text)

echo "AMI ID: ${AMI_ID}"
