# HamPi → Raspberry Pi OS Trixie / Pi 5 Port — Design

**Date:** 2026-07-14
**Repo:** `DaiTengu/HamPi` (fork of `dslotter/HamPi`), branch `trixie-port`
**Status:** Approved design — ready for implementation planning

---

## 1. Goal

Take the HamPi Ansible playbook — which installs ~100 amateur-radio applications onto
Raspberry Pi OS — and make it install cleanly on **64-bit Raspberry Pi OS Trixie
(Debian 13) running on a Raspberry Pi 5**. Along the way: update applications to current
versions, prefer each application's own official distribution channel, modernize the
playbook for current-Debian conventions, and document everything for end users.

The original author (W3DJS) stopped mid-way through a 32→64-bit transition in April 2024.
We are completing and modernizing that transition for a newer OS than he targeted.

## 2. Verified target environment (confirmed on real hardware)

Reference test device (real host/user/key kept in a local, gitignored inventory — not committed; see `inventory/hampi.ini.example`):

| Property | Value |
|---|---|
| OS | Debian 13 **Trixie** (13.5) |
| Kernel / SoC | 6.18.34-rpi-**2712** (BCM2712 → Pi 5) |
| Architecture | **arm64** / 64-bit |
| Model | Raspberry Pi 5 Model B Rev 1.0 |
| Python | **3.13.5** |
| GCC | **14.2.0** |
| Base image | pi-gen reference 2026-06-18 (Raspberry Pi OS Trixie) |
| Desktop | **labwc** (Wayland) present |
| Ansible | **not installed** on the Pi |

Nothing about the target is assumed — all of the above is read off the device.

## 3. Scope & non-goals

**In scope (this effort):**
- Primary target: Raspberry Pi OS Trixie, 64-bit, Pi 5.
- Core-set-first: get ~18 headline apps installing + verified end-to-end (Milestone 1),
  then expand to full parity in themed tranches.
- Modernize the playbook framework (arch facts, build flags, Python packaging, networking,
  desktop, external-dependency hygiene).
- In-repo Markdown documentation.

**Deferred (later phase, not now):**
- Building a distributable `.img`. Deliverable now is a playbook you run against a fresh Pi.
- Full ~100-app parity (comes after the core set is proven).
- Actively maintaining the HamPC (Xubuntu x86) and HamIQ (Inovato armhf) targets. Their
  existing conditionals are left in place but **untested** — we do not add new multi-platform
  logic and do not guarantee those paths.

**Out of scope / dropped:**
- **HamClock** — ignored per project owner instruction (separate migration planned later).
- **rpitx** — Pi 5 moved GPIO to the RP1 chip; no upstream Pi 5 support.
- **RadioExplorer** — Windows application, no native arm64 build.
- **MSHV** — ships an `MSHV_I686.pro` x86 build target; revisit only if upstream provides an
  arm source build.
- **PMON, TeamViewer** — proprietary, no arm64 build.
- **twclock, twhamqth** — upstream websites gone.

## 4. Installation strategy — the tiered rule

Every application is resolved by the **first** tier that yields a working, current arm64
result:

1. **Tier 1 — upstream official arm64 artifact/repo.** The project's own `.deb`, AppImage,
   apt repo, or the install method the project itself documents (e.g. CHIRP's pipx). Current,
   reliable, official. **Preferred.**
2. **Tier 2 — Trixie arm64 apt package**, when it exists and is close enough to current.
   Reliable and arm64-native. This is the default for the large, well-packaged, slow-moving
   apps.
3. **Tier 3 — source build**, fixed for aarch64 / GCC 14. Last resort: only when neither
   above gives a working, current arm64 result.

**Version pinning:** where a tier fetches a versioned artifact, the version lives in an
Ansible **variable**, not an HTML-scrape of the vendor's download page. The original repo's
fragile "curl + grep the site for the latest version" pattern is removed. Bumping a version
becomes a one-line edit.

**"Close enough" rule (Tier 2 vs Tier 3):** on Trixie, apt is fresh enough to be the default.
Drop to Tier 3 (source) only when the Trixie apt version is *meaningfully* behind AND that
gap matters (e.g. rig-model support in flrig/Hamlib, protocol changes in Direwolf, LoTW
compatibility in tqsl). Each such decision is made against the **actual on-device apt
version**, confirmed while writing that task (not assumed here).

## 5. Framework rework (done first — everything rides on it)

1. **`library/set_facts.yml`**
   - Fix the latent bug: `is_arm_64` is currently set `True` for *any* ARM (32-bit included).
     Set it only for `aarch64`.
   - Add `is_trixie` (`ansible_distribution_release == "trixie"` / major version `13`).
   - Tidy the OS/arch fact cascade so Trixie is a first-class release.

2. **Build flags** — remove the 32-bit flags baked into `default/raspbianos.yml`
   (`-march=armv7-a -mfloat-abi=hard -mfpu=neon -mtune=cortex-a72`). For any remaining
   on-device source compile, use `-mcpu=cortex-a76` (Pi 5) — the `-mfloat-abi`/`-mfpu`
   flags do not exist on aarch64 and must be dropped, not translated.

3. **Python packaging (PEP 668).** Python 3.13 on Trixie is externally-managed; drop the
   blunt `--break-system-packages` hack in favor of one consistent pattern:
   - **apt** `python3-*` where Debian packages it (preferred),
   - **pipx** for standalone CLI/GUI Python tools (e.g. CHIRP-next),
   - **venv** (e.g. `/opt/hampi/venv`) for anything else that needs pip.

4. **Networking.** Any dhcpcd / `wpa_supplicant.conf` tasks → NetworkManager keyfiles
   (`/etc/NetworkManager/system-connections/*.nmconnection`) or `nmcli`. dhcpcd is gone on
   Trixie.

5. **Desktop.** Openbox/wayfire assumptions → **labwc** (`~/.config/labwc/{autostart,rc.xml,menu.xml}`);
   taskbar config stays at `~/.config/wf-panel-pi/wf-panel-pi.ini`; wallpaper applied via
   `pcmanfm --set-wallpaper` under Wayland.

6. **Audio.** PipeWire is default on Trixie with Pulse/JACK shims — mostly no change for
   PortAudio/ALSA apps. Install `pipewire-jack` explicitly where a tool links against JACK.

7. **External-dependency hygiene.** Tasks that fetch-and-run build scripts from the original
   author's repos (`dslotter/ham_radio_scripts`, etc.) are removed where we move to apt/upstream.
   For any script we still need, fork it into `DaiTengu` or inline it into the task — the fork
   must not depend on the upstream author's personal repos.

8. **Run mode / inventory.** Primary dev/test loop: run Ansible **from a controller (this box)
   over SSH** to the Pi — matches the existing inventory model, works today,
   no bootstrap on the Pi. The end-user "run on your own Pi" path (install ansible locally,
   run against `localhost`) is supported too. Provide a clean `hosts` inventory + a wrapper
   for both.

9. **GCC 14.** Expect some old, unmaintained C source builds (older SoapySDR modules,
   `hlog`/`libjeffpc`, niche libs) to fail on GCC 14's promotion of
   `-Wimplicit-function-declaration` (and implicit-int, incompatible-pointer-types) to hard
   errors. Fix per-build with `-fpermissive` / `-Wno-error=implicit-function-declaration` or
   an upstream patch. Confirmed on-device: GCC is 14.2.0.

## 6. Optional-apps pattern

Optional / off-by-default / heavy / niche apps are controlled by **variable flags** in a
defaults file, not by commenting out `main.yml` imports. Example:

```yaml
install_wsjtx_improved: true    # default weak-signal client (replaces mainline WSJT-X)
install_wsjtz: false            # opt-in: source build, enable explicitly
```

Enabling a disabled app is a one-line override (or `--extra-vars` / a tag); nothing is lost
in comments, and the on/off state is self-documenting. Every "off by default" app gets this
treatment, replacing the current mess of `###`-commented imports.

## 7. WSJT-X family

- **WSJT-X Improved (DG2YCB)** — Tier 1, upstream official arm64 `.deb`. **Replaces** mainline
  WSJT-X (installs the same `wsjtx` binary). Default variant **`PLUS`** (plain); `AL_PLUS`
  (alerts) and `widescreen_PLUS` selectable via variable. Version pinned as variables:
  ```yaml
  wsjtx_improved_version: "3.1.0"
  wsjtx_improved_build: "260522"
  wsjtx_improved_variant: "PLUS"       # PLUS | AL_PLUS | widescreen_PLUS
  ```
  Asset: `wsjtx-{ver}_improved_{variant}_{build}_Rpi_bookworm_arm64.deb` (the bookworm arm64
  build is the correct one for Trixie — confirm on-device it installs cleanly; a `trixie_arm64`
  build also exists if needed). This removes the old `update_wsjtx_from_src` external-script
  dependency.
- **WSJT-Z (SQ9FVE)** — **disabled by default** (`install_wsjtz: false`). No prebuilt Linux
  packages upstream (Windows-only releases), so Linux is a Tier 3 source build (current
  v2.0.16). Enabled explicitly or installed by hand; documented in the docs.

## 8. Milestones

**Milestone 1 — Core set (framework + ~18 apps, verified end-to-end):**

| App | Tier (plan) | Notes / confirm-on-device |
|---|---|---|
| Hamlib (`libhamlib-utils`, rigctld) | 2 apt | source only if apt materially behind upstream 4.7.2 |
| flrig | 2 apt → maybe 3 | apt may still be 1.x; upstream 2.0.10 — source if so |
| WSJT-X Improved | 1 upstream .deb | v3.1.0 PLUS; replaces WSJT-X |
| JS8Call | 1/3 | apt stale (2.2.0); upstream 2.3.1 — upstream/source |
| JTDX | 2 apt | apt ≈ upstream (2.2.159) |
| fldigi | 2 apt → maybe 3 | source if apt behind upstream 4.2.x |
| flmsg, flamp | 2 apt | |
| GridTracker | 1 upstream .deb | v2.260705.2 arm64 (verified) |
| CHIRP-next | 1 pipx | per upstream ChirpOnLinux |
| Direwolf | 2 apt → maybe 3 | source if apt behind upstream 1.8.1 |
| Xastir | 2 apt | |
| Pat (Winlink) | 1 upstream .deb | v1.0.0 arm64 (GitHub releases) |
| CQRlog / KLog + xlog | 2 apt | |
| TrustedQSL (tqsl) | 2 apt → maybe 1 | upstream 2.8.6 if LoTW currency needed |
| SoapySDR + `soapysdr-module-rtlsdr` + rtl-sdr | 2 apt | consider rtlsdrblog fork for V3/V4 dongles |
| gqrx (`gqrx-sdr`) | 2 apt | |
| gpredict | 2 apt | source for 2.5.1 if apt snapshot too old |
| qsstv | 2 apt | apt ≈ upstream (9.5.8) |

Milestone-1 exit criteria: playbook runs clean against the Pi, every core app launches
on the desktop, rig control + one digital mode + logging verified working.

**Milestone 2+ — Expansion tranches** (each = re-enable/port + verify on device):
SDR drivers (SoapySDR module family, airspy, hackrf, bladeRF, plutosdr…), SDR GUIs
(SDRangel, CubicSDR, SDR++), DMR/digital-voice (qdmr, DMRHost, droidstar, BlueDV),
ADS-B (readsb / dump1090-fa, replacing armhf dump1090), APRS extras, antenna modeling,
morse, satellite/weather (noaa-apt, meteor_decoder), FLDigi suite remainder, misc.
Each tranche adds apps behind flags, tests on hardware, and updates docs.

## 9. Documentation plan (in-repo Markdown, `docs/`)

The upstream wiki is a flat "what's included" list with big gaps. Our `docs/` fills them:

- **Install / first-boot** — flashing Trixie 64-bit, running the playbook (controller and
  local modes), NetworkManager/WiFi, first-boot config.
- **Hardware setup** — CAT/USB-serial rig control, sound-card wiring for digital modes,
  RTL-SDR/SDRplay/HackRF/Airspy dongles, GPS/gpsd, DRAWS/HAT.
- **Per-application config** — menu location, default settings, how to launch, HamPi-specific
  tweaks (not just a link to each upstream's docs).
- **Updating** — the variable-pinned version model; how to bump an app; enabling optional apps.
- **Troubleshooting / FAQ** — entirely absent upstream.

`docs/` is the source of truth; may be mirrored to the fork's GitHub wiki later.

## 10. Testing / verification approach

- Ground truth is the **Trixie Pi 5** — research narrows the risk, the device
  decides pass/fail.
- Per app: install via the playbook, confirm the binary exists, launches, and (for the core
  set) performs its basic function.
- Capture per-app pass/fail so tranches are demonstrably complete, not assumed.
- Apt versions and "apt vs source" calls are confirmed against the device at task-write time
  (per approved decision (b)).

## 11. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Python 3.13 removed 19 stdlib modules (telnetlib, audioop, cgi…) | Per-app import check; shim (e.g. telnetlib3), patch, or newer upstream. Confirmed relevant: Python 3.13.5 on device. |
| GCC 14 promotes implicit-decl warnings to errors | `-fpermissive` / `-Wno-error=…` or upstream patch on affected source builds. Confirmed relevant: GCC 14.2.0. |
| apt package dropped/stale on Trixie | Tiered rule reroutes to upstream (Tier 1) or source (Tier 3); never blocks the port. |
| External build scripts on upstream author's repos disappear | Removed where apt/upstream replaces them; forked/inlined otherwise. |
| Wayland/labwc GUI quirks in older ham apps | XWayland covers most; raspi-config X11 fallback documented if a specific app misbehaves. |

## 12. Open items to resolve during implementation (not blockers)

- Exact Trixie apt versions per core app (confirm on device; drives Tier 2 vs Tier 3).
- Whether JS8Call / TrustedQSL / Direwolf / flrig / fldigi cross the "meaningfully behind"
  line on Trixie apt.
- rtl-sdr: stock Debian `rtl-sdr` vs the `rtlsdrblog` fork (needed for RTL-SDR V3/V4 features).
- Controller-mode inventory details (user/become password handling for the Pi user).
