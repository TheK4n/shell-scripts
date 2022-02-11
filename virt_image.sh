dd if=/dev/zero of=test.img bs=1024M count=1
mkfs.ext4 test.img
sudo mount -t auto -o loop test.img /mnt
