#!/bin/bash

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests
rm -rf prebuilts/clang/host/linux-x86

# Initialize repo
repo init -u https://github.com/ProjectMatrixx/android.git -b 15.0 --git-lfs

# Sync the repositories
/opt/crave/resync.sh
/opt/crave/resync.sh

# Clone device tree repository
git clone https://github.com/Sorayukii/stardust_kernel_sony_sdm845 -b stock kernel/sony/sdm845
git clone https://github.com/Sorayukii/android_device_sony_tama-common -b matrixx-15 device/sony/tama-common
git clone https://github.com/Sorayukii/android_device_sony_aurora -b 15 device/sony/aurora
git clone https://github.com/Sorayukii/proprietary_vendor_sony_tama-common -b 15 vendor/sony/tama-common
git clone https://github.com/Sorayukii/proprietary_vendor_sony_aurora -b 15 vendor/sony/aurora
git clone https://github.com/Sorayukii/priv-keys -b master vendor/lineage-priv
git clone https://github.com/Sorayukii/android_hardware_sony_SonyOpenTelephony -b 15 hardware/sony/SonyOpenTelephony

# Export
export BUILD_USERNAME=ivy
export BUILD_HOSTNAME=crave

# Set up build environment
source build/envsetup.sh

# Build rom
brunch aurora
