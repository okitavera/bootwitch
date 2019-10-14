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

# Setup proper permission for DC-dimming and FOD knob
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

sleep 3

cpuA=/sys/devices/system/cpu/cpufreq/policy0
cpuB=/sys/devices/system/cpu/cpufreq/policy6

write $cpuA/scaling_min_freq 300000
write $cpuA/scaling_governor schedutil
write $cpuA/schedutil/iowait_boost_enable 0
write $cpuA/schedutil/up_rate_limit_us 1000
write $cpuA/schedutil/down_rate_limit_us 1000
write $cpuA/blu_schedutil/up_rate_limit_us 20000
write $cpuA/blu_schedutil/down_rate_limit_us 500

write $cpuB/scaling_min_freq 300000
write $cpuB/scaling_governor schedutil
write $cpuB/schedutil/iowait_boost_enable 0
write $cpuB/schedutil/up_rate_limit_us 2000
write $cpuB/schedutil/down_rate_limit_us 1000
write $cpuA/blu_schedutil/up_rate_limit_us 20000
write $cpuA/blu_schedutil/down_rate_limit_us 500

# Setup Memory Management
write /proc/sys/vm/dirty_ratio 80
write /proc/sys/vm/dirty_expire_centisecs 3000
write /proc/sys/vm/dirty_background_ratio 8
write /proc/sys/vm/page-cluster 0

# Reset default thermal config
chmod 644 /sys/class/thermal/thermal_message/sconfig
write /sys/class/thermal/thermal_message/sconfig 16
chmod 444 /sys/class/thermal/thermal_message/sconfig

# Unify all blocks setup
for i in /sys/block/*/queue; do
  write $i/read_ahead_kb 256
  write $i/add_random 0
  write $i/iostats 0
  write $i/rotational 0
  write $i/scheduler cfq
done

# Reset entropy values
write /proc/sys/kernel/random/read_wakeup_threshold 128
write /proc/sys/kernel/random/write_wakeup_threshold 128

# allow console suspend
write /sys/module/printk/parameters/console_suspend 1
