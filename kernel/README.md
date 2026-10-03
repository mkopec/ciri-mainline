# Linux

The kernel for Ciri is the
[`ciri-full`](https://github.com/mkopec/linux/tree/ciri-full) branch of
`mkopec/linux`: v7.3-rc4 with the patches below.

```sh
git clone -b ciri-full https://github.com/mkopec/linux.git
```

## Patches

| Patches | Upstream status |
| --- | --- |
| M.2 E-key power sequencing (Chen-Yu Tsai), Wi-Fi/BT on Geralt | Pending, by the author |
| Input: himax_hx83112b: HX83102J support (Dmitry Mastykin) | Pending, by the author; not needed by Ciri (I2C variant) |
| ASoC: mediatek: card probe and topology name fixes, UL8 constraints; hdmi-codec: empty ELD | Prepared, not sent |
| drm/mediatek: dp: audio while no sink is connected | Prepared, not sent |
| drm/panfrost: unprepare clocks on suspend, MT8188 GPU timestamp | Prepared, not sent |
| media: mediatek: vcodec: extended H.264 VSI on MT8188 | Prepared, not sent |
| media: mtk-mdp3: GCE power, RSZ merge switch on MT8188 | Prepared, not sent |
| arm64: dts: mt8188-geralt: Enlarge SCP core0 memory region (Justin Yeh) | In the MediaTek tree (`v7.3-next/dts64`) |
| arm64: dts: mt8188: SCP core 1 reservation, power allocator, touchpad | [Posted](https://lore.kernel.org/all/?q=s%3A%22SCP+memory%2C+thermal+and+touchpad+fixes%22) |
| Himax HX83102J touchscreen: binding, driver, Ciri devicetree | [v5](https://lore.kernel.org/all/20261003142741.48634-1-michal@nozomi.space/) posted, v6 prepared |
| LOCAL: drm/mediatek: merge: raise the prefetch data rate limit | Local workaround, not for upstream |
| Camera: ISP 7.1 camsys, imgsys and AIE drivers imported from ChromeOS, mtk-smi larb clamp/reset, fixes | Out of tree; waits for MediaTek's upstream camsys series |
| Camera devicetree for Ciri: SCP core 1 region as a DMA pool, imgsys and AIE left disabled | Out of tree, with the camera drivers |

## Kernel configuration

Besides the MT8188 platform drivers, Ciri needs:

| Option | For |
| --- | --- |
| `CONFIG_HID_HIMAX=m` | Touchscreen |
| `CONFIG_I2C_HID_OF=m` | Touchpad |
| `CONFIG_DRM_PANEL_HIMAX_HX83102` | Panel |
| `CONFIG_DRM_PANFROST` | GPU |
| `CONFIG_SND_SOC_MT8188_MT6359`, `CONFIG_SND_SOC_SOF_MT8186` | Audio (SOF) |
| `CONFIG_VIDEO_MEDIATEK_VCODEC`, `CONFIG_VIDEO_MEDIATEK_MDP3` | Video decode and scaling |
| `CONFIG_MT7921E` | Wi-Fi |

The touchscreen driver loads its firmware early, from the initramfs. The
`ciri-support` package installs the firmware and an initramfs hook for it, see
[`../firmware.md`](../firmware.md).
