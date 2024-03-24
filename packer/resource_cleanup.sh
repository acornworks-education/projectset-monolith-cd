#!/bin/bash

# Function to delete EC2 instances with names starting with "packer_"
cleanup_ec2_instances() {
    echo "Finding and deleting EC2 instances with names starting with 'packer_'..."
    instances=$(aws ec2 describe-instances --query "Reservations[].Instances[?starts_with(Tags[?Key=='Name'].Value | [0], 'packer_')].[InstanceId]" --output text)
    if [ -n "$instances" ]; then
        aws ec2 terminate-instances --instance-ids $instances
        echo "Instances terminated: $instances"
    else
        echo "No matching EC2 instances found."
    fi
}

# Function to delete security groups tagged with names starting with "packer_"
cleanup_security_groups() {
    echo "Finding and deleting security groups with names starting with 'packer_'..."
    groups=$(aws ec2 describe-security-groups --query "SecurityGroups[?starts_with(GroupName, 'packer_')].[GroupId]" --output text)
    if [ -n "$groups" ]; then
        for group in $groups; do
            aws ec2 delete-security-group --group-id $group
            echo "Security group deleted: $group"
        done
    else
        echo "No matching security groups found."
    fi
}

# Function to delete key pairs with names starting with "packer_"
cleanup_key_pairs() {
    echo "Finding and deleting key pairs with names starting with 'packer_'..."
    keys=$(aws ec2 describe-key-pairs --query "KeyPairs[?starts_with(KeyName, 'packer_')].[KeyName]" --output text)
    if [ -n "$keys" ]; then
        for key in $keys; do
            aws ec2 delete-key-pair --key-name $key
            echo "Key pair deleted: $key"
        done
    else
        echo "No matching key pairs found."
    fi
}

# Execute cleanup functions
cleanup_ec2_instances
cleanup_security_groups
cleanup_key_pairs
