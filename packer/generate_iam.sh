#!/bin/bash

# Define an array of regions
regions=("ap-southeast-2" "ap-northeast-2")

# Loop through the array and generate a JSON file for each region
for region in "${regions[@]}"; do
    jsonnet --ext-str region="$region" -o "${region}.json" packer.jsonnet
done
