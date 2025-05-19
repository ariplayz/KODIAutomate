#!/bin/bash

# Define the device and output ISO file
DEVICE="/dev/sdb"
OUTPUT_ISO="Live.iso"

# Check if the device exists
if [ ! -b "$DEVICE" ]; then
    echo "Error: Device $DEVICE does not exist."
    exit 1
fi

# Get the size of the used space on the SD card
USED_SIZE=$(sfdisk -s "$DEVICE" | awk '{print $1}')

# Create the ISO image using dd, skipping empty space
echo "Creating ISO image of $DEVICE..."
dd if="$DEVICE" of="$OUTPUT_ISO" bs=4M count="$USED_SIZE" status=progress

echo "ISO image created: $OUTPUT_ISO"
