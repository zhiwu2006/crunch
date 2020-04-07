#!/bin/bash
if ( ! test -z {,} ); then echo "Must be ran with \"sudo bash\""; exit 1; fi
if [ $(whoami) != "root" ]; then echo "Please run with sudo"; exit 1; fi
if [ -z $(which cgpt) ]; then echo "The cgpt package/binary has to be installed first"; exit 1; fi
if [ ! -f "$1" ]; then echo "Chromeos recovery image $1 not found"; exit 1; fi
if [ ! $(file -b "$1" | head -c3) == 'DOS' ] || [ $(cgpt show -i 12 -b "$1") -eq 0 ] || [ $(cgpt show -i 13 -b "$1") -gt 0 ] || [ ! $(cgpt show -i 3 -l "$1") == 'ROOT-A' ]; then echo "$source is not a valid Chromeos image"; fi

if mountpoint -q ./chroot/dev; then umount ./chroot/dev; fi
if mountpoint -q ./chroot/sys; then umount ./chroot/sys; fi
if mountpoint -q ./chroot/proc; then umount ./chroot/proc; fi
if mountpoint -q ./chroot/out; then umount ./chroot/out; fi
if [ -d ./chroot ]; then rm -r ./chroot; fi
if [ -d ./out ]; then rm -r ./out; fi

mkdir -p ./chroot/out ./out
chmod 0777 ./out

recovery_image=$(losetup --show -fP "$1")
mount -o ro "$recovery_image"p3 ./out
cp -a ./out/* ./chroot/
umount ./out
mkdir ./chroot/home/chronos/image
dd if="$recovery_image"p12 of=./chroot/home/chronos/image/efi.img bs=1M
cp -r ./efi-mods ./chroot/home/chronos/image/
chown -R 1000:1000 ./chroot/home/chronos/image
sudo losetup -d "$recovery_image"

chmod 0777 ./chroot/home/chronos
rm ./chroot/etc/resolv.conf
echo 'nameserver 8.8.4.4' > ./chroot/etc/resolv.conf
echo 'chronos ALL=(ALL) NOPASSWD: ALL' > ./chroot/etc/sudoers.d/95_cros_base

mkdir -p ./chroot/home/chronos/initramfs
cp ./scripts/crunch-init ./chroot/home/chronos/initramfs/init
chmod 0755 ./chroot/home/chronos/initramfs/init
chown -R 1000:1000 ./chroot/home/chronos/initramfs

mkdir  ./chroot/home/chronos/rootc
cp -r ./patches ./chroot/home/chronos/rootc/
chmod -R 0755 ./chroot/home/chronos/rootc/patches
chown -R 1000:1000 ./chroot/home/chronos/rootc

mkdir ./chroot/home/chronos/crunch
cp ./scripts/chromeos-install.sh ./chroot/home/chronos/crunch/
chmod 0755 ./chroot/home/chronos/crunch/chromeos-install.sh
chown -R 1000:1000 ./chroot/home/chronos/crunch

mount --bind ./out ./chroot/out
mount -t proc none ./chroot/proc
mount -t sysfs none ./chroot/sys
mount -t devtmpfs none ./chroot/dev

cp ./scripts/build-init ./chroot/init
chroot --userspec=1000:1000 ./chroot /init

umount ./chroot/dev
umount ./chroot/sys
umount ./chroot/proc
umount ./chroot/out
rm -r ./chroot
