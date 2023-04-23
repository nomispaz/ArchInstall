#!/usr/bin/env bash

args=('--force' '--no-hostonly-cmdline')

all=0
lines=()

if (( all )); then
	lines=(/usr/lib/modules/*)
fi

while read -r line; do
	if [[ "${line}" != */vmlinuz ]]; then
		# triggers when it's a change to dracut files
		all=1
		continue
	fi

	lines+=("/${line%/vmlinuz}")

	pkgbase="$(<"${lines[-1]}/pkgbase")"
	install -Dm644 "/${line}" "/boot/vmlinuz-${pkgbase}"
done

for line in "${lines[@]}"; do
	if ! pacman -Qqo "${line}/pkgbase" &> /dev/null; then
		# if pkgbase does not belong to any package then skip this kernel
		continue
	fi

	pkgbase="$(<"${line}/pkgbase")"
	kver="${line##*/}"
	dracut_restore_img="/usr/lib/modules/${kver}/initrd"

	echo ":: Building initramfs for ${pkgbase} (${kver})"
	dracut --force --hostonly --no-hostonly-cmdline${DRACUT_EXTRA_PARAMS} ${dracut_restore_img} "${kver}"
	install -Dm644 ${dracut_restore_img} "/boot/initramfs-${pkgbase}.img"

    if [[ ${NO_DRACUT_FALLBACK} != "true" ]] ; then
		echo ":: Building fallback initramfs for ${pkgbase} (${kver})"
		dracut --force --no-hostonly${DRACUT_EXTRA_PARAMS} "/boot/initramfs-${pkgbase}-fallback.img" "${kver}"
	fi
done
