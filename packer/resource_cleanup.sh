#!/bin/bash

# Function to delete EC2 instances with names starting with "packer_"
cleanup_ec2_instances() {
    echo "Finding security groups starting with 'packer_'..."

    # Fetch security groups with names starting with "packer_"
    sg_ids=$(aws ec2 describe-security-groups --query "SecurityGroups[?starts_with(GroupName, 'packer_')].GroupId" --output text)

    if [ -z "$sg_ids" ]; then
        echo "No security groups found with names starting with 'packer_'."
        return
    fi

    echo "Security groups found: $sg_ids"
    echo "Searching for instances associated with these security groups..."

    for sg_id in $sg_ids; do
        echo "Processing security group: $sg_id"

        # Fetch instance IDs associated with the security group, filtering out any null responses
        instance_ids=$(aws ec2 describe-instances \
            --filters "Name=instance.group-id,Values=$sg_id" \
            --query "Reservations[].Instances[].[InstanceId]" --output text | grep -v "None")

        # Check if instance IDs were found
        if [ -n "$instance_ids" ]; then
            echo "Terminating instances: $instance_ids"
            aws ec2 terminate-instances --instance-ids $instance_ids
        else
            echo "No instances found for security group $sg_id."
        fi
    done
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
