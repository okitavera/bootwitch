#!/system/bin/sh
# Environment Setup Script for Okitavera

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

if ! grep 'okita' /proc/sys/kernel/osrelease 2>&1 /dev/null; then
  kwrite "okita: unknown kernel, exit with crying."
  exit 5
fi

# Hax sepolicy for broken custom ROM
magiskpolicy --live "allow * vendor_camera_prop file { read open getattr map }"
magiskpolicy --live "allow * camera_prop file { read open getattr map }"
magiskpolicy --live "allow * hal_fingerprint_hwservice hwservice_manager { find }"

# Setup proper permission for DC-dimming knob
chmod 600 /sys/devices/platform/soc/soc:qcom,dsi-display@18/msm_fb_ea_enable
chown system:system /sys/devices/platform/soc/soc:qcom,dsi-display@18/msm_fb_ea_enable

# wait until boot is complete
while true; do 
  if [[ "$(getprop sys.boot_completed)" == "1" ]]; then
    break
  else
    sleep 1
  fi
done

# Disable CPU Retention
write /sys/module/lpm_levels/L3/cpu0/ret/idle_enabled N
write /sys/module/lpm_levels/L3/cpu6/ret/idle_enabled N

# Reset to schedutil
write /sys/devices/system/cpu/cpufreq/policy0/scaling_governor schedutil
write /sys/devices/system/cpu/cpufreq/policy6/scaling_governor schedutil

# Mimick Pixel ratelimits
write /sys/devices/system/cpu/cpufreq/policy0/schedutil/up_rate_limit_us 500
write /sys/devices/system/cpu/cpufreq/policy0/schedutil/down_rate_limit_us 20000
write /sys/devices/system/cpu/cpufreq/policy6/schedutil/up_rate_limit_us 500
write /sys/devices/system/cpu/cpufreq/policy6/schedutil/down_rate_limit_us 20000

# Set the default IRQ affinity to the silver cluster.
write /proc/irq/default_smp_affinity 3f

# Setup cpuset
write /dev/cpuset/top-app/cpus 0-7
write /dev/cpuset/camera-daemon/cpus 0-7
write /dev/cpuset/foreground/cpus 0-5,7
write /dev/cpuset/background/cpus 4-5
write /dev/cpuset/system-background/cpus 2-5
write /dev/cpuset/restricted/cpus 2-5

# Turn on sleep modes.
write /sys/module/lpm_levels/parameters/sleep_disabled 0

# Enable idle state listener
write /sys/class/drm/card0/device/idle_encoder_mask 1
write /sys/class/drm/card0/device/idle_timeout_ms 64

# Prepare SchedTune
## rt
write /dev/stune/rt/schedtune.boost 0 
write /dev/stune/rt/schedtune.sched_boost 0 
write /dev/stune/rt/schedtune.sched_boost_enabled 1 
write /dev/stune/rt/schedtune.sched_boost_no_override 0 
write /dev/stune/rt/schedtune.colocate 0 
write /dev/stune/rt/schedtune.prefer_idle 0
## foreground
write /dev/stune/foreground/schedtune.boost 0 
write /dev/stune/foreground/schedtune.sched_boost 0 
write /dev/stune/foreground/schedtune.sched_boost_enabled 1 
write /dev/stune/foreground/schedtune.sched_boost_no_override 1 
write /dev/stune/foreground/schedtune.colocate 0 
write /dev/stune/foreground/schedtune.prefer_idle 1
## background
write /dev/stune/background/schedtune.boost 0 
write /dev/stune/background/schedtune.sched_boost 0 
write /dev/stune/background/schedtune.sched_boost_enabled 0 
write /dev/stune/background/schedtune.sched_boost_no_override 1 
write /dev/stune/background/schedtune.colocate 0 
write /dev/stune/background/schedtune.prefer_idle 0
## top-app
write /dev/stune/top-app/schedtune.boost 0
write /dev/stune/top-app/schedtune.sched_boost 0 
write /dev/stune/top-app/schedtune.sched_boost_enabled 1 
write /dev/stune/top-app/schedtune.sched_boost_no_override 0 
write /dev/stune/top-app/schedtune.colocate 1 
write /dev/stune/top-app/schedtune.prefer_idle 0
## global
write /dev/stune/schedtune.boost 0 
write /dev/stune/schedtune.sched_boost 0 
write /dev/stune/schedtune.sched_boost_enabled 1 
write /dev/stune/schedtune.sched_boost_no_override 0 
write /dev/stune/schedtune.colocate 0 
write /dev/stune/schedtune.prefer_idle 0

# Setup Dynamic SchedTune
write /sys/module/cpu_input_boost/parameters/dynamic_stune_boost 20

# Setup Memory Management
write /proc/sys/vm/dirty_ratio 80
write /proc/sys/vm/dirty_expire_centisecs 3000
write /proc/sys/vm/dirty_background_ratio 8
write /proc/sys/vm/page-cluster 0
write /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk 0

# Reset default thermal config
tmsc=/sys/class/thermal/thermal_message/sconfig
chmod 644 /sys/class/thermal/thermal_message/sconfig
write /sys/class/thermal/thermal_message/sconfig 16
chmod 444 /sys/class/thermal/thermal_message/sconfig

# Reset io readahead
write /sys/block/sda/queue/read_ahead_kb 256
write /sys/block/sdf/queue/read_ahead_kb 128

# Reset entropy values
write /proc/sys/kernel/random/read_wakeup_threshold 64
write /proc/sys/kernel/random/write_wakeup_threshold 128

# Setup final blkio
write /dev/blkio/blkio.weight 1000
write /dev/blkio/background/blkio.weight 10
write /dev/blkio/bg/blkio.weight 10

# reduce debugging
write /sys/module/printk/parameters/console_suspend 1
for i in $(find /sys/module/ -type f -iname debug_mask); do
	write $i 0;
done

exit 0
