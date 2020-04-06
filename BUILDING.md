# Crunch principle

The Crunch framework purpose is to be able to boot your Chromebook's native ChromeOS build after flashing MrChromebox UEFI Full ROM firmware. Crunch will only run the official image built by google for your chromebook, if you want to install another recovery image on your chromebook, you have to use Brunch.

Thanks goes to the Chromebrew framework maintainers for their work which was actively used when creating this project and to MrChromebox for its UEFI Full ROMs.

Crunch uses the device native ChromeOS kernel with an added initramfs, userspace patches and a specific EFI partition to boot.

The source directory is composed of:
- the build.sh script used to build the framework,
- An "efi-mods" folder containing GRUB and its config,
- A script folder which contains sub-scripts used during the build process and the Crunch initramfs script,
- A patches folder which contains the patches which will be applied by the initramfs to the ChromeOS rootfs.

The build script will copy the rootfs from a ChromeOS recovery image, chroot into it, and install the Chromebrew framework in order to:
- download from git and build qemu, nano and their dependencies. (stored in ROOTC image),
- build busybox from its git and create the initramfs. (stored in ROOTC image),
- copy the install script which will be used to create the ChromeOS image (chromeos-install.sh),
- create the ROOTC partition image,
- create 2 different efi partitions ("efi_secure.img" with secure boot support and "efi_legacy.img" for older devices).

From there, to create the ChromeOS image, the install script will only have to:
- create the disk/partitions,
- copy the ChromeOS recovery image partitions to this device,
- copy the ROOTC partition which contains the framework,
- replace the EFI partition.

At boot, GRUB will load the kernel present on ROOTC partition and launch the initramfs which is responsible for adding all the userspace patches to the standard ChromeOS rootfs before booting it, this process takes place:
- on the first boot,
- when the ROOTC partition is modified,
- when an update has been applied.

# Build instructions

Building the framework is currently only possible under Linux (should work with any distro).

The build process consist of 2 successive steps:
- getting the source,
- building the install package.

Warning: The build scripts currently lacks many build process checks. I will try to work on that as soon as I have the time.

## Getting the source

Clone the branch you want to use (usually the latest) and enter the source directory:

```
git clone https://github.com/sebanc/crunch.git -b < ChromeOS version e.g. r79 >
cd crunch
```

## Building the release package.

To build the release package, you need to have:
- root access,
- the `pv` and `cgpt` packages/binaries installed,
- 16 GB free disk space available,
- an internet connection.

1. Download your device official recovery image from here (https://cros-updates-serving.appspot.com/).

2. Make sure you have 16GB of free space available for the build.

3. Launch the build as root:
```
sudo bash build.sh < path to the ChromeOS recovery image >
```
4. Verify that everything worked well. You should have an "out" directory containing 2 tar.gz files:
- crunch_< version >.tar.gz which contains the crunch package.
- sources_< version >.tar.gz which contains the sources that were used for building binaries inside the chroot (only for backup/history purpose).

