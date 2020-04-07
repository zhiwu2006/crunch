ret=0
cat >/system/etc/init/usb-updates.conf <<USBUPDATES
start on starting boot-services

script
	device=\$(rootdev -d | sed "s#/dev/##g")
	mkdir -p /tmp/usb_updates
	echo 0 > /tmp/usb_updates/removable
	mount -o bind "/tmp/usb_updates/removable" "/sys/block/\$device/removable"
end script
USBUPDATES
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 0))); fi
exit $ret
