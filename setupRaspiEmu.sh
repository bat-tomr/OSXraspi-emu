#!/bin/sh

#  MacOS Mojave

brew install qemu

export QEMU=$(which qemu-system-arm)
export TMP_DIR=./qemu-rpi

export RPI_KERNEL=kernel-qemu-4.14.79-stretch
export RPI_FS=2018-11-13-raspbian-stretch-lite.img
export PTB_FILE=versatile-pb.dtb
export IMAGE_FILE=2018-11-13-raspbian-stretch-lite.zip
export IMAGE=http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2018-11-15/${IMAGE_FILE}
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/Cellar/libffi/3.2.1/lib

mkdir -p $TMP_DIR; cd $TMP_DIR

wget -nc https://github.com/dhruvvyas90/qemu-rpi-kernel/blob/master/kernel-qemu-4.14.79-stretch?raw=true \
	    -O ${RPI_KERNEL}

wget -nc https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/versatile-pb.dtb \
	    -O ${PTB_FILE}

wget -nc $IMAGE
unzip -n $IMAGE_FILE

cp ../runme .
