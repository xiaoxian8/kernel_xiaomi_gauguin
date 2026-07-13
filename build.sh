#!/usr/bin/env bash
set -euo pipefail
#LLVM环境变量
export PATH=$PWD/llvm14/bin:$PATH
git clone https://github.com/sidex15/KernelSU-Next.git -b legacy-susfs-v2
curl -LSs "https://raw.githubusercontent.com/sidex15/KernelSU-Next/refs/heads/legacy-susfs-v2/kernel/setup.sh" | bash -s legacy-susfs-v2
git clone https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd.git --depth=1 

patch -p1 -F3 < NonGKI_Kernel_Build_2nd/Patches/Patch/susfs_patch_to_4.19.patch
patch -p1 < scope_min_manual_hooks_next.patch
patch -p1 -d KernelSU-Next < next_susfs.patch
patch -p1 < fix_susfs.patch
patch -p1 -F3 < NonGKI_Kernel_Build_2nd/Patches/Droidspaces/fix_kernel_panic_in_xt_qtaguid.cocci
patch -p1 -F3 < NonGKI_Kernel_Build_2nd/Patches/Droidspaces/fix_restore_cgroup_file_prefix_handling.cocci

./scripts/kconfig/merge_config.sh -m  \
      arch/arm64/configs/gauguin_kali_defconfig \
	  NonGKI_Kernel_Build_2nd/Patches/Droidspaces/droidspaces.config
mv .config arch/arm64/configs/gauguin_droid_defconfig
#编译参数
args=(-j$(nproc --all)
	O=out
	ARCH=arm64
	CLANG_TRIPLE=aarch64-linux-gnu-
	CROSS_COMPILE=aarch64-linux-gnu-
	CROSS_COMPILE_COMPAT=arm-linux-gnueabi-
	CC=clang
	LD=ld.lld
	AR=llvm-ar
	NM=llvm-nm
	STRIP=llvm-strip
	OBJCOPY=llvm-objcopy
	OBJDUMP=llvm-objdump
	DEPMOD=depmod
	DTC_EXT=/usr/bin/dtc)

#定义默认配置
make ${args[@]} gauguin_droid_defconfig

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
