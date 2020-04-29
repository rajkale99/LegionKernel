#!/usr/bin/env bash
KERN_IMG=$PWD/out/arch/arm64/boot/Image.gz-dtb
ZIP_DIR=$HOME/Zipper
THREAD="-j32"
CONFIG=vince_defconfig
TYPE=gcc
# build the kernel
function build_kern() {
    DATE=`date`
    BUILD_START=$(date +"%s")

    # cleaup first
#    make clean && make mrproper

    # building
    make O=out $CONFIG $THREAD
    # use gcc for vince and clang
    if [[ "$TYPE" == "gcc" ]]; then
        make O=out $THREAD
    else
        export PATH="$HOME/toolchains/clang/bin:$PATH"
        make $THREAD O=out \
                    CC=clang \
                    CROSS_COMPILE=aarch64-linux-gnu- \
                    CROSS_COMPILE_ARM32=arm-linux-gnueabi-
    fi
}

# make flashable zip
function make_flashable() {
    cd $ZIP_DIR
    make clean &>/dev/null
    cp $KERN_IMG $ZIP_DIR/zImage
        make stable &>/dev/null
    echo "Flashable zip generated under $ZIP_DIR."
    ZIP=$(ls | grep *.zip | grep -v *.sha1)
    cd -
}

# Export
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Rajkale99"
export KBUILD_BUILD_HOST="Legion"
export CROSS_COMPILE="$HOME/toolchains/aarch64/bin/aarch64-elf-"
export CROSS_COMPILE_ARM32="$HOME/toolchains/aarch32/bin/arm-eabi-"
export LINUX_VERSION=$(awk '/SUBLEVEL/ {print $3}' Makefile \
    | head -1 | sed 's/[^0-9]*//g')
# Install build package
sudo apt install bc

# Clone toolchains
[ -d $HOME/toolchains/clang ] || git clone https://github.com/kdrag0n/proton-clang.git --depth 1 $HOME/toolchains/clang
[ -d $HOME/toolchains/aarch64 ] || git clone https://github.com/kdrag0n/aarch64-elf-gcc.git $HOME/toolchains/aarch64
[ -d $HOME/toolchains/aarch32 ] || git clone https://github.com/kdrag0n/arm-eabi-gcc.git $HOME/toolchains/aarch32

# Clone AnyKernel3
[ -d $HOME/Zipper ] || git clone https://github.com/Rajkale99/AnyKernel3 $HOME/Zipper

# Build start
build_kern

# make zip
make_flashable
