#!/bin/bash

# Remove local changes
rm -rf .repo/local_manifests
rm -rf kernel/sony/sdm845
rm -rf device/sony/tama-common
rm -rf device/sony/aurora
rm -rf hardware/sony/SonyOpenTelephony
rm -rf vendor/sony/tama-common
rm -rf vendor/sony/aurora
rm -rf vendor/lineage-priv

# Initialize repo
repo init -u https://github.com/Evolution-X/manifest -b vic --git-lfs

# Sync the repositories
/opt/crave/resync.sh
repo sync -c --force-sync --no-clone-bundle --no-tags

# Clone device tree
git clone https://github.com/Sorayukii/stardust_kernel_sony_sdm845 -b stock kernel/sony/sdm845
git clone https://github.com/Sorayukii/android_device_sony_aurora -b evix-15 device/sony/aurora
git clone https://github.com/Sorayukii/android_device_sony_tama-common -b 15x device/sony/tama-common
git clone https://github.com/Sorayukii/android_hardware_sony_SonyOpenTelephony -b 15 hardware/sony/SonyOpenTelephony
git clone https://github.com/Sorayukii/proprietary_vendor_sony_aurora -b 15 vendor/sony/aurora
git clone https://github.com/Sorayukii/proprietary_vendor_sony_tama-common -b 15 vendor/sony/tama-common
git clone https://github.com/Sorayukii/priv-keys -b master vendor/lineage-priv

# Fuck-bpf
git clone https://github.com/techyminati/fuck-bpf -b lineage-23.2
chmod +x ./fuck-bpf/apply.sh && ./fuck-bpf/apply.sh --mb

# Export
export BUILD_USERNAME=ivy
export BUILD_HOSTNAME=crave

# Build rom
. build/envsetup.sh
lunch lineage_aurora-bp1a-userdebug
m evolution
