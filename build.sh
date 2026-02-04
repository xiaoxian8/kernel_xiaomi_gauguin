#!/usr/bin/env bash

#LLVM环境变量
export PATH=$PWD/llvm20/bin:$PATH

#编译参数
args=(-j4
	O=out
	ARCH=arm64
	CC=clang
	LD=ld.lld
	AR=llvm-ar
	NM=llvm-nm
	STRIP=llvm-strip
	OBJCOPY=llvm-objcopy
	OBJDUMP=llvm-objdump
	READELF=llvm-readelf
	HOSTCC=clang
	HOSTCXX=clang++
	HOSTAR=llvm-ar
	HOSTLD=ld.lld
	DTC=dtc
	DEPMOD=depmod)
	
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

#移动到 Anykernel3
mv -v Image AnyKernel3/Image
mv -v dtbo.img AnyKernel3/dtbo.img
rm Image

#合成DTB
cat $(find out/arch/arm64/boot/dts/vendor/qcom/ -type f -name "*.dtb") > AnyKernel3/dtb

#打包成 flashable zip
cd AnyKernel3
zip -r9v ../out/kernel.zip *
rm Image dtbo.img dtb
