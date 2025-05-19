#!/bin/bash
# Change these to your SD card partitions:
BOOT_PART=/dev/sdX1
ROOT_PART=/dev/sdX2

# Output image files:
BOOT_IMG=pi-boot.partclone.img
ROOT_IMG=pi-root.partclone.img

echo "Cloning BOOT partition $BOOT_PART to $BOOT_IMG..."
sudo partclone.fat32 -c -s "$BOOT_PART" -o "$BOOT_IMG"

echo "Cloning ROOT partition $ROOT_PART to $ROOT_IMG..."
sudo partclone.ext4 -c -s "$ROOT_PART" -o "$ROOT_IMG"

echo "Done! Images created:"
ls -lh "$BOOT_IMG" "$ROOT_IMG"