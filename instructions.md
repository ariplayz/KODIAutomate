sudo dd if=/dev/zero of=LIBREELEC.img bs=1M count=10000
sudo losetup -fP LIBREELEC.img
losetup -a    # Find the /dev/loopX assigned to your image
sudo fdisk /dev/loop0 # Replace loop0 with the correct loop device
# Create partitions to match your SD card (usually a small FAT32 boot and a larger ext4 root)
sudo mkfs.vfat /dev/loop0p1 # replace these with the correct partition/loop numbers
sudo mkfs.ext4 /dev/loop0p2
sudo partclone.fat32 -r -s pi-boot.partclone.img -o /dev/loop0p1 # USE YOUR EXISTING SEPARATE PARTITION IMAGES
sudo partclone.ext4  -r -s pi-root.partclone.img -o /dev/loop0p2 # USE YOUR EXISTING SEPARATE PARTITION IMAGES

sudo losetup -d /dev/loop0 # Detach the loop device