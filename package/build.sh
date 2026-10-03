#!/bin/sh
# Build the ciri-support package from the files in rootfs/ and user/.
#
#   package/build.sh [version] [output directory]
#
# The version defaults to one derived from git describe.
set -eu

top=$(cd "$(dirname "$0")/.." && pwd)
version=${1:-$(git -C "$top" describe --tags --always 2>/dev/null | sed 's/^v//; s/-/+/g')}
out=${2:-$top/dist}
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT

install_file() {
	install -D -m "$3" "$top/$1" "$stage/$2"
}

# Vendor locations, so that files in /etc can still override them.
install_file rootfs/etc/udev/hwdb.d/61-ciri-accel.hwdb \
	usr/lib/udev/hwdb.d/61-ciri-accel.hwdb 644
install_file rootfs/etc/udev/rules.d/60-cpu-thermal-power-allocator.rules \
	usr/lib/udev/rules.d/60-cpu-thermal-power-allocator.rules 644
install_file rootfs/etc/udev/rules.d/90-ciri-stylus-rotation.rules \
	usr/lib/udev/rules.d/90-ciri-stylus-rotation.rules 644
install_file rootfs/etc/libwacom/google-ciri-hxtp.tablet \
	usr/share/libwacom/google-ciri-hxtp.tablet 644
install_file rootfs/etc/NetworkManager/conf.d/99-ciri-wifi-no-powersave.conf \
	usr/lib/NetworkManager/conf.d/99-ciri-wifi-no-powersave.conf 644
install_file rootfs/etc/initramfs-tools/hooks/himax-fw \
	usr/share/initramfs-tools/hooks/ciri-himax-fw 755
install_file user/.config/wireplumber/wireplumber.conf.d/51-ciri-disable-pro-audio.conf \
	usr/share/wireplumber/wireplumber.conf.d/51-ciri-disable-pro-audio.conf 644
for f in "$top"/rootfs/usr/share/alsa/ucm2/conf.d/sof-mt8188_m983/*; do
	install -D -m 644 "$f" \
		"$stage/usr/share/alsa/ucm2/conf.d/sof-mt8188_m983/$(basename "$f")"
done

# Chromium only reads its flags from /etc.
install_file rootfs/etc/chromium.d/v4l2.conf etc/chromium.d/ciri-v4l2 644

install_file package/ciri-firmware-update usr/sbin/ciri-firmware-update 755
install_file README.md usr/share/doc/ciri-support/README.md 644
install_file firmware.md usr/share/doc/ciri-support/firmware.md 644
install_file package/copyright usr/share/doc/ciri-support/copyright 644
{
	echo "ciri-support ($version) unstable; urgency=medium"
	echo
	echo "  * Built from $(git -C "$top" rev-parse --short HEAD 2>/dev/null || echo unknown)."
	echo
	echo " -- Michał Kopeć <michal@nozomi.space>  $(date -R -d "@${SOURCE_DATE_EPOCH:-$(git -C "$top" log -1 --format=%ct 2>/dev/null || date +%s)}")"
} | gzip -n9 > "$stage/usr/share/doc/ciri-support/changelog.gz"
chmod 644 "$stage/usr/share/doc/ciri-support/changelog.gz"

mkdir -p "$stage/DEBIAN"
sed "s/@VERSION@/$version/" "$top/package/DEBIAN/control.in" > "$stage/DEBIAN/control"
install -m 755 "$top/package/DEBIAN/postinst" "$top/package/DEBIAN/postrm" "$stage/DEBIAN/"
(cd "$stage" && find etc -type f | sed 's|^|/|') > "$stage/DEBIAN/conffiles"
size=$(du -sk --exclude=DEBIAN "$stage" | cut -f1)
echo "Installed-Size: $size" >> "$stage/DEBIAN/control"

mkdir -p "$out"
dpkg-deb --root-owner-group -Zxz --build "$stage" "$out/ciri-support_${version}_all.deb"
