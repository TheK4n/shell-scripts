
test -z "$1" && exit 1

PATH_TO_DEVICE="$1"
MOUNTPOINT="/media/$USER"


test -b "$PATH_TO_DEVICE" || exit 1

sudo mkdir -p $MOUNTPOINT
ln -s $MOUNTPOINT $HOME/media


DEVICE_UUID="$(lsblk -o uuid "$PATH_TO_DEVICE")"

FSTAB_STRING="UUID=$DEVICE_UUID /media/$USER $(lsblk -o FSTYPE "$PATH_TO_DEVICE" | head -n +2 | tail -n 1) noauto,nofail,users,rw"

grep "$FSTAB_STRING" /etc/fstab || \
echo "$FSTAB_STRING" | sudo tee --append /etc/fstab

mount "$MOUNTPOINT"

