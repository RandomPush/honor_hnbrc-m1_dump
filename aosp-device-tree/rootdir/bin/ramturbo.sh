#!/vendor/bin/sh

memtotal=$(cat /proc/meminfo_size)
ramsize=$(expr $memtotal / 1024 / 1024 + 1)
setprop vendor.zram.ramturbo.size $ramsize
