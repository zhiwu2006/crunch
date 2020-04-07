ret=0
cat >/system/lib/udev/rules.d/99-hdd_fix.rules <<HDDFIX
ACTION=="add", SUBSYSTEMS=="block", ATTRS{removable}=="0", ENV{UDISKS_PRESENTATION_HIDE}="1"
ACTION=="add", SUBSYSTEMS=="usb", ENV{UDISKS_PRESENTATION_HIDE}="0"
ACTION=="add", SUBSYSTEMS=="mmc", ATTRS{type}!="MMC", ENV{UDISKS_PRESENTATION_HIDE}="0"
HDDFIX
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 0))); fi
exit $ret
