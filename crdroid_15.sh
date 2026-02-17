#!/bin/bash

# WARNING: This will remove all local changes!
rm -rf .repo/local_manifests
rm -rf prebuilts/clang/host/linux-x86

# Initialize repo
repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs

# Clone device tree manifest
git clone https://github.com/Sorayukii/local_manifests -b maaster .repo/local_manifests

# Sync the repositories
/opt/crave/resync.sh
/opt/crave/resync.sh
repo sync

# Export
export BUILD_USERNAME=ivy
export BUILD_HOSTNAME=crave

# Set up build environment
. build/envsetup.sh

# Build rom
brunch aurora
