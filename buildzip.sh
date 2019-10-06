#!/bin/bash
#
# Simple script for builing zip file
#
SELFPATH=$(dirname $(realpath $0))

# KBUILD_OUT, used to get kernel, dtbo file, and version directly from it
[[ -f "$KBUILD_OUT/.config" ]] || { echo "missing $KBUILD_OUT. exiting"; exit 1; }

# replace kernel version with actual version
generatedver=$(cat $KBUILD_OUT/include/generated/utsrelease.h | cut -d\" -f2 | cut -d\- -f3)
sed -i -e "s/kernelver=.*/kernelver=\"$generatedver\"/g" $SELFPATH/kernel.conf

[[ -f "$SELFPATH/kernel.conf" ]] || { echo "kernel.conf cannot be found. exiting"; exit 1; }
# get kernel.conf for id and version information
source $SELFPATH/kernel.conf

# replace kernel and dtbo path directly from KBUILD_OUT
src_kernel=$KBUILD_OUT/arch/arm64/boot/$src_kernel
src_dtbo=$KBUILD_OUT/$src_dtbo

# Requirement checking
[[ -f "$SELFPATH/external/magiskboot" ]] || { echo "./external/magiskboot cannot be found. exiting"; exit 1; }
[[ -f "$src_kernel" ]] || { echo "src_kernel ($src_kernel) cannot be found. exiting"; exit 1; }
[[ "$kernelid" ]] || { echo "kernelid cannot be found. exiting"; exit 1; }
[[ "$kernelver" ]] || { echo "kernelver cannot be found. exiting"; exit 1; }

# Setup file zip name
zipname=${kernelid// /-}-$kernelver-Mi9SE.zip

# Setup folder and files that will be included in the zip
sources=($SELFPATH/META-INF
         $SELFPATH/external
         $SELFPATH/addons
         $SELFPATH/kernel.conf
         $src_kernel)

if [[ "$with_dtbo" == "true" ]]; then
  sources+=($src_dtbo)
fi

if [[ "$banner_mode" == "custom" ]]; then
  sources+=($SELFPATH/banner.txt)
fi

# prepare working directory in the /tmp
WORKDIR=/tmp/build-bootwitch-$USER
rm -rf $WORKDIR
mkdir $WORKDIR

# copy needed files
for file in "${sources[@]}"; do
    (test -f $file || test -d $file) && cp -afv $file $WORKDIR/
done

# creating zip file
command pushd "$WORKDIR" > /dev/null
    zip -r9 --exclude=*placeholder $WORKDIR/$zipname *
command popd > /dev/null

# copy generated zip file to bootwitch dir
cp -v $WORKDIR/$zipname $SELFPATH/

# cleanup working directory
rm -rf $WORKDIR

# send it to my device
command -v adb >/dev/null 2>&1 || exit 0
if [[ "$(adb get-state)" != "offline" ]]; then
    read -p ":: Push $zipname to /sdcard/ ? (y/n) > " ASKPUSH
    [[ $ASKPUSH =~ ^[Yy]$ ]] && adb push $SELFPATH/$zipname /sdcard/
fi
if [[ "$(adb get-state)" == "device" ]]; then
    read -p ":: Reboot to recovery ? (y/n) > " ASKREC
    [[ $ASKREC =~ ^[Yy]$ ]] && echo "rebooting to recovery..." && adb reboot recovery
fi
