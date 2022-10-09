
test -z "$1" && exit 1

PATH_TO_DEVICE="$1"

test -b "$PATH_TO_DEVICE" || exit 1

DEVICE_UUID="$(lsblk -no uuid "$PATH_TO_DEVICE")"

MOUNTPOINT="/media/$USER/$DEVICE_UUID"


sudo mkdir -p "$MOUNTPOINT"
mkdir ~/media
ln -s "$MOUNTPOINT" "$HOME/media/$(lsblk -no LABEL "$PATH_TO_DEVICE")"



FSTAB_STRING="UUID=$DEVICE_UUID /media/$USER/$DEVICE_UUID $(lsblk -no FSTYPE "$PATH_TO_DEVICE") noauto,nofail,users,rw"

grep "$FSTAB_STRING" /etc/fstab || \
echo "$FSTAB_STRING" | sudo tee --append /etc/fstab
sudo systemctl daemon-reload

mount "$MOUNTPOINT"

