mkdir tmp mnt
sudo mount -t tmpfs -o size=2G tmpfs tmp

dd if=/dev/zero of=tmp/test.img bs=1024M count=1
mkfs.ext4 tmp/test.img
sudo mount -t ext4 -o loop tmp/test.img mnt
