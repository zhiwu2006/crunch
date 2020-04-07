ret=0
cat >/system/usr/sbin/chromeos-update <<UPDATE
#!/bin/bash
if ( ! test -z {,} ); then echo "Must be ran with \"bash\""; exit 1; fi
if [ \$(whoami) != "root" ]; then echo "Please run with this script with sudo"; exit 1; fi

usage()
{
	echo ""
	echo "Crunch updater: update chromeos or crunch in the running environment."
	echo "Usage: chromeos-update -f (Crunch release archive) -r (ChromeOS recovery image)"
	echo "-f (Crunch release archive), --framework (Crunch release archive)"
	echo "-r (ChromeOS recovery image), --recovery (ChromeOS recovery image)"
	echo "-h, --help					Display this menu"
}

while [ \$# -gt 0 ]; do
	case "\$1" in
		-r | --recovery)
		shift
		if [ ! -f "\$1" ]; then echo "Chromeos recovery image \$1 not found"; exit 1; fi
		if [ \$(cgpt show -i 12 -b "\$1") -eq 0 ] || [ \$(cgpt show -i 13 -b "\$1") -gt 0 ] || [ ! \$(cgpt show -i 3 -l "\$1") == 'ROOT-A' ]; then
			echo "\$1 is not a valid Chromeos image"
			exit 1
		fi
		recovery="\$1"
		;;
		-f | --framework)
		shift
		if [ ! -f "\$1" ]; then echo "Crunch release archive not found"; exit 1; fi
		tar -tf "\$1" | grep rootc.img
		if [ ! "\$?" -eq 0 ]; then
			echo "\$1 is not a valid Crunch release archive"
			exit 1
		fi
		framework="\$1"
		;;
		-h | --help)
		usage
		 ;;
		*)
		echo "\$1 argument is not valid"
		usage
		exit 1
	esac
	shift
done

destination=\$(rootdev -d)
if (expr match "\$destination" ".*[0-9]\$" >/dev/null); then
	partition="\$destination"p
else
	partition="\$destination"
fi

if [[ ! -z \$framework ]]; then
	tar zxvf "\$framework" -C ~ rootc.img
	pv ~/rootc.img > "\$partition"7
	rm ~/rootc.img
	echo "Crunch updated."
fi

if [[ ! -z \$recovery ]]; then
	loopdevice=\$(losetup --show -fP "\$recovery")
	pv "\$loopdevice"p4 > "\$partition"4
	pv "\$loopdevice"p3 > "\$partition"5
	losetup -d "\$loopdevice"
	mkdir -p /tmp/tmpupdate
	mount "\$partition"7 /tmp/tmpupdate
	vbutil_kernel --get-vmlinuz "\$partition"4 --vmlinuz-out /tmp/tmpupdate/kernel
	mkdir -p /tmp/tmpupdate/initramfs
	gunzip -c /tmp/tmpupdate/initramfs.img > /tmp/tmpupdate/initramfs/initramfs.cpio
	rm /tmp/tmpupdate/initramfs.img
	(cd /tmp/tmpupdate/initramfs && bsdcpio -i < initramfs.cpio)
	rm /tmp/tmpupdate/initramfs/initramfs.cpio
	mkdir -p /tmp/tmpupdate/tmp
	mount -o,ro "\$partition"5 /tmp/tmpupdate/tmp
	rm -r /tmp/tmpupdate/initramfs/lib/*
	cp -r /tmp/tmpupdate/tmp/lib/firmware /tmp/tmpupdate/initramfs/lib/
	umount /tmp/tmpupdate/tmp
	rm -r /tmp/tmpupdate/tmp
	(cd /tmp/tmpupdate/initramfs && find . | bsdcpio -o -H newc | gzip > /tmp/tmpupdate/initramfs.img)
	rm -r /tmp/tmpupdate/initramfs
	umount /tmp/tmpupdate
	rm -r /tmp/tmpupdate
	cgpt add -i 2 -S 0 -T 15 -P 0 "\$destination"
	cgpt add -i 4 -S 0 -T 15 -P 15 "\$destination"
	echo "ChromeOS updated."
fi
UPDATE
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 0))); fi
chmod 0755 /system/usr/sbin/chromeos-update
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 1))); fi
exit $ret
