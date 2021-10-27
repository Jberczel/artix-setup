#/bin/sh

# This is an auto-install script for artix linux
# DO NOT RUN unless you're okay with deleting your entire /dev/sda

# Create partitions for BOOT (1GB), ROOT (30GB), HOME (remaining disk space)
cat <<EOF | fdisk /dev/sda
o
n
p


+1G
n
p


+30G
n
p



w
EOF

# Create filesystems
yes | mkfs.ext4 /dev/sda3
yes | mkfs.ext4 /dev/sda2
yes | mkfs.ext4 /dev/sda1
mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/home
mount /dev/sda1 /mnt/boot
mount /dev/sda3 /mnt/home

# Run base install scripts
basestrap /mnt base base-devel runit elogind-runit vim

# Install Linux kernel
basestrap /mnt linux linux-firmware

# Configure fstab (mount partitions after reboot)
fstabgen -U /mnt >> /mnt/etc/fstab

# Configure base artix system
artix-chroot /mnt bash <<EOF
pacman --noconfirm --needed -S networkmanager networkmanager-runit

# Setup NetworkManager to run on start up
ln -s /etc/runit/sv/NetworkManager /etc/runit/runsvdir/current

ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US ISO-88590-1" >> /etc/locale.gen
locale.gen

echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Setup bootloader
pacman --noconfirm --needed -S grub && grub-install --recheck /dev/sda && grub-mkconfig -o /boot/grub/grub.cfg

pacman --noconfirm --needed -S dialog
dialog --no-cancel --inputbox "Enter a name for your computer." 10 60 2> compname
mv compname /etc/hostname

echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts

# TODO
# passwd
EOF

# TODO
# umount and reboot prompts?!?







