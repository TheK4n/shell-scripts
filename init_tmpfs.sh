IMAGE_NAME=.tmp/test.img


die() {
    echo "$@" >&2
    exit 1
}


yesno() {
	[[ -t 0 ]] || return 0
	local response
	read -r -p "$1 [y/N] " response
	[[ $response == [yY] ]] || die "Aborted"
}


test -e $IMAGE_NAME && yesno "[?] Reinitialize?"

sudo umount mnt .tmp
sudo rm -rf mnt .tmp

mkdir mnt .tmp

sudo mount -t tmpfs -o size=2G tmpfs .tmp

dd if=/dev/zero of="$IMAGE_NAME" bs=1024M count=1
mkfs.ext4 "$IMAGE_NAME"
sudo mount -t ext4 -o loop "$IMAGE_NAME" mnt
sudo chown $USER mnt
