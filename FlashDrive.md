Absolutely, this is a common goal:  
**Write a minimal, shrunken Raspberry Pi image to a new SD card or drive, but expand the root partition to fill all the remaining space.**

Below is the step-by-step workflow:

---

## 1. Flash the Shrunk Image to the New Drive

Suppose your image is `raspi-minimal.img` and your target drive is `/dev/sdY` (be 100% sure this is correct, as it will be erased!):

```sh
sudo dd if=raspi-minimal.img of=/dev/sdY bs=4M status=progress
sync
```
- This will copy the small image (with both partitions) to the start of the drive.

---

## 2. Reload Partition Table

After `dd` finishes, either reboot or use:
```sh
sudo partprobe /dev/sdY
```
or
```sh
sudo blockdev --rereadpt /dev/sdY
```
This makes the new partitions visible to the OS.

---

## 3. Expand the Root Partition

Suppose the root partition is `/dev/sdY2` (check with `lsblk`).

**With `gparted` (easiest):**
1. Run: `sudo gparted /dev/sdY`
2. Right-click the root partition (usually the second one), choose “Resize/Move”.
3. Drag to fill all available space, apply changes.

**With `parted` or `fdisk` (command line, example for EXT4 root on partition 2):**
1. Delete the root partition (don’t worry, no data is lost if you don’t format!).
2. Re-create it starting at the SAME sector, but let it extend to the end of the disk.

Example:
```sh
sudo fdisk /dev/sdY
# d (delete), 2 (partition 2)
# n (new), p (primary), 2, [default start sector], [default end sector]
# w (write)
```
- This only updates the partition table, not the data!

---

## 4. Resize the Filesystem to Fill New Partition

Suppose root is `/dev/sdY2` and it’s **ext4**:

```sh
sudo e2fsck -f /dev/sdY2
sudo resize2fs /dev/sdY2
```

If it’s **f2fs** or other, use the matching resize tool.

---

## 5. Done!

You now have:
- The boot partition as before.
- The root partition expanded to fill the entire drive, with all your data intact.

---

## **Summary Script**

```bash
# 1. Write image (WARNING: will erase target drive!)
sudo dd if=raspi-minimal.img of=/dev/sdY bs=4M status=progress
sync

# 2. Reload partition table
sudo partprobe /dev/sdY

# 3. Expand root partition (use gparted or fdisk as above)

# 4. Resize filesystem
sudo e2fsck -f /dev/sdY2
sudo resize2fs /dev/sdY2
```

---

**Let me know if you want a more automated script, or if you need step-by-step screenshots for `gparted`!**  
**Double-check device names to avoid overwriting other drives!**
