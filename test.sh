#!/bin/bash

# =========================================================
# CONFIGURATION
# =========================================================
# This token was retrieved from your previous log for continuous functionality.
TG_BOT_TOKEN="8153933976:AAHLza4gwShckhzAydZxJWGYFKYrgEO5MVE"
TG_BUILD_CHAT_ID="-1002476597056"
DEVICE_CODE="aurora"
BUILD_TARGET="Evolution-X"
ANDROID_VERSION="15"

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
  
  # 1. Escape MarkdownV2 special characters that are NOT intended for formatting
  # Temporarily replace '*' and '_' to preserve bold/italic formatting
  local escaped_message=$(echo "$message" | sed \
    -e 's/\*/\*TEMP\*/g' \
    -e 's/_/\_TEMP\_/g' \
    -e 's/\[/\\[/g' \
    -e 's/\]/\\]/g' \
    -e 's/(/\\(/g' \
    -e 's/)/\\)/g' \
    -e 's/~/\\~/g' \
    -e 's/`/\`/g' \
    -e 's/>/\\>/g' \
    -e 's/#/\\#/g' \
    -e 's/+/\\+/g' \
    -e 's/-/\\-/g' \
    -e 's/=/\\=/g' \
    -e 's/|/\\|/g' \
    -e 's/{/\\{/g' \
    -e 's/}/\\}/g' \
    -e 's/\./\\./g' \
    -e 's/!/\\!/g')

  # 2. Restore the actual formatting characters (* and _)
  local re_escaped_message=$(echo "$escaped_message" | sed \
    -e 's/\*TEMP\*/\*/g' \
    -e 's/\_TEMP\_/\_/g')

  # 3. URL encode special characters for safe HTTP transmission
  local encoded_message=$(echo "$re_escaped_message" | sed \
    -e 's/%/%25/g' \
    -e 's/&/%26/g' \
    -e 's/+/%2b/g' \
    -e 's/ /%20/g' \
    -e 's/\"/%22/g' \
    -e 's/'"'"'/%27/g' \
    -e 's/\n/%0A/g')
    
  # Send message using Telegram Bot API with MarkdownV2 parsing
  curl -s -X POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" \
    -d "chat_id=${chat_id}" \
    -d "text=${encoded_message}" \
    -d "parse_mode=MarkdownV2" \
    -d "disable_web_page_preview=true" > /dev/null
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
    local initial_msg=$'⚙️ *ROM Build Started!*\n\n• *ROM:* '"$BUILD_TARGET"$'\n• *Android:* '"$ANDROID_VERSION"$'\n• *Device:* '"$DEVICE_CODE"$'\n• *Server:* foss.crave.io\n• *Start Time:* '"$(date '+%Y-%m-%d %H:%M:%S %Z')"
    send_telegram_msg "$TG_BUILD_CHAT_ID" "$initial_msg"
    
    # =========================================================
    # ORIGINAL BUILD STEPS
    # =========================================================
    
    # Remove local changes
    rm -rf .repo/local_manifests
    rm -rf kernel/sony/sdm845
    rm -rf device/sony/tama-common
    rm -rf device/sony/aurora
    rm -rf hardware/sony/SonyOpenTelephony
    rm -rf vendor/sony/tama-common
    rm -rf vendor/sony/aurora
    rm -rf vendor/lineage-priv

    # Init Evolution-X
    repo init -u https://github.com/Evolution-X/manifest -b vic --git-lfs

    # Resync sources
    /opt/crave/resync.sh
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

    # Clone device tree
    git clone https://github.com/Sorayukii/stardust_kernel_sony_sdm845 -b stock kernel/sony/sdm845
    git clone https://github.com/Sorayukii/android_device_sony_aurora -b 15 device/sony/aurora
    git clone https://github.com/Sorayukii/android_device_sony_tama-common -b 15x device/sony/tama-common
    git clone https://github.com/Sorayukii/android_hardware_sony_SonyOpenTelephony -b 15 hardware/sony/SonyOpenTelephony
    git clone https://github.com/Sorayukii/proprietary_vendor_sony_aurora -b 15 vendor/sony/aurora
    git clone https://github.com/Sorayukii/proprietary_vendor_sony_tama-common -b 15 vendor/sony/tama-common
    git clone https://github.com/Sorayukii/priv-keys -b master vendor/lineage-priv

    # Setup the build environment
    . build/envsetup.sh

    # Declare flags
    export TARGET_INCLUDE_ACCORD=false
    export WITH_GMS=false

    # Lunch target selection
    lunch lineage_aurora-bp1a-user
    
    # Build rom
    m evolution

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
    local final_msg=$'⚙️ *ROM Build Finished!*\n\n• *Finish Time:* '"$(date '+%Y-%m-%d %H:%M:%S %Z')"$'\n• *Duration:* '"$DURATION_FORMATTED"$'\n• *Status:* '"$status_text"
    send_telegram_msg "$TG_BUILD_CHAT_ID" "$final_msg"
    
    if [[ $BUILD_STATUS -ne 0 ]]; then
        send_telegram_file "$TG_BUILD_CHAT_ID" "out/error.log"
    fi

    # Conditional Upload ROM
    if [[ $BUILD_STATUS -eq 0 ]]; then
        send_telegram_msg "$TG_BUILD_CHAT_ID" "📤 *Uploading files...*"
        # Calls the go-up script
        rm -rf go-up*
        wget https://raw.githubusercontent.com/Sorayukii/tools-gofile/refs/heads/private/go-up
        chmod +x go-up
        ./go-up out/target/product/aurora/Evolution*aurora*.zip
    fi
}

# =========================================================
# MAIN EXECUTION
# =========================================================

# Check required environment variables (optional but good practice)
start_build_process
