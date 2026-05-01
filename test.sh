#!/bin/bash

# =========================================================
# CONFIGURATION
# =========================================================
# This token was retrieved from your previous log for continuous functionality.
TG_BOT_TOKEN="8153933976:AAHLza4gwShckhzAydZxJWGYFKYrgEO5MVE"
TG_BUILD_CHAT_ID="-1002476597056"
DEVICE_CODE="aurora"
BUILD_TARGET="LunarisAOSP"
ANDROID_VERSION="16"

# SHELL CONFIGURATION
export TZ="Asia/Jakarta"
export BUILD_USERNAME=Ivy
export BUILD_HOSTNAME=crave

# =========================================================
# TELEGRAM FUNCTIONS
# =========================================================

# Function to safely format and send a text message to Telegram
send_telegram_msg() {
  local chat_id="$1"
  local message="$2"

  echo -e "\n[$(date '+%Y-%m-%d %H:%M:%S')] Sending message to Telegram..."

  curl -s -X POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" \
    -d "chat_id=${chat_id}" \
    --data-urlencode "text=${message}" \
    -d "parse_mode=HTML" \
    -d "disable_web_page_preview=true" &> /dev/null
}

send_telegram_file() {
  local chat_id="$1"
  local file_path="$2"
  
  # Ensure the file exists before attempting upload
  [ -f "$file_path" ] || {
    echo "File not found: $file_path"
    return 1
  }
  
  # Send file using Telegram Bot API (no caption, no parse_mode)
  curl -s -X POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendDocument" \
    -F chat_id="${chat_id}" \
    -F document=@"${file_path}" > /dev/null
}

# Function to format total seconds into HH:MM:SS string
format_duration() {
    local T=$1
    local H=$((T/3600))
    local M=$(( (T%3600)/60 ))
    local S=$((T%60))
    printf "%02d hours, %02d minutes, %02d seconds" $H $M $S
}


# =========================================================
# BUILD LOGIC FUNCTION
# =========================================================

start_build_process() {

    # --- STEP 1: START TIMER AND SEND INITIAL NOTIFICATION ---
    START_TIME=$(date +%s)

    # Message for Build Started
    local initial_msg=$'⚙️ <b>ROM Build Started!</b>\n\n• <b>ROM:</b> '"$BUILD_TARGET"$'\n• <b>Android:</b> '"$ANDROID_VERSION"$'\n• <b>Device:</b> '"$DEVICE_CODE"$'\n• <b>Server:</b> foss.crave.io\n• <b>Start Time:</b> '"$(date '+%Y-%m-%d %H:%M:%S %Z')"
    send_telegram_msg "$TG_BUILD_CHAT_ID" "$initial_msg"
    
    # =========================================================
    # ORIGINAL BUILD STEPS
    # =========================================================
    
    # Remove local changes
    rm -rf .repo/local_manifests
    rm -rf bionic
    rm -rf build/make
    rm -rf build/soong
    rm -rf kernel/sony/sdm845
    rm -rf device/sony/tama-common
    rm -rf device/sony/aurora
    rm -rf hardware/sony/SonyOpenTelephony
    rm -rf vendor/sony/tama-common
    rm -rf vendor/sony/aurora
    rm -rf vendor/lineage-priv

    # Init ROM repository
    repo init -u https://github.com/Lunaris-AOSP/android -b 16.2 --git-lfs

    # Resync sources
    /opt/crave/resync.sh
    repo sync --force-sync --no-clone-bundle --no-tags

    # Clone device tree
    git clone https://github.com/Sorayukii/stardust_kernel_sony_sdm845 -b bpf kernel/sony/sdm845
    git clone https://github.com/Sorayukii/android_device_sony_aurora -b 16.2-luna device/sony/aurora
    git clone https://github.com/Sorayukii/android_device_sony_tama-common -b 16 device/sony/tama-common
    git clone https://github.com/Sorayukii/android_hardware_sony_SonyOpenTelephony -b 15 hardware/sony/SonyOpenTelephony
    git clone https://github.com/Sorayukii/proprietary_vendor_sony_aurora -b 15 vendor/sony/aurora
    git clone https://github.com/Sorayukii/proprietary_vendor_sony_tama-common -b 15 vendor/sony/tama-common
    git clone https://github.com/Sorayukii/priv-keys -b master vendor/lineage-priv

    # Fix camera
    rm -rf bionic
    rm -rf build/make
    rm -rf build/soong
    git clone https://github.com/Sorayukii/android_bionic -b luna-16.2 bionic
    git clone https://github.com/Sorayukii/android_build -b luna-16.2 build/make
    git clone https://github.com/Sorayukii/android_build_soong -b luna-16.2 build/soong

    # Setup the build environment
    . build/envsetup.sh

    # Custom flag
    export TARGET_DISABLE_MATLOG=true
    export WITH_BCR=true
    export USE_REALITY_ENGINE=true
    echo "ro.lunaris.maintainer=Ivy" >> device/sony/aurora/system.prop

    # Start building
    lunch lineage_aurora-bp4a-userdebug
    m bacon

    BUILD_STATUS=$? # Capture exit code immediately

    # --- STEP 3: CALCULATE TIME AND SEND FINAL NOTIFICATION ---
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    local DURATION_FORMATTED=$(format_duration $DURATION)
    
    if [[ $BUILD_STATUS -eq 0 ]]; then
        local status_text="Success"
    else
        local status_text="Failure (Exit Code: $BUILD_STATUS)"
    fi

    # Final Message with Android Version
    local final_msg=$'⚙️ <b>ROM Build Finished!</b>\n\n• <b>Finish Time:</b> '"$(date '+%Y-%m-%d %H:%M:%S %Z')"$'\n• <b>Duration:</b> '"$DURATION_FORMATTED"$'\n• <b>Status:</b> '"$status_text"
    send_telegram_msg "$TG_BUILD_CHAT_ID" "$final_msg"
    
    if [[ $BUILD_STATUS -ne 0 ]]; then
        send_telegram_file "$TG_BUILD_CHAT_ID" "out/error.log"
    fi

    # Conditional Upload ROM
    if [[ $BUILD_STATUS -eq 0 ]]; then
        send_telegram_msg "$TG_BUILD_CHAT_ID" "📤 <b>Uploading files...</b>"
        # Calls the go-up script
        rm -rf go-up*
        wget https://raw.githubusercontent.com/Sorayukii/tools-gofile/refs/heads/private/go-up
        chmod +x go-up
        ./go-up out/target/product/aurora/*aurora*.zip
    fi
}

# =========================================================
# MAIN EXECUTION
# =========================================================

# Check required environment variables (optional but good practice)
start_build_process
