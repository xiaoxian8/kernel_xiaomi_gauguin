#!/usr/bin/env bash

#环境变量
source $PWD/../envpath/envset.sh

#LLVM环境变量
export PATH=$PWD/../envpath/prebuilts-master/clang/host/linux-x86/clang-r416183b/bin:$PATH

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
	DTC_EXT=$PWD/../envpath/build/build-tools/path/linux-x86/dtc
	DTC_OVERLAY_TEST_EXT=ufdt_apply_overlay)

#清理旧的构建
make ${args[@]} mrproper

#定义默认配置
make ${args[@]} gauguin_kali_defconfig
make ${args[@]} menuconfig

#开始编译
make ${args[@]}

#生成modules_install
make ${args[@]} INSTALL_MOD_PATH=modules modules_install

# 拷贝 Image 和 dtbo.img 到当前目录
cp $(find out -type f \( -name "Image" -o -name "dtbo.img" \)) ./

#应用补丁
./kpm_patch/patch_linux

#移动到 Anykernel3
mv -v oImage AnyKernel3/Image
mv -v dtbo.img AnyKernel3/dtbo.img
rm Image

#合成DTB
cat $(find out/arch/arm64/boot/dts/vendor/qcom/ -type f -name "*.dtb") > AnyKernel3/dtb

#打包成 flashable zip
cd AnyKernel3
zip -r9v ../out/kernel.zip *
