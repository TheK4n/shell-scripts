#!/usr/bin/env bash

die() {
    echo "$0: Error: $1" >&2
    exit $2
}

_is_registered_in_fstab_by_uuid_and_mountpoint() {
    grep "$1" /etc/fstab &>/dev/null && return 0 || return 1
}

_create_symbolic_link_to_home() {
    mkdir ~/media

    DEVICE_LABEL="$(lsblk -no LABEL "$1")"

    if [ -n "$DEVICE_LABEL" ]; then
        ln -s "$MOUNTPOINT" "$HOME/media/$DEVICE_LABEL"
    else
        DEVICE_UUID="$2"
        ln -s "$MOUNTPOINT" "$HOME/media/$DEVICE_UUID"
    fi
}

cmd_reg() {

    PATH_TO_DEVICE="$1"
    test -b "$PATH_TO_DEVICE" || die "'$PATH_TO_DEVICE' isn\`t a block device" 1
    DEVICE_UUID="$(lsblk -no uuid "$PATH_TO_DEVICE")"

    FSTAB_STRING="UUID=$DEVICE_UUID /media/$USER/$DEVICE_UUID $(lsblk -no FSTYPE "$PATH_TO_DEVICE") noauto,nofail,users,rw"
    _is_registered_in_fstab_by_uuid_and_mountpoint "UUID=$DEVICE_UUID /media/$USER/$DEVICE_UUID" || (
        MOUNTPOINT="/media/$USER/$DEVICE_UUID"
        sudo mkdir -p "$MOUNTPOINT"
        sudo chgrp "$USER" "/media/$USER" "$MOUNTPOINT"
        sudo chmod g+rx "/media/$USER" "$MOUNTPOINT"

        _create_symbolic_link_to_home "$PATH_TO_DEVICE" "$DEVICE_UUID"

        echo "$FSTAB_STRING" | sudo tee --append /etc/fstab >/dev/null
        sudo systemctl daemon-reload
    )
}

cmd_mount() {
    test -b "$1" || die "'$1' isn\`t a block device" 1
    DEVICE_UUID="$(lsblk -no uuid "$1")"
    _is_registered_in_fstab_by_uuid_and_mountpoint "UUID=$DEVICE_UUID /media/$USER/$DEVICE_UUID" && (
        MOUNTPOINT="$(lsblk -no MOUNTPOINT "$1")"
        if [ -z "$MOUNTPOINT" ]; then
            mount "$1"
        else
            die "'$1' already mounted in $MOUNTPOINT" 3
        fi
    )
}

cmd_umount() {
    test -b "$1" || die "'$1' isn\`t a block device" 1
    DEVICE_UUID="$(lsblk -no uuid "$1")"
    _is_registered_in_fstab_by_uuid_and_mountpoint "UUID=$DEVICE_UUID /media/$USER/$DEVICE_UUID" && (
        MOUNTPOINT="$(lsblk -no MOUNTPOINT "$1")"
        if [ -n "$MOUNTPOINT" ]; then
            umount "$1"
        else
            die "'$1' isn\`t mounted in $MOUNTPOINT" 4
        fi
    )
}

cmd_help() {
    echo -e "mount\numount\nreg\nunreg"
}


case "$1" in
    mount) shift;            cmd_mount  "$@" ;;
    umount) shift;           cmd_umount  "$@" ;;
    reg) shift;              cmd_reg  "$@" ;;
    unreg) shift;            cmd_unreg  "$@" ;;
    *)                       cmd_help    "$@" ;;
esac
exit 0
