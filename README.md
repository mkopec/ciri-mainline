# ciri-mainline
Google Chromebook Ciri / Lenovo Chromebook Duet Gen 9 (11") is a hybrid laptop / tablet
featuring the Mediatek Kompanio 838 SoC (MT8188) System-on-a-Chip. It runs ChromeOS
with downstream ChromeOS Linux kernel version v6.1.

This repository serves resources about the process of mainlining fixes into upstream
projects (Linux, Mesa etc) to be able to use this device as a regular Linux laptop.

## Layout

| Path | Contents |
| --- | --- |
| [`kernel/`](kernel/) | The Linux branch for Ciri and the upstream status of its patches |
| [`rootfs/`](rootfs/) | System configuration files, installed relative to `/` |
| [`user/`](user/) | Per-user configuration files, installed relative to `$HOME` |
| [`package/`](package/) | The `ciri-support` Debian package and the firmware installer |
| [`userspace.md`](userspace.md) | Status of the userspace changes (Mesa, ffmpeg, libcamera, ...) |
| [`firmware.md`](firmware.md) | Firmware files needed from ChromeOS, and the coreboot work |

## Status

Status of each component with the kernel from [`kernel/`](kernel/).

| Component | Status | Notes |
| --- | --- | --- |
| Display (DSI panel) | Works | Mainline. |
| External display (USB-C DP) | Works | Mainline. |
| Keyboard (detachable base) | Works | Mainline (cros-ec). |
| Touchpad (detachable base) | Works | DT patch posted, see `kernel/`. |
| Touchscreen | Works | Himax HX83102J driver: v5 posted, v6 prepared. |
| Stylus | Works | With the touchscreen driver; needs the libwacom entry and the udev rule in `rootfs/`, not in libwacom. |
| Speakers, headset, microphones | Works | ASoC fixes pending; UCM profile only in `rootfs/`, not in alsa-ucm-conf. |
| DP audio | Works | drm/mediatek patch pending. |
| Wi-Fi, Bluetooth (MT7921) | Works | M.2 E-key power sequencing series by Chen-Yu Tsai, pending. Wi-Fi power saving disabled in `rootfs/`. |
| GPU, OpenGL (Panfrost) | Works | Mesa fix pending for hardware video decode in Chromium. |
| GPU, Vulkan (panvk) | Works | Mali-G57 (v9) support under review in Mesa. |
| Hardware video decode | Partly | H.264 needs a vcodec fix (pending), scaling needs MDP3 fixes (pending). AV1 fails: the driver rejects the AV1 data of the linux-firmware SCP firmware (`vsi size mismatch`). |
| Camera | Partly | ChromeOS camsys driver imported out of tree, open libcamera pipeline handler; not upstreamable as is. |
| Suspend (deep) | Works | Panfrost clock fix pending; the camera drivers need the mtk-smi fix. |
| Thermal throttling | Works | Power allocator DT patch posted, governor set by the udev rule in `rootfs/`. |
| Screen rotation | Works | Accelerometer mount matrix in `rootfs/`; mutter older than 737d8f06 rotates on docking. |
| Boot firmware | Works | coreboot with a LinuxBoot payload, changes under review, see `firmware.md`. |

## Installing

On Debian and derivatives, install the `ciri-support` package from the
[releases](https://github.com/mkopec/ciri-mainline/releases):

```sh
sudo apt install ./ciri-support_*_all.deb
```

It installs the configuration files and runs `ciri-firmware-update`, which
downloads the ChromeOS recovery image for Ciri from Google (about 1.8 GB) and
copies the firmware that is only shipped with ChromeOS out of it. Set
`CIRI_SUPPORT_SKIP_FIRMWARE=1` to skip the download, and run
`sudo ciri-firmware-update` later. The firmware is not included in the package.

On other distributions, copy the files from `rootfs/` to `/` and from `user/`
to `$HOME`, and run `package/ciri-firmware-update` as root.

## License

MIT, see [`LICENSE`](LICENSE).
