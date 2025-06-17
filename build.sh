#!/bin/bash

#环境变量
source $PWD/../envpath/envset.sh

#LLVM环境变量
export PATH=$PWD/../envpath/llvm20/bin:$PATH

#编译参数
args=(-j$(nproc --all) 
	O=out
	ARCH=arm64
	CLANG_TRIPLE=aarch64-linux-gnu-
	CROSS_COMPILE=aarch64-linux-gnu-
	CROSS_COMPILE_COMPAT=arm-linux-gnueabi-
	CC=clang
	AR=llvm-ar
	NM=llvm-nm
	OBJCOPY=llvm-objcopy
	OBJDUMP=llvm-objdump
	STRIP=llvm-strip
	DEPMOD=$PWD/../envpath/build/build-tools/path/linux-x86/depmod
	DTC_EXT=$PWD/../envpath/build/build-tools/path/linux-x86/dtc
	DTC_OVERLAY_TEST_EXT=ufdt_apply_overlay)

#清理旧的构建
make ${args[@]} mrproper

#定义默认配置
make ${args[@]} gauguin_kali_defconfig

#开始编译
make ${args[@]}

#生成modules_install
make ${args[@]} INSTALL_MOD_PATH=modules modules_install

#生成dtb
find out/arch/arm64/boot/dts/vendor/qcom -name '*.dtb' -exec cat {} + > out/arch/arm64/boot/dtb
