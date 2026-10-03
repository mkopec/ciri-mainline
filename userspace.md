# Userspace

| Project | Change | Status |
| --- | --- | --- |
| Mesa | panvk: Mali-G57 (Valhall v9, job manager) support | Under review (MR !40244) |
| Mesa | panvk: v9 performance work, transform feedback, multi-draw-indirect | Local |
| Mesa | panfrost: don't convert MTK tiled images bound by the detile shader; fixes Chromium crashing on hardware video decode | Prepared, not sent |
| Mesa | panfrost: handle the no-batch case in `panfrost_blitter_clear` | Prepared, not sent |
| ffmpeg | MediaTek MM21 CAPTURE format, `scale_v4l2m2m` filter, AV1 tile starts in MI units | Local, on top of Jonas Karlman's v4l2-request series |
| libcamera | gc05a2/gc08a3 gain model fix | Prepared, not sent |
| libcamera | `mtk-isp7` pipeline handler and IPA for the camsys driver | Local; needs the kernel camera driver upstream first |
| alsa-ucm-conf | `sof-mt8188_m983` profile (MAX98390 speakers, RT5682S headset) | Only in `rootfs/` |
| systemd | Accelerometer mount matrix for Ciri (`60-sensor.hwdb`) | Only in `rootfs/` |
| mutter | Reset to the logical normal orientation (737d8f06); without it the screen turns 90 degrees when the keyboard is attached | Upstream; backport needed for mutter 50.5 |

## Configuration

- Chromium uses the hardware video decoder with the flags in
  `rootfs/etc/chromium.d/v4l2.conf`, with the GL (ANGLE GL) backend. With the
  Vulkan backend, Chromium decodes video in software.
- `user/.config/wireplumber/wireplumber.conf.d/51-ciri-disable-pro-audio.conf`
  disables the Pro Audio profile, which floods the kernel log with ASoC errors.
