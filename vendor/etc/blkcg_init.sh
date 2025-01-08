#!/system/bin/sh
# Smart IO related.
# Copyright © Honor Device Co., Ltd. 2016-2019. All rights reserved.

set -e
KBG_MAXINFLIGHT="$1"
BG_MAXINFLIGHT="$2"

USERDATADIR="/data"
BLKROOT="/dev/blkio"

TOPAPP="$BLKROOT/top-app"
FGDIR="$BLKROOT/foreground"
BGDIR="$BLKROOT/background"
KBGDIR="$BLKROOT/key-background"
SBGDIR="$BLKROOT/system-background"

USERDEVID=$(mountpoint -d "$USERDATADIR")

configure_read_ahead_kb_values()
{
	MemTotalStr=`cat /proc/meminfo | grep MemTotal`
	MemTotal=${MemTotalStr:16:8}

	# Set 128 for <= 4GB &
	# set 512 for >= 5GB targets.
	if [ $MemTotal -le 4194304 ]; then
		ra_kb=128
	else
		ra_kb=512
	fi

	dmptsNames=$(ls /sys/block/*/dm/name | grep -e dm)
	kbStr="queue/read_ahead_kb"
	for dmName in $dmptsNames; do
		dmNameBeginStr=${dmName%%dm/name*}
		dm=$dmNameBeginStr$kbStr
		dmNameValue=`cat $dmName`
		if [ ! -f $dm ];then
			echo "$dmNameValue device path:$dm is not exist,break!"
		elif [ "$dmNameBeginStr" = "/sys/block/dm-2/" ]; then
			echo "jump dm-2"
		elif [ "$dmNameValue" = "userdata" ]; then
			echo $ra_kb > $dm
		else
			echo 128 > $dm
		fi
	done
	echo 128 > "/sys/block/dm-2/queue/read_ahead_kb"

}
configure_read_ahead_kb_values

if [ -z "$USERDEVID" ]; then
	echo "Get userdata devid failed"
	exit 1
fi

SYSUSERDEV="/sys/dev/block/$USERDEVID/partition"
if [ -f "$SYSUSERDEV" ]; then
	SYSDEV=$(readlink -f /sys/dev/block/"$USERDEVID")
	SYSDEV=$(dirname "$SYSDEV")

	if [ -z "$SYSDEV" ]; then
		echo "Get device failed"
		exit 1
	fi

	USERDEVID=$(cat "$SYSDEV"/dev)
	if [ -z "$USERDEVID" ]; then
		echo "Get device id failed"
		exit 1
	fi
fi

echo "$USERDEVID 3" > "$BLKROOT"/blkio.throttle.mode_device
if [ $? -ne 0 ]; then
	echo "open iops weight control failed"
	exit 1
fi

echo "$USERDEVID 32" > "$BLKROOT"/blkio.throttle.iops_slice_device
if [ $? -ne 0 ]; then
	echo "set iops slice failed"
	exit 1
fi


set_weight()
{
	local cgrp_name="$1"
	local cgrp="$2"
	local value="$3"

	echo "$USERDEVID $value" > "$cgrp"/blkio.throttle.weight_device
	if [ $? -ne 0 ]; then
		echo "set $cgrp_name weight failed"
	fi
}

set_weight "top-app" "$TOPAPP" 800
set_weight "fg" "$FGDIR" 800
set_weight "sbg" "$SBGDIR" 400
set_weight "kbg" "$KBGDIR" 400
set_weight "bg" "$BGDIR" 100

set_cgroup_type()
{
	local cgrp_name="$1"
	local cgrp="$2"
	local value="$3"

	echo "$value" > "$cgrp"/blkio.throttle.type
	if [ $? -ne 0 ]; then
		echo "set $cgrp_name type failed"
	fi
}

set_cgroup_type "top-app" "$TOPAPP" 0
set_cgroup_type "fg" "$FGDIR" 1
set_cgroup_type "kbg" "$KBGDIR" 2
set_cgroup_type "sbg" "$SBGDIR" 3
set_cgroup_type "bg" "$BGDIR" 4



set_max_inflights()
{
	local cgrp_name="$1"
	local cgrp="$2"
	local value="$3"

	echo "$value" > "$cgrp"/blkio.throttle.max_inflights
	if [ $? -ne 0 ]; then
		echo "set $cgrp_name max inflight failed"
	fi
}

echo "$USERDEVID 1" > "$BLKROOT"/blkio.throttle.enable_max_inflights_device
set_max_inflights "kbg" "$KBGDIR" "$KBG_MAXINFLIGHT"
set_max_inflights "bg" "$BGDIR" "$BG_MAXINFLIGHT"
