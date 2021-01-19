#!/bin/bash

# Created by Bat.bat on 11/1/2020
# Copyright (C) 2020 OpenIntelWireless. All rights reserved.

TGT_DIR="$HOME/Desktop/AirItlDebug"
TGT_FILE="$TGT_DIR/Report_$(date '+%Y-%m-%d_%H-%M-%S').log"

AIRPORT_TOOL="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport"

function abort() {
  echo "[ERROR] $1"
  echo "The script will exit in 10 seconds."
  sleep 10
  exit 1
}

function dumpInfo() {
  {
    echo "----- $1 -----"
    echo
    echo "$2"
    echo
  } >> "$TGT_FILE"
}

# Init
if [ -d "$TGT_DIR" ]; then
  read -p "A previous debug report exists. Delete [Y], Exit [N]: " -n 1 -r; echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$TGT_DIR"
  else
    exit 1
  fi
fi

mkdir "$TGT_DIR"

# Check Requirements for Big Sur
DARWIN_VER="$(sysctl -n kern.osrelease)"
DARWIN_MAJOR=${DARWIN_VER%%\.*}

# Check msgbuf value from nvarm on Big Sur and above
if (( $DARWIN_MAJOR >= 20 )); then
  MSGBUF="$(nvram boot-args | grep ' msgbuf=')"
  if [[ -z $MSGBUF ]]; then
    echo 'Please add `msgbuf=1048576` into boot-args using either nvram or your bootloader^s config'
  fi
fi

# Info
echo 'Dumping info from System Report, this may take up to 1 minute...'
{
  BLE_SYSREPORT="$(system_profiler SPBluetoothDataType -detailLevel mini)"
  ITL_KEXTSTAT="$(kextstat -l | grep com.zxystd.itlwm)"
  AIR_KEXTSTAT="$(kextstat -l | grep com.zxystd.AirportItlwm)"
  AIR_SYSREPORT="$(system_profiler SPAirPortDataType -detailLevel basic |
                 sed '/BSSID:.*/d' |
                 sed '/MAC Address:.*'/d |
                 sed '/Current Network Information:*/{n;s/.*//;}')"
  AIR_INFO="$($AIRPORT_TOOL -I | sed '/SSID:.*/d')"
} &> /dev/null

if [ -n "${ITL_KEXTSTAT}" ]; then
  abort 'Please use "Create Diagnostic Report" from HeliPort instead.'
fi

if [[ -z $AIR_KEXTSTAT ]] || [[ -z $AIR_SYSREPORT ]]; then
  abort 'AirportItlwm did not load properly.'
fi

dumpInfo 'Kext Status' "$AIR_KEXTSTAT"
dumpInfo 'Airport Info' "$AIR_INFO"
dumpInfo 'Airport Sys Report' "$AIR_SYSREPORT"
dumpInfo 'Bluetooth Sys Report' "$BLE_SYSREPORT"

read -p "Extract real time Airport Logs? [Y/N]: " -n 1 -r; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -n 'Enter the time period required for your operation (Seconds [0 ~ 1000]): '
  read -r PERIOD
  if [[ ! $PERIOD =~ ^[0-9]+$ ]] ; then
    echo 'Invalid input, skipping log extraction.'
  fi
  sudo "$AIRPORT_TOOL" debug +AllUserland +AllDriver +AllVendor >/dev/null 2>&1
  echo "$PERIOD second(s) countdown has started."
  {
    echo "----- Airport Logs -----"
    echo
    sudo "$AIRPORT_TOOL" logger & sleep "$PERIOD" >/dev/null 2>&1 ; sudo kill $! >/dev/null 2>&1
    echo
  } >> "$TGT_FILE"
fi

echo 'Dumping System Logs, this may take up to 5 minutes...'
SYS_LOGS="$(log show --last boot --info --debug --predicate "(sender=\"IO80211Family\" || sender=\"sharingd\")" |
            perl -0777 -pe "s/(meCard:).*?($(date '+%Y'))/$1 ---MASKED---\\n$(date '+%Y')$2/isg" |
            sed 's/accountForAppleID.*/accountForAppleID ---MASKED---/g')"
ITLWM_LOGS="$(sudo dmesg | grep -i "itlwm" | 
             while read -r line; do
               DMESG_TS="$(echo $line | cut -d '[' -f2 | cut -d ']' -f1 | tr -d ' ')"
               export PLACEHOLDER_TS="${DMESG_TS#*.}"
               LOG_TS="$(perl -mPOSIX -e '@a=split(`sysctl -n kern.boottime | cut -c14-18`);printf POSIX::strftime("%Y-%m-%d %H:%M:%S.$ENV{PLACEHOLDER_TS}%z\n",localtime(time()+$a[0] - $ENV{DMESG_TS}))')"
               PREFIX="$LOG_TS 0x0        Default     0x0                  0      0    "
               echo $line | sed "s/\[.*itlwm/${PREFIX}itlwm/g"
             done
             )"

KERN_LOGS="$SYS_LOGS"
KERN_LOGS+="$ITLWM_LOGS"

                                 # Remove lines that don't start with year
KERN_LOGS="$(echo "$KERN_LOGS" | awk "/^$(date '+%Y')/" | sort)"

dumpInfo 'Kernel Logs' "$KERN_LOGS"

(
  cd "$TGT_DIR" || exit
  zip -q AirItlDebug_"$(date '+%Y-%m-%d_%H-%M-%S')".zip ./*.log >/dev/null 2>&1
  rm -rf ./*.log
)

echo
echo 'Successfully generated debug report.'

open "$TGT_DIR"
