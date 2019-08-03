#!/bin/bash
#
# Simple script for builing zip file
#

# get kernel.conf for id and version information
source ./kernel.conf

# Setup file zip name
zipname=bootwitch-${kernelid// }-$kernelver.zip

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
