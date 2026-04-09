#!/usr/bin/env bash
set -euo pipefail
#LLVM环境变量
export PATH=$PWD/llvm12/bin:$PATH
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s legacy

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
	STRIP=llvm-strip
	OBJCOPY=llvm-objcopy
	OBJDUMP=llvm-objdump
	DEPMOD=depmod
	DTC_EXT=/usr/bin/dtc)

#定义默认配置
make ${args[@]} gauguin_kali_defconfig

#开始编译
make ${args[@]} Image dtbo.img all

#生成modules_install
make ${args[@]} INSTALL_MOD_PATH=modules modules_install

# 拷贝 Image 和 dtbo.img 到当前目录
cp $(find out -type f \( -name "Image" -o -name "dtbo.img" \)) ./

#移动到 Anykernel3
mv -v Image AnyKernel3/Image
mv -v dtbo.img AnyKernel3/dtbo.img

#合成DTB
cat $(find out/arch/arm64/boot/dts/vendor/qcom/ -type f -name "*.dtb") > AnyKernel3/dtb

#打包成 flashable zip
cd AnyKernel3
zip -r9v ../out/kernel.zip *
cd ..

#编译susfs版本
git checkout --ours .
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s legacy_susfs
wget https://raw.githubusercontent.com/JackA1ltman/NonGKI_Kernel_Build_2nd/refs/heads/mainline/Patches/Patch/susfs_patch_to_4.19.patch
patch -p1 -F3 < susfs_patch_to_4.19.patch
git clone https://gitlab.com/simonpunk/susfs4ksu.git -b gki-android12-5.10 --depth=1
cp susfs4ksu/kernel_patches/fs ./ -r
cp susfs4ksu/kernel_patches/include ./ -r

#定义默认配置
make ${args[@]} gauguin_kali_defconfig

#开始编译
make ${args[@]} Image dtbo.img all

# 拷贝 Image 和 dtbo.img 到当前目录
cp $(find out -type f \( -name "Image" -o -name "dtbo.img" \)) ./

#移动到 Anykernel3
mv -v Image AnyKernel3/Image
mv -v dtbo.img AnyKernel3/dtbo.img

#合成DTB
cat $(find out/arch/arm64/boot/dts/vendor/qcom/ -type f -name "*.dtb") > AnyKernel3/dtb

#打包成 flashable zip
cd AnyKernel3
zip -r9v ../out/kernel-susfs.zip *
