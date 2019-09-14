#!/bin/bash
#
# Simple script for builing zip file
#
SELFPATH=$(dirname $(realpath $0))

[[ -f "$SELFPATH/kernel.conf" ]] || { echo "kernel.conf cannot be found. exiting"; exit 1; }
# get kernel.conf for id and version information
source $SELFPATH/kernel.conf

# Requirement checking
[[ -f "$SELFPATH/external/magiskboot" ]] || { echo "external/magiskboot cannot be found. exiting"; exit 1; }
[[ -f "$SELFPATH/$src_kernel" ]] || { echo "$src_kernel cannot be found. exiting"; exit 1; }
[[ "$kernelid" ]] || { echo "kernelid cannot be found. exiting"; exit 1; }
[[ "$kernelver" ]] || { echo "kernelver cannot be found. exiting"; exit 1; }

# Setup file zip name
zipname=bootwitch-${kernelid// }-$kernelver.zip

# Setup folder and files that will be included in the zip
sources=($SELFPATH/META-INF
         $SELFPATH/external
         $SELFPATH/kernel.conf
         $SELFPATH/$src_kernel)

if [[ "$with_dtbo" == "true" ]]; then
  sources+=($SELFPATH/$src_dtbo)
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

# copy generated zip file to current directory
cp -v $WORKDIR/$zipname $SELFPATH/

# cleanup working directory
rm -rf $WORKDIR
