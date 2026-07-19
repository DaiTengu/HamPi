# HamPi64 — Coverage Map

_Original HamPi app set vs. the HamPi64 (64-bit Trixie / Raspberry Pi 5) port._
_Regenerated 2026-07-16 from the live `tasks/hampi_trixie.yml` install set._

## Summary

| Status | Count | Meaning |
|---|---|---|
| ✅ Installed | ~130 | Baked into the image (apt, upstream prebuilt, or source build) |
| 🔒 Deferred non-free | 4 | Not baked; installed on demand via **HamPi64 Extras** (see below) |
| 🎛️ Opt-in | 2 | Present but off by default (enable with a flag) |
| ❌ Not included | ~35 | Intentional, not-viable, or deferred — see "Not in HamPi64" |

The marathon port closed almost the entire original gap: SDRangel, DroidStar, MSHV,
hamfax, D-Rats, DXSpider, TR-Log, OpenDV, FreeDV, and dozens more that earlier drafts of
this map listed as "not addressed" are now installed. Several apps the **original** HamPi
had *removed* as broken (SoapyAirspyHF/PlutoSDR, SoapyVOLKConverters, F4HTBPanadapter,
CallRec, TR-Log, OpenDV, SDRangel) build cleanly on Trixie/aarch64 here.

## 🔒 Deferred non-free (installed via HamPi64 Extras, not baked in)

These are proprietary or patent-encumbered, so they are **not** shipped in the image. The
**HamPi64 Extras** launcher installs them on demand, on the user's own device, under each
vendor's license (or bake with `-e include_nonfree=true`). See `tasks/install_nonfree_installer.yml`.

- **SDRplay RSP API** + **SoapySDRPlay3** — proprietary vendor API (SDRplay Ltd).
- **HamRS** — closed-source freeware logger.
- **DroidStar** — GPL app, but uses the patent-encumbered AMBE vocoder (MD-380 firmware).

## 🎛️ Opt-in (present, off by default)

- **WSJT-Z** — `-e install_wsjtz=true` (source build to `/opt/wsjtz`, coexists with WSJT-X Improved).
- **BOINC** — installed but disabled; user enables via `systemctl`.

## ✅ Installed (by category)

**General / rig control:** HamLib (`libhamlib-utils`), grig, wfview (arm64 AppImage, rig-defs
extracted), QTel/SvxLink, splat, D-Rats (source).

**Digital modes & weak-signal:** WSJT-X Improved (DG2YCB .deb), JS8Call, JTDX, GridTracker 2,
gnss-sdr, linpsk (dl1ksv Qt5 fork), multimon-ng, psk31lx, twpsk, FreeDV *(recovered — original
dropped it)*, MSHV *(built on aarch64; original was x86-only)*, acarsdec (+libacars), the full
**FLDigi suite** (fldigi/flrig/flmsg/flamp/flarq/flwrap apt; flcluster/fllog/flnet/flwkey source),
glfer (QRSS), QrssPiG, Fl_MoxGen.

**SDR drivers:** Airspy, AirspyHF, HackRF, LimeSuite, UHD, gr-osmosdr, rtl-sdr, rtl-433,
SoapySDR (+ `soapysdr-module-all`), SoapyAirspyHF *(source; original broken)*, SoapyPlutoSDR
*(source; original broken)*, SoapyVOLKConverters *(source; original broken)*, inspectrum.

**SDR GUIs:** GQRX, CubicSDR, cutesdr, quisk, SDR++ (nightly arm64 .deb), piHPSDR (dl1ycf),
lysdr *(original SKIP)*, leansdr/leandvb *(original SKIP)*, SDRangel *(source; original removed)*,
UHRR (web remote).

**APRS / packet:** Xastir, DireWolf, aprsdigi, aprx, soundmodem, linpac, AX.25 stack
(libax25/ax25-tools/ax25-apps).

**DMR & digital voice:** qdmr, dmrconfig, DMRHost, DMRlink/HBlink3, OpenDV (DStarRepeater)
*(original removed)*, AMBEserver, brandmeister-dmr-sea. *(DroidStar is deferred non-free above.)*

**Logging:** TrustedQSL, CQRlog, KLog, xlog, PyQSO, tlf, tucnak, ADIF Merge (adifmerg), ADIF
Multitool (adifmt), DXSpider (node), SKCCLogger, Ten-Ten QSO Logger, TR-Log *(source; original
BROKEN)*, Reverse Beacon Network client. *(HamRS is deferred non-free above.)*

**Morse / CW:** cw, cwcp, xcwcp, cwdaemon, aldo, qrq, ebook2cw(+gui), morse, morse2ascii,
morsegen, xdemorse, rscw (source), Wordsworth.

**Antenna modeling:** nec2c, xnec2c *(replaces antennavis/gsmc/xnecview)*, yagiuda, flaa,
aa-analyzer, F4HTBPanadapter *(source; original removed)*.

**Satellite / weather:** Gpredict, predict (jj1bdx), noaa-apt (arm64 prebuilt), xwefax, hamfax
*(Qt5 fork; Debian dropped the Qt4 pkg)*, QSSTV.

**Winlink:** Pat (arm64 .deb).

**Training / exam:** fccexam, hamexam.

**Misc / utilities:** VOACAP (voacapl), gnuais/gnuaisgui, GPS (gpsd), Xdx, wwl, twclock
*(recovered)*, readsb+viewadsb *(replaces dump1090)*, CQRprop, Lady Heather, JS8Call Utilities,
WsprryPi ❌ (see below), WireGuard, BOINC (opt-in), Go toolchain, PyBOMBS, CallRec *(source;
original BROKEN)*, build libs (CMake/wxWidgets/RtAudio from apt).

**System / framework:** set_facts, configuration_tasks, install_menus, install_wallpaper,
install_about, upgrade_debian_packages, install_nonfree_installer (HamPi64 Extras).

## ❌ Not in HamPi64 — and why

The programs from the original HamPi/HamPC set that HamPi64 does **not** install:

### Intentionally left out
- **QSLware nag dialog** — the original's "mail me a QSL card" nagware; a GPL fork shouldn't ship the original author's donation nag.
- **HamClock** — upstream owner flagged it dead / "ignore".
- **OpenWebRX** — a full web-SDR server + service; belongs as a deliberate opt-in (like BOINC), not auto-installed. Candidate for a future opt-in flag.
- **Zenith tracker** — trial the hosted version first before earning a place in the image.

### Not viable on Pi 5 / 64-bit ARM
- **rpitx**, **WsprryPi / TAPR WSPR** — Pi 5 moved GPIO to the RP1 chip; no way to key RF out.
- **medet** (Meteor-M LRPT) — x86-only inline asm in `tim.pas`; **SatDump** is the modern aarch64 replacement (candidate to add).
- **wxtoimg** — armhf abandonware, no arm64 build.
- **SkyRoof**, **RadioExplorer** — Windows-only (.NET/DirectX).
- **SparkSDR** — no Raspberry Pi support.
- **TeamViewer**, **PMON** — proprietary, no arm64 build.
- **DRAWS support** — Node.js install path broken.

### Deferred — feasible, just not done yet (candidates for a later pass)
- **YAAC** (Java download), **Patmenu2 / ARDOP (piardopc) / Find ARDOP** (were armhf-only, need arm64 sources), **wsjtx_to_n3fjp**, **BlueDV** (needs an AMBE dongle + AMBEServer), **predict-gsat** (GTK front-end; ncurses `predict` is installed), **fbb** (packet mailbox), **twlog**, **twcw**, **acfax**, **CygnusRFI**, **multimon** (original; `multimon-ng` is installed), **flpost** (upstream dead), **colrconv** (orphaned in Debian), **gcb** (dead upstream), **Pi3/4 Stats Monitor**, **Auto WiFi Hotspot**, **install_bookmarks**, **country-files download** (cty.dat), **APRS Message App for JS8Call**, **Open Wouxun (OWX)**.

### Replaced by a better-maintained tool
- **antennavis / gsmc / xnecview** → **xnec2c**.
- **dump1090** (dead armhf) → **readsb + viewadsb**.
