#!/system/bin/sh

trap 'nukeself $?' EXIT
selfpath=$(realpath $0)

kwrite(){
  echo $1 2>&1 >/dev/kmsg;
}

write(){
  echo $2 > $1
  [[ "$?" == "1" ]] && { kwrite "okita: failed to set $1 to $2"; }
}

nukeself(){
  if [[ "$1" == "5" ]];then
    kwrite "okita: launching self-destroy mechanism"
    grep 'nukeself' $selfpath 2>&1 /dev/null && rm "$selfpath"
  fi
}

if ! grep 'okita' /proc/version 2>&1 /dev/null; then
  kwrite "okita: unknown kernel, exit with crying."
  exit 5
fi

magiskpolicy --live "allow * vendor_camera_prop file { read open getattr map }"
magiskpolicy --live "allow * camera_prop file { read open getattr map }"
magiskpolicy --live "allow * hal_fingerprint_hwservice hwservice_manager { find }"

for i in 0 6; do
  write /sys/module/lpm_levels/L3/cpu$i/ret/idle_enabled N
	write /sys/devices/system/cpu/cpufreq/policy$i/scaling_governor schedutil
done

# proper setup manual SchedTune for DynSchedTune boost later
# background
write /dev/stune/background/schedtune.sched_boost_enabled 0
write /dev/stune/background/schedtune.sched_boost_no_override 1
# top-app
write /dev/stune/top-app/schedtune.sched_boost_enabled 1
write /dev/stune/top-app/schedtune.sched_boost_no_override 0

write /proc/sys/vm/dirty_ratio 60
write /proc/sys/vm/dirty_background_ratio 6
write /proc/sys/vm/page-cluster 3
write /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk 0

write /sys/block/sda/queue/read_ahead_kb 256
write /sys/block/sdf/queue/read_ahead_kb 128

write /proc/sys/kernel/random/read_wakeup_threshold 64
write /proc/sys/kernel/random/write_wakeup_threshold 128

# reduce debugging
write /sys/module/printk/parameters/console_suspend 1
for i in $(find /sys/module/ -type f -iname debug_mask); do
	write $i 0;
done

sleep 10

stop cnss_diag
stop tcpdump
pkill -9 cnss_diag
pkill -9 tcpdump
kill -9 cnss_diag
kill -9 tcpdump

exit 0