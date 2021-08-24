#!/bin/bash

if test $# -ne 1; then
    echo "Usage: $0 <kvm_image>" 1>&2
    exit 1
fi

kvm_image="$1"

echo "Starting KVM image $kvm_image mounting ./guest_fs/ ..."
sudo qemu-system-x86_64  -fsdev local,id=myid,path=$(pwd)/guest_fs,security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=rootfs,disable-modern=on,disable-legacy=off \
    -kernel "$kvm_image" \
    -cpu host \
    -enable-kvm \
    -nographic
