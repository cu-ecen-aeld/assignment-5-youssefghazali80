#!/bin/bash
# Script to run QEMU for buildroot (qemu_aarch64_virt_defconfig)
# Host Port 10022 --> QEMU Port 22
# Author: Siddhant Jajoo (modified)

set -e

# Resolve absolute path to repo root (directory containing this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"  # Adjust this if runqemu.sh is inside subdir

ROOTFS="$REPO_ROOT/buildroot/output/images/rootfs.ext4"
KERNEL="$REPO_ROOT/buildroot/output/images/Image"

# Check file existence
if [[ ! -f "$ROOTFS" ]]; then
    echo "❌ rootfs.ext4 not found: $ROOTFS"
    exit 1
fi

if [[ ! -f "$KERNEL" ]]; then
    echo "❌ Kernel image not found: $KERNEL"
    exit 1
fi

# Launch QEMU
qemu-system-aarch64 \
    -M virt \
    -cpu cortex-a53 -nographic -smp 1 \
    -kernel "$KERNEL" \
    -append "rootwait root=/dev/vda console=ttyAMA0" \
    -netdev user,id=eth0,hostfwd=tcp::10022-:22 \
    -device virtio-net-device,netdev=eth0 \
    -drive file="$ROOTFS",if=none,format=raw,id=hd0 \
    -device virtio-blk-device,drive=hd0 \
    -device virtio-rng-pci

