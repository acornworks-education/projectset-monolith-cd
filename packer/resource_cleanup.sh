#!/bin/bash

# Function to delete EC2 instances with names starting with "packer_"
cleanup_ec2_instances() {
    echo "Finding EC2 instances with security groups starting with 'packer_'..."

    # Get the IDs of security groups with names starting with "packer_"
    sg_ids=$(aws ec2 describe-security-groups --query "SecurityGroups[?starts_with(GroupName, 'packer_')].[GroupId]" --output text)

    if [ -z "$sg_ids" ]; then
        echo "No security groups found with names starting with 'packer_'."
        return
    fi

    # Initialize an empty array to hold instances for deletion
    instances_to_delete=()

    # For each security group ID, find associated instances
    for sg_id in $sg_ids; do
        echo "Checking instances for security group $sg_id..."
        instance_ids=$(aws ec2 describe-instances --filters Name=instance.group-id,Values=$sg_id --query "Reservations[*].Instances[*].[InstanceId]" --output text)

        # Check if any instance IDs were returned
        if [ ! -z "$instance_ids" ]; then
            # Add instance IDs to the array
            for id in $instance_ids; do
                instances_to_delete+=($id)
            done
        fi
    done

    # Remove duplicate instance IDs if any
    unique_instances_to_delete=($(echo "${instances_to_delete[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

    # Terminate instances
    if [ ${#unique_instances_to_delete[@]} -ne 0 ]; then
        echo "Terminating instances: ${unique_instances_to_delete[@]}"
        aws ec2 terminate-instances --instance-ids ${unique_instances_to_delete[@]}
    else
        echo "No instances found with security groups starting with 'packer_'."
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
