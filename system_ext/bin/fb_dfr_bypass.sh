#!/system/bin/sh
# Copyright (c) Honor Device Co., Ltd. 2024-2024. All rights reserved.
# Description: support close fb feature when device produce abnormal reboot count
# in MONITOR_TIME_INTERVAL_MAX more than ABNORMAL_BOOT_COUNT_THRESHOLD
# Author: maoqian 00023305
# Create: 2024-6-28

HISTORY_LOG_PATH="/log/history.log"
BYPASS_NODE_PATH="/sys/class/fb_vadj/bypass"
NEED_BYPASS_PROP="persist.fb.bypass.need"
BYPASS_NODE_CMD=2
ABNORMAL_BOOT_COUNT_THRESHOLD=4
# monitor abnormal boot count in 1 month
MONITOR_DAYS=30
SECONDS_IN_ONE_DAY=86400
MONITOR_TIME_INTERVAL_MAX=$(expr $MONITOR_DAYS \* $SECONDS_IN_ONE_DAY)

function log()
{
    echo "$1" > /dev/kmsg
    echo "$1"
}

function close_fb()
{
    log "fb_dfr_bypass: close fb"
    setprop $NEED_BYPASS_PROP true

    node_value=$(cat $BYPASS_NODE_PATH)
    if [[ $node_value -ne $BYPASS_NODE_CMD ]]; then
        log "fb_dfr_bypass: value of &BYPASS_NODE_PATH is $node_value"
    fi
}

# if need close fb, then set prop and node
prop=$(getprop $NEED_BYPASS_PROP)
log "fb_dfr_bypass: value of persist.fb.bypass.need = $prop"
if [[ $prop == true ]]; then
    close_fb
    exit 0
fi

# get abnormal boot count in MONITOR_TIME_INTERVAL_MAX
sleep 6s
count=0;
cur_date=$(date +'%Y-%m-%d')
time_stamp_cur=$(date -d "$cur_date" +%s)
cat $HISTORY_LOG_PATH | tac | while read line
do
    if [[ $line != *NORMALBOOT* ]]; then
        time=$(echo $line | grep -o "[0-9]\{14\}")
        time_format="${time:0:4}-${time:4:2}-${time:6:2}"
        time_stamp=$(date -d $time_format +%s)
        interval=$(expr $time_stamp_cur - $time_stamp)
        log "fb_dfr_bypass: interval=$interval"

        if [[ $interval -le $MONITOR_TIME_INTERVAL_MAX ]]; then
            let count++
        else
            break
        fi
    fi

    # close fb if count in MONITOR_TIME_INTERVAL_MAX more than ABNORMAL_BOOT_COUNT_THRESHOLD
    if [[ $count -ge $ABNORMAL_BOOT_COUNT_THRESHOLD ]]; then
        close_fb
        break
    fi
done

