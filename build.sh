#!/usr/bin/env bash

#LLVM环境变量
export PATH=$PWD/llvm12/bin:$PATH

#编译参数
args=(-j4
	O=out
	ARCH=arm64
	CLANG_TRIPLE=aarch64-linux-gnu-
	CROSS_COMPILE=aarch64-linux-gnu-
	CROSS_COMPILE_COMPAT=arm-linux-gnueabi-
	CC=clang
	AR=llvm-ar
	NM=llvm-nm
	STRIP=llvm-strip
	OBJCOPY=llvm-objcopy
	OBJDUMP=llvm-objdump
	DTC_EXT=dtc
	DEPMOD=depmod
	DTC_OVERLAY_TEST_EXT=ufdt_apply_overlay)

#定义默认配置
make ${args[@]} gauguin_kali_defconfig

#开始编译
make ${args[@]} Image.gz-dtb dtbo.img

#生成modules_install
make ${args[@]} INSTALL_MOD_PATH=modules modules_install

# 拷贝 Image 和 dtbo.img 到当前目录
cp $(find out -type f \( -name "Image.gz-dtb" -o -name "dtbo.img" \)) ./

#移动到 Anykernel3
mv -v Image.gz-dtb AnyKernel3/Image.gz-dtb
mv -v dtbo.img AnyKernel3/dtbo.img

#合成DTB
#cat $(find out/arch/arm64/boot/dts/vendor/qcom/ -type f -name "*.dtb") > AnyKernel3/dtb

#打包成 flashable zip
cd AnyKernel3
zip -r9v ../out/kernel.zip *
