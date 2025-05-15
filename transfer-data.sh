#!/bin/bash

# Define source and target drives
SOURCE="/dev/sdb"
TARGET="/dev/sdc"

# Wipe the target drive
echo "Wiping $TARGET..."
sudo wipefs -a $TARGET
sudo dd if=/dev/zero of=$TARGET bs=1M count=100

# Create a new partition table on the target drive
echo "Creating a new partition table on $TARGET..."
sudo parted $TARGET mklabel msdos

# Clone each partition from source to target
echo "Cloning partitions from $SOURCE to $TARGET..."

# Get the list of partitions on the source drive
parted $SOURCE unit GB print | grep "^ " | awk '{print $1}' | while read PARTITION; do
    # Get the start and end of the partition
    START=$(sudo parted $SOURCE unit GB print | grep "$PARTITION" | awk '{print $2}' | sed 's/GB//')
    END=$(sudo parted $SOURCE unit GB print | grep "$PARTITION" | awk '{print $3}' | sed 's/GB//')

    # Create the partition on the target drive
    echo "Creating partition $PARTITION on $TARGET..."
    sudo parted $TARGET mkpart primary $START GB $END GB

    # Get the partition number
    PART_NUM=$(echo $PARTITION | sed 's/[^0-9]*//g')

    # Clone the partition using dd
    echo "Cloning partition $PARTITION to $TARGET..."
    sudo dd if=${SOURCE}${PARTITION} of=${TARGET}${PARTITION} bs=4M status=progress
done

echo "Cloning completed successfully."
