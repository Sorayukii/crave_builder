#!/bin/bash

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests
rm -rf prebuilts/clang/host/linux-x86

# Initialize repo
repo init -u https://github.com/ProjectMatrixx/android.git -b 15.0 --git-lfs

# Clone device tree manifest
git clone https://github.com/Sorayukii/local_manifests -b matrixx-15 .repo/local_manifests

# Sync the repositories
/opt/crave/resync.sh
/opt/crave/resync.sh
repo sync -c --no-clone-bundle --optimized-fetch --prune --force-sync -j$(nproc --all)

# Export
export BUILD_USERNAME=ivy
export BUILD_HOSTNAME=crave

# Set up build environment
source build/envsetup.sh

# Build rom
brunch aurora
