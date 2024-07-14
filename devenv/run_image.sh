#!/bin/sh
###/bin/sh -ex

if [ $# -lt 1 ]
then
    echo "Usage: $0 <image name>"
    exit 1
fi

DEVENV_DIR=$(dirname "$0")
DISK_IMG=$1

if [ ! -f $DISK_IMG ]
then
    echo "No such file: $DISK_IMG"
    exit 1
fi

if [ "$QEMU_HOST" = "" ]; then
    cp -p $DEVENV_DIR/OVMF_VARS.fd $DEVENV_DIR/OVMF_DATA.fd
    qemu-system-x86_64 \
        -m 1G \
        -drive if=pflash,format=raw,readonly,file=$DEVENV_DIR/OVMF_CODE.fd \
        -drive if=pflash,format=raw,file=$DEVENV_DIR/OVMF_DATA.fd \
        -drive if=ide,index=0,media=disk,format=raw,file=$DISK_IMG \
        -device nec-usb-xhci,id=xhci \
        -device usb-mouse -device usb-kbd \
        -rtc base=localtime \
        -monitor stdio \
        $QEMU_OPTS
else
    if [ "$QEMU_LOCAL_DIR" = "" -o "$QEMU_REMOTE_DIR" = "" ]; then
        if QEMU_REMOTE_DIR=$(ssh $QEMU_HOST mktemp -dt qemu); then
            scp -p $DEVENV_DIR/OVMF_CODE.fd $DEVENV_DIR/OVMF_VARS.fd $DISK_IMG \
                $QEMU_HOST:$QEMU_REMOTE_DIR
            CLEANUP_REMOTE_DIR=yes
        else
            exit $?
        fi
    else
        cp -p $DEVENV_DIR/OVMF_CODE.fd $DEVENV_DIR/OVMF_VARS.fd $DISK_IMG \
                $QEMU_LOCAL_DIR
        sync
    fi
    ssh $QEMU_HOST '
        . .profile;
        cd '"$QEMU_REMOTE_DIR"';
        qemu-system-x86_64 \
            -m 1G \
            -drive if=pflash,format=raw,readonly=on,file=OVMF_CODE.fd \
            -drive if=pflash,format=raw,file=OVMF_VARS.fd \
            -drive if=ide,index=0,media=disk,format=raw,file='"$DISK_IMG"' \
            -device nec-usb-xhci,id=xhci \
            -device usb-mouse -device usb-kbd \
            -rtc base=localtime \
            -monitor stdio \
            '"$QEMU_OPTS"
    if [ "$CLEANUP_REMOTE_DIR" = yes ]; then
        ssh $QEMU_HOST 'rm -fr '"$QEMU_REMOTE_DIR"
    fi
fi
