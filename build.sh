#!/usr/bin/env bash
set -euo pipefail
#LLVM环境变量
export PATH=$PWD/llvm12/bin:$PATH
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s legacy

#编译参数
args=(-j$(nproc --all)
	O=out
	ARCH=arm64
	CROSS_COMPILE=aarch64-linux-gnu-
	CROSS_COMPILE_COMPAT=arm-linux-gnueabi-
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
	DEPMOD=depmod
	DTC_EXT=/usr/bin/dtc)

#定义默认配置
make ${args[@]} gauguin_kali_defconfig

#开始编译
make ${args[@]} Image.gz-dtb dtbo.img modules

#生成modules_install
make ${args[@]} INSTALL_MOD_PATH=modules modules_install

# 拷贝 Image 和 dtbo.img 到当前目录
# cp $(find out -type f \( -name "Image.gz-dtb" -o -name "dtbo.img" \)) ./

#移动到 Anykernel3
mv -v Image.gz-dtb AnyKernel3/Image.gz-dtb
mv -v dtbo.img AnyKernel3/dtbo.img

#合成DTB
#cat $(find out/arch/arm64/boot/dts/vendor/qcom/ -type f -name "*.dtb") > AnyKernel3/dtb

#打包成 flashable zip
cd AnyKernel3
zip -r9v ../out/kernel.zip *
