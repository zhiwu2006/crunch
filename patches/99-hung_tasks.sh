ret=0

cat >/system/etc/init/hung-tasks.conf <<HUNGTASKS
start on stopped udev-trigger

script
	echo 0 > /proc/sys/kernel/hung_task_timeout_secs
end script
HUNGTASKS
if [ ! "$?" -eq 0 ]; then ret=$((ret + (2 ** 0))); fi

exit $ret
