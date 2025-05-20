---

## Overview

1. **Extract minimal raw images of each partition (using partclone + partclone-utils).**
2. **Create a blank disk image with a matching partition table.**
3. **Copy the minimal-size partition images into the correct places in the blank disk image using dd.**
4. **Result:** You get a complete `.img` file, as small as possible, that can be flashed directly to an SD card.

---

## Step-by-Step Guide

### 1. Extract Minimal Partition Images

Suppose your SD card is `/dev/sdX` with `/dev/sdX1` (boot, FAT32) and `/dev/sdX2` (root, ext4):

```sh
# Clone each partition
sudo partclone.fat32 -c -s /dev/sdX1 -o pi-boot.partclone.img
sudo partclone.ext4  -c -s /dev/sdX2 -o pi-root.partclone.img

# Convert to minimal-size raw images
git clone https://github.com/Thomas-Tsai/partclone-utils.git
cd partclone-utils
sudo ./partclone.restore ../pi-boot.partclone.img ../pi-boot.raw
sudo ./partclone.restore ../pi-root.partclone.img ../pi-root.raw
cd ..
```

Now you have `pi-boot.raw` and `pi-root.raw`, each only as big as the actual data.

---

### 2. Create a Blank Disk Image

Calculate required size:  
- Add up the size of `pi-boot.raw`, `pi-root.raw`, and some extra (1–2MB for partition table and alignment).

Example (assuming 256MB boot, 4GB root):

```sh
IMG_SIZE=$(( (256 + 4096 + 2) * 1024 * 1024 ))  # in bytes
dd if=/dev/zero of=raspi-minimal.img bs=1 count=0 seek=$IMG_SIZE
```

Or, more safely, just round up to the next GB.

---

### 3. Create Partition Table in the Blank Image

Attach as a loop device:

```sh
sudo losetup -fP raspi-minimal.img
losetup -a   # Find /dev/loopX assigned
```

Suppose `/dev/loop0`.

Use `fdisk` or `parted` to create partitions matching the size of your `.raw` images (boot first, then root):

```sh
sudo fdisk /dev/loop0
# n (new), p (primary), 1, Enter (default start), +256M, t, c (FAT32 LBA)
# n, p, 2, Enter, Enter (use rest of disk)
# w (write)
```

This will create `/dev/loop0p1` and `/dev/loop0p2` (sometimes `/dev/mapper/loop0p1`, check with lsblk).

---

### 4. Write the Minimal Partition Images into the Image

```sh
sudo dd if=pi-boot.raw of=/dev/loop0p1 bs=4M status=progress
sudo dd if=pi-root.raw of=/dev/loop0p2 bs=4M status=progress
```

---

### 5. Detach Loop Device

```sh
sudo losetup -d /dev/loop0
```

---

### 6. (Optional) Shrink the Final Image

If the image file is bigger than needed (i.e., has unused space at the end), you can shrink it with truncate:

```sh
END=$(parted raspi-minimal.img --script unit B print | grep -Eo '[0-9]+B' | tail -1 | sed 's/B//')
truncate -s $END raspi-minimal.img
```

---

## Result

You now have a minimal-size, restorable disk image (`raspi-minimal.img`) that contains only the used data from each partition, and can be flashed directly to an SD card.

---

## Bash Script Example

```bash name=make_minimal_rpi_img.sh
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
```

---

**You now have a minimal, restorable, flashable `.img` of your Raspberry Pi SD card—with no wasted space!**

Let me know if you want a fully automated version or help with partition automation!
