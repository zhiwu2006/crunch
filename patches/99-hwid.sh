ret=0
cat >/system/etc/init/hwid.conf <<GENERATEHWID
start on stopped udev-trigger

script
	mkdir -p /tmp/chromeos_acpi
	product_name="\$(cat /sys/class/dmi/id/product_name | tr a-z A-Z)"
	case "\$product_name" in
		"RAMMUS")
			product_name="SHYVANA"
	esac
	echo "\$product_name B2B-B2B-B2B-B2B-B2B-B2B" > /tmp/chromeos_acpi/HWID
	mount -o bind /tmp/chromeos_acpi/ /sys/bus/platform/devices/chromeos_acpi/
end script
GENERATEHWID
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 0))); fi
exit $ret
