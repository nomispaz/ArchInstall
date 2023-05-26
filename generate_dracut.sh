#!/bin/bash
#
for kernel in /usr/lib/modules/*
do
v_kernel = $(basename "$kernel")
dracut /boot/initramfs-linux.img --force --kver $v_kernel
dracut /boot/initramfs-linux-zen.img --force --kver $v_kernel
