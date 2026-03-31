#!/bin/bash

# Remove local changes
rm -rf .repo/local_manifests
rm -rf prebuilts
rm -rf kernel/sony/sdm845
rm -rf device/sony/tama-common
rm -rf device/sony/aurora
rm -rf hardware/sony/SonyOpenTelephony
rm -rf vendor/sony/tama-common
rm -rf vendor/sony/aurora
rm -rf vendor/lineage-priv

# Initialize repo
repo init -u https://github.com/AviumUI/android_manifests -b avium-16.2 --git-lfs

# Sync the repositories
/opt/crave/resync.sh
repo sync -c --force-sync --no-clone-bundle --no-tags

# Try fix issue
rm -rf hardware/lineage/compat
git clone https://github.com/Ivy-4869/android_hardware_lineage_compat -b lineage-23.2 hardware/lineage/compat

# Clone device tree
git clone https://github.com/Sorayukii/stardust_kernel_sony_sdm845 -b main kernel/sony/sdm845
git clone https://github.com/Sorayukii/android_device_sony_aurora -b avm device/sony/aurora
git clone https://github.com/Sorayukii/android_device_sony_tama-common -b 16x device/sony/tama-common
git clone https://github.com/Sorayukii/android_hardware_sony_SonyOpenTelephony -b 15 hardware/sony/SonyOpenTelephony
git clone https://github.com/Sorayukii/proprietary_vendor_sony_aurora -b 15 vendor/sony/aurora
git clone https://github.com/Sorayukii/proprietary_vendor_sony_tama-common -b 16x vendor/sony/tama-common
git clone https://github.com/Sorayukii/priv-keys -b master vendor/lineage-priv

# Fuck-bpf
git clone https://github.com/techyminati/fuck-bpf -b lineage-23.2
chmod +x ./fuck-bpf/apply.sh && ./fuck-bpf/apply.sh --mb

# Export
export BUILD_USERNAME=ivy
export BUILD_HOSTNAME=crave

# Build rom
. build/envsetup.sh
lunch lineage_aurora-bp4a-userdebug
m bacon -j$(nproc --all)
