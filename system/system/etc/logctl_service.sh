#!/system/bin/sh
#
# This file is added for restarting xlogcat_service after sleeping 20s waiting for oba file
# Copyright © Honor Device Co., Ltd. 2010-2019. All rights reserved.
#
set -e

retval_image=$(getprop ro.image)
retval_bootmode=$(getprop ro.bootmode)
retval_runmode=$(getprop ro.runmode)
if [ "$retval_image" == "bootimage" ]&&[ "$retval_bootmode" != "charger" ]&&[ "$retval_runmode" != "factory" ];then
    sleep 30
    retval_remotedebug=$(getprop persist.log.remotedebug)
    if [ "$retval_remotedebug" == "true" ];then
        exit 1
    fi
    start xlogcat_service
fi

consolelevel=`getprop ro.boot.console.level`
logcatkmsg=`getprop ro.boot.logcat.kmsg`

if [ -n "$consolelevel" ]; then
    echo "$consolelevel" > /proc/sys/kernel/printk
fi

if [ -n "$logcatkmsg" ]; then
    if [ -n "$consolelevel" ]; then
        logcatconsolelevel=$(expr $consolelevel - 1)
        echo "$consolelevel $logcatconsolelevel" > /proc/sys/kernel/printk
    else
        echo "4 3 1 7" > /proc/sys/kernel/printk
    fi
fi

exit 0
