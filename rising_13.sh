#!/bin/bash

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests
rm -rf kernel/sony
rm -rf device/sony
rm -rf hardware/sony
rm -rf vendor/sony
rm -rf vendor/lineage-priv
rm -rf packages/apps/AudioFX
rm -rf packages/apps/Etar
rm -rf packages/apps/Eleven
rm -rf packages/apps/Gallery2
rm -rf packages/apps/Glimpse
rm -rf packages/apps/Jelly

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

# Clone Extra Apps
git clone https://github.com/LineageOS/android_packages_apps_AudioFX -b lineage-20.0 packages/apps/AudioFX
git clone https://github.com/LineageOS/android_packages_apps_Etar -b lineage-20.0 packages/apps/Etar
git clone https://github.com/LineageOS/android_packages_apps_Eleven -b lineage-20.0 packages/apps/Eleven
git clone https://github.com/LineageOS/android_packages_apps_Recorder -b lineage-20.0 packages/apps/Recorder
git clone https://github.com/LineageOS/android_packages_apps_Gallery2 -b lineage-20.0 packages/apps/Gallery2
git clone https://github.com/LineageOS/android_packages_apps_Glimpse -b lineage-20.0 packages/apps/Glimpse
git clone https://github.com/LineageOS/android_packages_apps_Jelly -b lineage-20.0 packages/apps/Jelly

# Export
export BUILD_USERNAME=ivy
export BUILD_HOSTNAME=crave

# Set up build environment
source build/envsetup.sh

# Build rom
brunch aurora userdebug

# Upload rom
curl uploader.sh -T out/target/product/aurora/rising*.zip
