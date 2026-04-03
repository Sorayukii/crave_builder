#!/bin/bash

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests
rm -rf kernel/sony
rm -rf device/sony
rm -rf hardware/sony
rm -rf vendor/sony
rm -rf vendor/lineage-priv

# Initialize repo
repo init -u https://github.com/ArrowOS-T/android_manifest.git -b arrow-13.1_ext

# Sync the repositories
/opt/crave/resync.sh
repo sync

# Clone device tree
git clone https://github.com/Sorayukii/stardust_kernel_sony_sdm845 -b main kernel/sony/sdm845
git clone https://github.com/Sorayukii/android_device_sony_akari -b arrow-13 device/sony/akari
git clone https://github.com/Sorayukii/android_device_sony_tama-common -b aosp-13 device/sony/tama-common
git clone https://github.com/Sorayukii/android_hardware_sony_SonyOpenTelephony -b 13 hardware/sony/SonyOpenTelephony
git clone https://github.com/Sorayukii/proprietary_vendor_sony_akari -b 13 vendor/sony/akari
git clone https://github.com/Sorayukii/proprietary_vendor_sony_tama-common -b 13 vendor/sony/tama-common
# git clone https://github.com/Sorayukii/priv-keys -b master vendor/lineage-priv

# Clone libncurses
git clone https://github.com/LineageOS/android_external_libncurses -b lineage-20.0 external/libncurses

# Symlink libncurses 6 >> 5 for Q based
sudo ln -s /usr/lib/x86_64-linux-gnu/libncurses.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5
sudo ln -s /usr/lib/x86_64-linux-gnu/libtinfo.so.6   /usr/lib/x86_64-linux-gnu/libtinfo.so.5

# Export
export BUILD_USERNAME=ivy
export BUILD_HOSTNAME=crave

# Set up build environment
. build/envsetup.sh

# Build rom
lunch arrow_akari-userdebug
m bacon

