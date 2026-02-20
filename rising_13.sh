#!/bin/bash

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests
rm -rf kernel/sony
rm -rf device/sony
rm -rf hardware/sony
rm -rf vendor/sony
rm -rf vendor/lineage-priv

# Initialize repo
repo init -u https://github.com/Arrow-OS-Extended/android_manifest.git -b arrow-13.1 --git-lfs

# Sync the repositories
/opt/crave/resync.sh
/opt/crave/resync.sh
repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j8

# Clone device tree
git clone https://github.com/Sorayukii/stardust_kernel_sony_sdm845 -b stock kernel/sony/sdm845
git clone https://github.com/Sorayukii/android_device_sony_aurora -b arrow-13 device/sony/aurora
git clone https://github.com/Sorayukii/android_device_sony_tama-common -b aosp-13 device/sony/tama-common
git clone https://github.com/Sorayukii/android_hardware_sony_SonyOpenTelephony -b 13 hardware/sony/SonyOpenTelephony
git clone https://github.com/Sorayukii/proprietary_vendor_sony_aurora -b 13 vendor/sony/aurora
git clone https://github.com/Sorayukii/proprietary_vendor_sony_tama-common -b 13 vendor/sony/tama-common
git clone https://github.com/Sorayukii/priv-keys -b master vendor/lineage-priv

# Clone Extra Apps
git clone https://github.com/LineageOS/android_packages_apps_Recorder -b lineage-20.0 packages/apps/Recorder

# Export
export BUILD_USERNAME=ivy
export BUILD_HOSTNAME=crave

# Set up build environment
source build/envsetup.sh

# Build rom
lunch arrow_aurora-userdebug
m bacon

# Upload rom
curl uploader.sh -T out/target/product/aurora/Arrow*.zip
