#!/bin/bash

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests

# Initialize repo
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs --no-clone-bundle

# Sync the repositories
/opt/crave/resync.sh
/opt/crave/resync.sh
repo sync

# Clone device tree
git clone https://github.com/Sorayukii/stardust_kernel_sony_sdm845 -b stock kernel/sony/sdm845
git clone https://github.com/Sorayukii/android_device_sony_aurora -b 15 device/sony/aurora
git clone https://github.com/Sorayukii/android_device_sony_tama-common -b 15 device/sony/tama-common
git clone https://github.com/Sorayukii/android_hardware_sony_SonyOpenTelephony -b 15 hardware/sony/SonyOpenTelephony
git clone https://github.com/Sorayukii/proprietary_vendor_sony_aurora -b 15 vendor/sony/aurora
git clone https://github.com/Sorayukii/proprietary_vendor_sony_tama-common -b 15 vendor/sony/tama-common
git clone https://github.com/Sorayukii/priv-keys -b master vendor/lineage-priv

# Fuck-bpf
git clone https://github.com/techyminati/fuck-bpf
chmod +x ./fuck-bpf/apply.sh && ./fuck-bpf/apply.sh --mb

# Export
export BUILD_USERNAME=ivy
export BUILD_HOSTNAME=crave

# Set up build environment
source build/envsetup.sh

# Build rom
brunch aurora

# Upload rom
curl uploader.sh -T out/target/product/aurora/crDroidAndroid*.zip
