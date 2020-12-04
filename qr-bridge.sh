#!/bin/zsh
echo Setting tap interface
ip tuntap add mode tap tap0
ip link set dev tap0 up

echo Setting up bridge interface
brctl addbr br0
brctl addif br0 enp0s17 tap0
ip link set dev br0 up

echo Setting address: remove ip appdress from enp0s17
ip addr flush dev enp0s17
echo Setting address: add ip address to br0
ifconfig br0 192.168.1.42 netmask 255.255.255.0

echo Setting routing table
ip route add default via 192.168.1.1 dev br0
ip route del default via 192.168.1.1 dev enp0s17




qemu-system-arm \
	-M virt \
	-cpu cortex-a15 \
	-m 1024 \
	-append "console=ttyAMA0,115200 root=/dev/vda rootwait" \
	-kernel iotgoat-armvirt-32.zImage \
	-hda iotgoat-armvirt-32-root.squashfs \
	-device virtio-net-pci,netdev=lan \
	-netdev tap,id=lan,ifname=tap0,script=no,downscript=no \
	-nographic

echo Setting tap down
ip link set dev tap0 down

echo Setting address: remove ip adress from br0
ip addr flush dev br0
brctl delif br0 enp0s17 tap0
ip link set br0 down
brctl delbr br0

echo Setting address: add ip address to enp0s17
ifconfig enp0s17 192.168.1.42 netmask 255.255.255.0
ip tuntap del mode tap dev tap0

