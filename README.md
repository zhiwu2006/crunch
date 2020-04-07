# Crunch framework

## Overview

First of all, thanks go to the Chromebrew framework maintainers for their work which was actively used when creating this project and to MrChromebox for its UEFI Full ROMs.

The Crunch framework purpose is to be able to boot your Chromebook's native ChromeOS build after flashing MrChromebox UEFI Full ROM firmware. Crunch will only run the official image built by google for your chromebook, if you want to install another recovery image on your chromebook, you have to use Brunch.

Crunch uses the device native ChromeOS kernel with an added initramfs, userspace patches and a specific EFI partition to boot.

**Warning: with this setup, ChromeOS is not running in a virtual machine and has therefore direct access to all your devices. As such, many bad things can happen with your device and mostly your data. Make sure you only use this framework on a device which does not contain any sensitive data and keep non-sensitive data synced with a cloud service. I cannot be held responsible for anything bad that would happen to your device, including data loss.**

## Chromebooks compatibility, know issues and added features

Chromebooks compatibility:
- x86_64 Chromebooks with MrChromebox UEFI Full ROM firmware installed.

Know issues:
- Tablet mode, accelerometer and device wake on lid opening are currently not functional.

Additional features:
- nano text editor,
- qemu (with spice support).

# Install instructions

You can install ChromeOS on a USB flash drive or as an image on an HDD for dual booting (14GB of free space needed).

## Install ChromeOS from Linux (the easiest way)

### Requirements

- root access.
- `pv`, `tar`, `cgpt` and `vbutil_kernel` packages/binaries.

### Install ChromeOS on a USB flash drive

1. Download your device ChromeOS recovery image and extract it.
2. Download the Crunch release corresponding to the ChromeOS recovery image version you have downloaded (from the GitHub release section).
3. Open a terminal, navigate to the directory containing the package.
4. Extract it: 
```
tar zxvf crunch_< version >.tar.gz
```
5. Identify your USB flash drive device name e.g. /dev/sdX (Be careful here as the installer will erase all data on the target drive)
6. Install ChromeOS on the USB flash drive:
```
sudo bash chromeos-install.sh -src < path to the ChromeOS recovery image > -dst < your USB flash drive device. e.g. /dev/sdX >
```
7. Reboot your computer and boot from the USB flash drive (refer to your computer manufacturer's online resources).

The GRUB menu should appear, select ChromeOS and after a few minutes (the Crunch framework is building itself on the first boot), you should be greeted by ChromeOS startup screen. You can now start using ChromeOS.

### Dual Boot ChromeOS from your HDD

ChromeOS partition scheme is very specific which makes it difficult to dual boot. One solution to circumvent that is to keep ChromeOS in a disk image on the hard drive and run it from there.

Make sure you have an ext4 or NTFS partition with at least 14gb of free space available and no encryption or create one (refer to online resources).

1. Perform the steps 1 to 4 as described in the previous section (Install ChromeOS on a USB flash drive).
2. Mount the unencrypted ext4 or NTFS partition on which we will create the disk image to boot from:
```
mkdir -p ~/tmpmount
sudo mount < the destination partition (ext4 or ntfs) which will contain the disk image > ~/tmpmount
```
3. Create the ChromeOS disk image:
```
sudo bash chromeos-install.sh -src < path to the ChromeOS recovery image > -dst ~/tmpmount/chromeos.img -s < size you want to give to your chromeos install in GB (system partitions will take around 10GB, the rest will be for your data) >
```
4. Copy the GRUB configuration which appears in the terminal at the end of the process (between lines with stars) to either:
- your hard disk GRUB install if you have one (refer to you distro's online resources).
- the USB flash drive GRUB config file (then boot from USB flash drive and choose "boot from disk image" in the GRUB menu),
5. Unmout the destination partition
```
sudo umount ~/tmpmount
```
6. Reboot your computer and boot to the bootloader with the modified GRUB config.

The GRUB menu should appear, select "ChromeOS (boot from disk image)" and after a few minutes (the Crunch framework is building itself on the first boot), you should be greeted by ChromeOS startup screen. You can now start using ChromeOS from your HDD.

## Install ChromeOS from Windows

### Requirements

- Administrator access.

### Install ChromeOS on a USB flash drive

1. Download your device ChromeOS recovery image and extract it.
2. Download the Crunch release corresponding to the ChromeOS recovery version you have downloaded (from the GitHub release section).
3. Install the Ubuntu WSL from the Microsoft store (refer to online resources).
4. Launch Ubuntu WSL and install pv, tar and cgpt packages:
```
sudo apt update && sudo apt install pv tar cgpt vboot-kernel-utils
```
5. Browse to your Downloads folder using `cd`:
```
cd /mnt/c/Users/< username >/Downloads/
```
6. Extract the package:
```
sudo tar zxvf crunch_< version >.tar.gz
```
7. Make sure you have at least 14gb of free space available
8. Create a ChromeOS image:
```
sudo bash chromeos-install.sh -src < path to the ChromeOS recovery image > -dst chromeos.img
```
9. Use "Rufus" (https://rufus.ie/) to write the chromeos.img to the USB flash drive.
10. Reboot your computer and boot from the USB flash drive (refer to your computer manufacturer's online resources).
11. The GRUB menu should appear, select ChromeOS and after a few minutes (the Crunch framework is building itself on the first boot), you should be greeted by ChromeOS startup screen.
At this stage, your USB flash drive is incorrectly recognized as 14GB regardless of its actual capacity. To fix this:
13. At the ChromeOS startup screen, press CTRL+ALT+F2 to go into a shell session.
14. Login as `root`
15. Execute the below command:
```
sudo resize-data
```
16. Reboot your computer when requested and boot again from USB flash drive. You can now start using ChromeOS.

### Dual Boot ChromeOS from your HDD

1. Make sure you have a NTFS partition with at least 14gb of free space available and no BitLocker encryption or create one (refer to online resources).
2. Create a ChromeOS USB flash drive using the above method (Install ChromeOS on a USB flash drive) and boot it.
3. Open the ChromeOS shell (CTRL+ALT+T and enter `shell` at the invite)
4. Mount the unencrypted ext4 or NTFS partition on which we will create the disk image to boot from:
```
mkdir -p ~/tmpmount
sudo mount < the destination partition (ext4 or ntfs) which will contain the disk image > ~/tmpmount
```
5. Create the ChromeOS disk image:
```
sudo bash chromeos-install -dst ~/tmpmount/chromeos.img -s < size you want to give to your chromeos install in GB (system partitions will take around 10GB, the rest will be for your data) >
```
6. Copy the GRUB configuration which is displayed in the terminal (select it and CTRL+SHIFT+C), run `sudo edit-grub-config`, move to line 2 and paste the text (CTRL+SHIFT+V). Save and exit.
7. Unmout the destination partition
```
sudo umount ~/tmpmount
```
8. Reboot your computer and boot from USB flash drive.

The GRUB menu should appear, select "ChromeOS (boot from disk image)" and you should be greeted by ChromeOS startup screen. You can now start using ChromeOS from your HDD.

## Install ChromeOS on HDD from ChromeOS

1. Boot your ChromeOS USB flash drive.
2. Open the ChromeOS shell (CTRL+ALT+T and enter `shell` at the invite)
3. Identify your HDD device name e.g. /dev/sdX (Be careful here as the installer will erase all data on the target drive)
4. Install ChromeOS to HDD:
```
sudo chromeos-install -dst < your HDD device. e.g. /dev/sdX >
```
5. Shutdown your computer and remove your ChromeOS USB flash drive.

Note: Even if you boot from GRUB on your HDD, if you have a ChromeOS USB flash drive inserted, the initramfs will boot from it in priority.

The GRUB menu should appear, select ChromeOS and after a few minutes (the Crunch framework is building itself on the first boot), you should be greeted by ChromeOS startup screen. You can now start using ChromeOS.

# Optional steps

## Update the Crunch framework

1. Download the Crunch release corresponding to your ChromeOS version (from the GitHub release section).
2. Open the ChromeOS shell (CTRL+ALT+T and enter `shell` at the invite)
3. Update the framework:
```
sudo chromeos-update -f < path to the Crunch release archive >
```
4. Restart ChromeOS

## Modify the GRUB bootloader

### From Windows

1. Install notepad++ (https://notepad-plus-plus.org/)
2. Look for the EFI partition in the Explorer and browse to the efi/boot folder.
3. Edit the grub.cfg file with notepad++ (warning: editing this file with standard Notepad or Wordpad will render the file unusable and prevent GRUB from booting due to formatting issues)
4. Add your specific kernel parameters at the end of the Linux line arguments.

### From Linux

1. Create a directory to mount the EFI partition:
```
mkdir /tmp/efi_part
```
2. Mount the partition 12 of your device to your EFI partition:
```
sudo mount /dev/< partition 12 of ChromeOS device > /tmp/efi_part
```
3. Edit the file /tmp/efi_part/efi/boot/grub.cfg with your favorite editor (launched as root).
4. Unmount the partition:
```
sudo umount /tmp/efi_part
```

### From ChromeOS

Run `sudo edit-grub-config`

