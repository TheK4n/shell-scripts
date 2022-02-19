dd if=/dev/zero of=1 bs=128M count=1
dd if=/dev/zero of=2 bs=128M count=1

mkfs.ext4 1
mkfs.ext4 2


# create the loopback block device 
# where 7 is the major number of loop device driver, grep loop /proc/devices
sudo mknod /dev/fake-d1 b 7 200
sudo mknod /dev/fake-d2 b 7 201


sudo losetup /dev/fake-d1 1
sudo losetup /dev/fake-d2 2

# create raid
sudo mdadm --create /dev/md1 --level=1 --raid-devices=2 /dev/fake-d1 /dev/fake-d2

#losetup -d /dev/fake-d1 && rm /dev/fake-d1 && rm /dev/loop200
#losetup -d /dev/fake-d2 && rm /dev/fake-d2 && rm /dev/loop201
