#!/bin/bash
# Variables
BOOT_DEV=/dev/sdX1      # Change to your boot partition
ROOT_DEV=/dev/sdX2      # Change to your root partition

# 1. Clone and restore minimal-size partition images
sudo partclone.fat32 -c -s "$BOOT_DEV" -o pi-boot.partclone.img
sudo partclone.ext4  -c -s "$ROOT_DEV" -o pi-root.partclone.img

git clone https://github.com/Thomas-Tsai/partclone-utils.git
cd partclone-utils
sudo ./partclone.restore ../pi-boot.partclone.img ../pi-boot.raw
sudo ./partclone.restore ../pi-root.partclone.img ../pi-root.raw
cd ..

# 2. Calculate sizes
BOOT_SIZE=$(stat --format="%s" pi-boot.raw)
ROOT_SIZE=$(stat --format="%s" pi-root.raw)
IMG_SIZE=$(( BOOT_SIZE + ROOT_SIZE + 10*1024*1024 ))  # Add 10MB for partition table/slack

# 3. Create blank image
dd if=/dev/zero of=raspi-minimal.img bs=1 count=0 seek=$IMG_SIZE

# 4. Attach loop device
LOOPDEV=$(sudo losetup -f --show raspi-minimal.img)

# 5. Partition image (interactive, or use sfdisk for automation)
echo "Partition the image to match your boot and root sizes using fdisk or parted, then press Enter."
read

# 6. Refresh loop partitions
sudo partprobe "$LOOPDEV"

# 7. Write raw partition images
sudo dd if=pi-boot.raw of=${LOOPDEV}p1 bs=4M status=progress
sudo dd if=pi-root.raw of=${LOOPDEV}p2 bs=4M status=progress

# 8. Detach loop device
sudo losetup -d "$LOOPDEV"