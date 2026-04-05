#!/bin/bash

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests
rm -rf kernel/sony
rm -rf device/sony
rm -rf hardware/sony
rm -rf vendor/sony
rm -rf vendor/lineage-priv
rm -rf external/chromium-webview

# Initialize repo
repo init -u https://github.com/DerpFest-AOSP/manifest.git -b 13

# Sync the repositories
/opt/crave/resync.sh
repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune

# Clone device tree
git clone https://github.com/Sorayukii/stardust_kernel_sony_sdm845 -b stock kernel/sony/sdm845
git clone https://github.com/Sorayukii/android_device_sony_aurora -b derp-13 device/sony/aurora
git clone https://github.com/Sorayukii/android_device_sony_tama-common -b aosp-13 device/sony/tama-common
git clone https://github.com/Sorayukii/android_hardware_sony_SonyOpenTelephony -b 13 hardware/sony/SonyOpenTelephony
git clone https://github.com/Sorayukii/proprietary_vendor_sony_aurora -b 13 vendor/sony/aurora
git clone https://github.com/Sorayukii/proprietary_vendor_sony_tama-common -b 13 vendor/sony/tama-common
git clone https://github.com/Sorayukii/priv-keys -b master vendor/lineage-priv

# Replace art and bionic
rm -rf art
rm -rf bionic
git clone https://github.com/ArrowOS/android_art -b arrow-13.1 art
git clone https://github.com/ArrowOS/android_bionic -b arrow-13.1 bionic

# Symlink libncurses 6 >> 5 for Q based
sudo ln -s /usr/lib/x86_64-linux-gnu/libncurses.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5
sudo ln -s /usr/lib/x86_64-linux-gnu/libtinfo.so.6   /usr/lib/x86_64-linux-gnu/libtinfo.so.5

# Export
export BUILD_USERNAME=ivy
export BUILD_HOSTNAME=crave

# Set up build environment
. build/envsetup.sh

# Build rom
lunch derp_aurora-userdebug
mka derp
