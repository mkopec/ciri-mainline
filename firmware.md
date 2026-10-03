# Firmware

## Firmware files

| File | Used by | Source |
| --- | --- | --- |
| `mediatek/mt8188/scp_c0.img` | SCP (video decode, MDP3) | linux-firmware (Debian `firmware-mediatek`) |
| `mediatek/sof/sof-mt8188.ri`, `mediatek/sof-tplg/sof-mt8188.tplg` | Audio DSP | linux-firmware (Debian `firmware-mediatek`) |
| `himax_i2chid_1002.bin` (BOE panel), `himax_i2chid_1003.bin` (IVO panel) | Touchscreen | ChromeOS only |
| `mediatek/mt8188/scp-dual.img` | Camera (SCP dual core) | ChromeOS only |

The ChromeOS-only files are not redistributable here. Copy them from the root
filesystem of a ChromeOS recovery image for Ciri (`/lib/firmware/`).

The touchscreen controller has no flash; the driver loads its firmware when it
probes, which happens in the initramfs. Install
`rootfs/etc/initramfs-tools/hooks/himax-fw` so the firmware is copied there,
and run `update-initramfs -u`.

The panel, and with it the touchscreen firmware, depends on the SKU: the
`firmware-name` property in the device tree selects the file.

## Boot firmware

Ciri boots from coreboot with a LinuxBoot payload (Linux and u-root) that
kexecs into the GRUB configuration of the installed system. The changes are
under review on [review.coreboot.org](https://review.coreboot.org/q/owner:michal%2540nozomi.space):

| Change | Subject | Status |
| --- | --- | --- |
| 95852 | lib/fit_payload: Specify cell sizes of the /firmware node | Merged |
| 95853-95859 | payloads/external/LinuxBoot: Linux 7.x, FIT image generation, devicetrees from the kernel source, u-root builds | Under review |
| 95860 | payloads/external/LinuxBoot: Kernel config for MediaTek based Chromebooks | Under review |
| 95861 | mb/google/geralt: Initialize the TPM and EC buses without vboot | Under review |
| 95862 | soc/mediatek/mt8188: Enlarge the postram CBFS cache to 8 MiB | Under review |

### VPD

The factory calibration of the speaker amplifiers (`dsm_calib_r0_N`,
`dsm_calib_temp_N`) and of the accelerometer and gyroscope is stored in the
`RO_VPD` region of the stock firmware, which is unique to each device. Keep a
backup of the stock firmware: with CONFIG_VPD, coreboot exposes an `RO_VPD`
region, and the VPD from the backup can be copied into it before flashing:

```sh
cbfstool stock.rom read -r RO_VPD -f ro-vpd.bin
# The stock region is 32 KiB, ours 16 KiB; the data only takes a few KiB.
truncate -s 16K ro-vpd.bin
cbfstool coreboot.rom write -r RO_VPD -f ro-vpd.bin
```

The region is preserved on updates. Linux shows the keys in
`/sys/firmware/vpd/ro/`, and the `ciri-speaker-calibration` service applies
the speaker calibration at boot, like `sound_card_init` on ChromeOS. Without
it, the amplifiers run at a 11 dB lower digital volume.
