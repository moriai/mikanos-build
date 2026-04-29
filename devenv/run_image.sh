#!/bin/sh -ex

if [ $# -lt 1 ]
then
    echo "Usage: $0 <image name>"
    exit 1
fi

DEVENV_DIR=$(dirname "$0")
DISK_IMG="$1"

if [ ! -f "$DISK_IMG" ]
then
    echo "No such file: $DISK_IMG"
    exit 1
fi

QEMU="qemu-system-x86_64"
OVMF_CODE="$DEVENV_DIR/OVMF_CODE.fd"
OVMF_VARS="$DEVENV_DIR/OVMF_VARS.fd"

if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    QEMU_FOR_WIN="/mnt/c/Program Files/qemu/qemu-system-x86_64.exe"
    if [ -x "$QEMU_FOR_WIN" ]; then
        QEMU="$QEMU_FOR_WIN"
        OVMF_CODE="$(wslpath -w $DEVENV_DIR/OVMF_CODE.fd)"
        OVMF_VARS="$(wslpath -w $DEVENV_DIR/OVMF_VARS.fd)"
        DISK_IMG="$(wslpath -w $DISK_IMG)"
    fi
fi

"$QEMU" \
    -m 1G \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$OVMF_VARS" \
    -drive if=ide,index=0,media=disk,format=raw,file="$DISK_IMG" \
    -device nec-usb-xhci,id=xhci \
    -device usb-mouse -device usb-kbd \
    -rtc base=localtime \
    -monitor stdio \
    $QEMU_OPTS
