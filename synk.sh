#!/bin/bash

# ANSI color escape codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Initialize variables
file_to_observe=""
android_app_group=""
ios_app_group=""
platform_flag=false

usage() {
  echo -e "\nUsage: synk -f file -a <packagename> -i <group id> "
  echo -e "  -f: Specify the file to be observerd and updated on the devices"
  echo -e "  -a: Specify the packname of the Android app where you want to updated the file."
  echo -e "  -i: Specify the group of the iOS app where you want to updated the file."
  echo -e "  -h: Display this help message"
  exit 1
}

log() {
  local level="$1"
  local message="$2"

  case "$level" in
    "info")
      echo -e "[${GREEN}INFO${NC}] $message"
      ;;
    "warning")
      echo -e "[${YELLOW}WARNING${NC}] $message"
      ;;
    "error")
      echo -e "[${RED}ERROR${NC}] $message" >&2
      ;;
    *)
      echo "Invalid log level: $level"
      ;;
  esac
}


error() {
  log "error" $1
  exit 1
}

# Parse command-line arguments
while getopts "f:a:i:h" opt; do
  case $opt in
    f)
      file_to_observe="$OPTARG"
      ;;
    a)
      android_app_group="$OPTARG"
      platform_flag=true
      ;;
    i)
      ios_app_group="$OPTARG"
      platform_flag=true
      ;;
    h)
      usage
      ;;
    \?)
      log "error" "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

# Check if -f is provided (mandatory)
if [ -z "$file_to_observe" ]; then
  log "error" "-f is mandatory. Please provide the path to the file to observe."
fi

# Check if either -android or -ios is provided
if [ "$platform_flag" = false ]; then
  log "error" "Either -android or -ios must be provided."
  usage
fi

log "info" "Observing changes to '$file_to_observe'..."

transfer_android() {
      # Check if adb is installed
    if ! command -v adb &> /dev/null; then
       log "error" "adb not found. Please make sure you have Android SDK installed and added to your PATH."
        return
    fi

    # Check for connected Android devices in debug mode
    devices=$(adb devices | grep 'device$' | awk '{print $1}')

    if [ -z "$devices" ]; then
       log "warning" "No connected Android devices in debug mode found."
        return
    fi
    # Iterate through connected devices and upload the file to each
    for device in $devices; do
    if adb -s "$device" push "$file_to_observe" /storage/emulated/0/Android/data/$android_app_group &>/dev/null; then
            log "info" "File updated on Android device $device successfully."
        else
            log "error" "Updating on Andorid device $device failed."
        fi
    done
}

transfer_ios() {
    # Check if xcrun is available
    if ! command -v xcrun &> /dev/null; then
        log "error" "xcrun not found. Please make sure you have Xcode Command Line Tools installed."
        return
    fi

    # Get a list of booted iOS simulators
    booted_simulators=$(xcrun simctl list | grep -E "Booted" | awk -F '[(|)]' '{print $2}' | tr -d '[:space:]')

    if [ -z "$booted_simulators" ]; then
        log "warning" "No booted iOS simulators found."
        return
    fi

    for simulator in $booted_simulators; do
        local device_dir="$HOME/Library/Developer/CoreSimulator/Devices/$simulator"
        local app_group_dir="$device_dir/data/Containers/Shared/AppGroup"
        local directory=$(find $app_group_dir -type f -exec grep -q $ios_app_group {} \; -exec dirname {} \; -quit)

        if [ -d "$directory" ]; then
            cp "$file_to_observe" "$directory"
            log "info" "File updated on iOS device $simulator successfully."
        else
            log "error" "Updating on iOS device $simulator failed."
        fi
    done
}

# Function to transfer the file
transfer_file() {
    if [ -n "$android_app_group" ]; then
        transfer_android
    fi

    if [ -n "$ios_app_group" ]; then
        transfer_ios
    fi
}

# Initial transference of the file
transfer_file

# Use fswatch to watch for file changes
fswatch -0 "$file_to_observe" | while read -d "" event; do
    transfer_file
done
