ret=0

cp /system/bin/chroot /system/bin/chroot.orig
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 0))); fi

cat >/system/bin/chroot <<CHROOT
#!/bin/bash
if [ "\$EUID" -eq 0 ] && [ "\$1" == "." ] && [ "\$2" == "/usr/bin/cros_installer" ]; then
destination=\$(rootdev -d)
if (expr match "\$destination" ".*[0-9]\$" >/dev/null); then
	partition="\$destination"p
else
	partition="\$destination"
fi
mkdir -p /tmp/tmpupdate
mount "\$partition"7 /tmp/tmpupdate
vbutil_kernel --get-vmlinuz "\$partition"4 --vmlinuz-out /tmp/tmpupdate/kernel
mkdir -p /tmp/tmpupdate/initramfs
gunzip -c /tmp/tmpupdate/initramfs.img > /tmp/tmpupdate/initramfs/initramfs.cpio
rm /tmp/tmpupdate/initramfs.img
(cd /tmp/tmpupdate/initramfs && bsdcpio -i < initramfs.cpio)
rm /tmp/tmpupdate/initramfs/initramfs.cpio
rm -r /tmp/tmpupdate/initramfs/lib/*
cp -a ./lib/firmware /tmp/tmpupdate/initramfs/lib/
(cd /tmp/tmpupdate/initramfs && find . | bsdcpio -o -H newc | gzip > /tmp/tmpupdate/initramfs.img)
rm -r /tmp/tmpupdate/initramfs
umount /tmp/tmpupdate
rm -r /tmp/tmpupdate
else
chroot.orig "\$@"
fi
CHROOT
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 1))); fi

touch /system/.nodelta
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 2))); fi

exit $ret
