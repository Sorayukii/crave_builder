#!/bin/bash

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests
rm -rf kernel/sony
rm -rf device/sony
rm -rf hardware/sony
rm -rf vendor/sony
rm -rf vendor/lineage-priv

# Initialize repo
repo init -u https://github.com/RisingOS-XTI/manifest -b thirteen --git-lfs

# Sync the repositories
/opt/crave/resync.sh
/opt/crave/resync.sh
repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j8

# Clone device tree
git clone https://github.com/Sorayukii/stardust_kernel_sony_sdm845 -b stock kernel/sony/sdm845
git clone https://github.com/Sorayukii/android_device_sony_aurora -b 13 device/sony/aurora
git clone https://github.com/Sorayukii/android_device_sony_tama-common -b 13 device/sony/tama-common
git clone https://github.com/Sorayukii/android_hardware_sony_SonyOpenTelephony -b 13 hardware/sony/SonyOpenTelephony
git clone https://github.com/Sorayukii/proprietary_vendor_sony_aurora -b 13 vendor/sony/aurora
git clone https://github.com/Sorayukii/proprietary_vendor_sony_tama-common -b 13 vendor/sony/tama-common
git clone https://github.com/Sorayukii/priv-keys -b master vendor/lineage-priv

# Export
export BUILD_USERNAME=ivy
export BUILD_HOSTNAME=crave

# Set up build environment
source build/envsetup.sh

# Build rom
brunch aurora userdebug

# Upload rom
curl uploader.sh -T out/target/product/aurora/rising*.zip
