#!/bin/bash

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests
rm -rf kernel/sony
rm -rf device/sony
rm -rf hardware/sony
rm -rf vendor/sony
rm -rf vendor/lineage-priv

# Initialize repo
repo init -u https://github.com/Superior13-NEXT/manifest.git -b QPR3

# Sync the repositories
/opt/crave/resync.sh
/opt/crave/resync.sh
repo sync -c --force-sync --no-clone-bundle --no-tags

# Remove additional
rm -rf packages/apps/SuperiorLab
rm -rf packages/apps/Settings
rm -rf frameworks/base

# Clone device tree
git clone https://github.com/Sorayukii/stardust_kernel_sony_sdm845 -b stock-upstream kernel/sony/sdm845
git clone https://github.com/Sorayukii/android_device_sony_aurora -b supri-13 device/sony/aurora
git clone https://github.com/Sorayukii/android_device_sony_tama-common -b aosp-13 device/sony/tama-common
git clone https://github.com/Sorayukii/android_hardware_sony_SonyOpenTelephony -b 13 hardware/sony/SonyOpenTelephony
git clone https://github.com/Sorayukii/proprietary_vendor_sony_aurora -b 13 vendor/sony/aurora
git clone https://github.com/Sorayukii/proprietary_vendor_sony_tama-common -b 13 vendor/sony/tama-common
git clone https://github.com/Sorayukii/priv-keys -b master vendor/lineage-priv

# Clone Additional
git clone https://github.com/LineageOS/android_packages_apps_Aperture --depth=1 -b lineage-20.0 packages/apps/Aperture
git clone https://github.com/KanonifyX/android_packages_apps_Settings --depth=1 -b QPR3 packages/apps/Settings
git clone https://github.com/KanonifyX/android_packages_apps_SuperiorLab --depth=1 -b QPR3 packages/apps/SuperiorLab
git clone https://github.com/KanonifyX/android_frameworks_base --depth=1 -b QPR3  frameworks/base

# Export
export BUILD_USERNAME=ivy
export BUILD_HOSTNAME=crave

# Set up build environment
source build/envsetup.sh
. build/envsetup.sh

# Build rom
lunch superior_aurora-userdebug
m installclean
m bacon -j$(nproc --all)

# Upload rom
curl uploader.sh -T out/target/product/aurora/Superior*.zip
