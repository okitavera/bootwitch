#!/bin/bash
#
# Simple script for builing zip file
#

# KBUILD_OUT, used to get kernel, dtbo file, and version directly from it
[[ -f "$KBUILD_OUT/.config" ]] || { echo "missing $KBUILD_OUT. exiting"; exit 1; }

# replace kernel version with actual version
generatedver=$(cat $KBUILD_OUT/include/generated/utsrelease.h | cut -d\" -f2 | cut -d\- -f3)
sed -i -e "s/kernelver=.*/kernelver=$generatedver/g" ./kernel.conf

[[ -f "./kernel.conf" ]] || { echo "./kernel.conf cannot be found. exiting"; exit 1; }
# get kernel.conf for id and version information
source ./kernel.conf

# replace kernel and dtbo path directly from KBUILD_OUT
src_kernel=$KBUILD_OUT/arch/arm64/boot/$src_kernel
src_dtbo=$KBUILD_OUT/$src_dtbo

# Requirement checking
[[ -f "./external/magiskboot" ]] || { echo "./external/magiskboot cannot be found. exiting"; exit 1; }
[[ -f "$src_kernel" ]] || { echo "src_kernel ($src_kernel) cannot be found. exiting"; exit 1; }
[[ "$kernelid" ]] || { echo "kernelid cannot be found. exiting"; exit 1; }
[[ "$kernelver" ]] || { echo "kernelver cannot be found. exiting"; exit 1; }

# Setup file zip name
zipname=${kernelid// }-$kernelver-Mi9SE.zip

# Setup folder and files that will be included in the zip
sources=(META-INF
         external
         kernel.conf
         $src_kernel)

if [[ "$with_dtbo" == "true" ]]; then
  sources+=($src_dtbo)
fi

if [[ "$banner_mode" == "custom" ]]; then
  sources+=(banner.txt)
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

# copy generated zip file to current directory
cp -v $WORKDIR/$zipname $(pwd)/

# cleanup working directory
rm -rf $WORKDIR
