# HamPi (Trixie / Pi 5) — TODO / Roadmap

Deferred items, captured so they aren't lost. Nothing here blocks the current build.

## Apps to add later (by group)
- **DMR programming**: qdmr, dmrconfig — ✅ done (apt). Digital-voice clients deferred (see "Digital voice" below; low priority).
- **Morse / training**: cw/cwcp/xcwcp, aldo, ebook2cw, qrq, morse2ascii, etc.
- **Logging extras**: PyQSO, tlf, tucnak, wsjtx-to-n3fjp
- **WinLink extras**: Patmenu2, ARDOP (piardopc) — were 32-bit-only before; need arm64 sources
- **APRS extras**: aprsdigi, aprx, soundmodem, YAAC
- **Weather / imaging**: noaa-apt ✅ done (arm64 prebuilt). Deferred: **medet** (Meteor-M LRPT) — x86-only inline asm in `tim.pas` won't build on aarch64; **wxtoimg** — armhf abandonware. Consider **SatDump** (modern, arm64, multi-satellite) to replace both.
- Remaining apps from the original playbook, added and tested one group at a time

## Not in Trixie apt — need source/upstream builds
- **SDRangel**, **SDR++** (SDR GUIs) — build from source or Flatpak
- **readsb** / **dump1090-fa** (modern ADS-B; replaces the dead armhf dump1090)

## Version bumps (apt is behind upstream)
- **JS8Call**: apt 2.2.0 → upstream 2.3.1
- **Direwolf**: apt 1.7 → upstream 1.8.1

## Optional / opt-in
- **WSJT-Z** (`install_wsjtz`): disabled by default; source-build task not yet written
- **Zenith** satellite tracker + APRS: feasible on the Pi (PHP web app + `zenith_aprs`
  Python↔AGWPE bridge to Direwolf). **Skipped for now** — trial the hosted version
  (web.zenithtracker.org) first to decide if it earns a place in the image. gpredict +
  Xastir already cover satellite + APRS.

## Digital voice (deferred — low priority)
- **DroidStar** (D-STAR/DMR/YSF/P25/NXDN/M17 client, Qt6/CMake) — **blocked on Trixie**: its
  CMake `find_package(Qt6 ... CorePrivate)` fails because Debian's `qt6-base-private-dev` ships
  the private headers but *not* the `Qt6CorePrivate` CMake config (qtbase private modules only).
  Revisit via a CMake shim, a `find_package` patch + manual private include path, or upstream fix.
- **md380 software AMBE vocoder (arm64)** — groundwork **done & working** (DroidStar needs it for
  DMR/AMBE audio; the original `md380_vocoder` is 32-bit-only). Recipe: deps
  `git cmake g++ xxd unzip python3 libboost-dev`; clone `nostar/md380_vocoder_dynarmic`; then
  `cd build && cmake .. && make && sh ../makelib.sh` → `build/libmd380_vocoder.a` (self-contained,
  bundles dynarmic/zydis/fmt/mcl); install the `.a`→/usr/local/lib and `md380_vocoder.h`→/usr/local/include.
- **BlueDV** — needs an AMBE hardware dongle + AMBEServer; beta distribution. Defer.
- **DMRHost / dmrlink / brandmeister** — DMR hotspot/network (needs MMDVM hardware). Defer.

## Not viable on Pi (arm64)
- **SkyRoof** — Windows-only (.NET/DirectX)
- **rpitx** — Pi 5 moved GPIO to the RP1 chip; no upstream support
- **MSHV** (x86 build target), **RadioExplorer** (Windows app), **PMON / TeamViewer** (proprietary, no arm64)

## Release / packaging (later milestone)
- Run the playbook against a **clean, freshly-flashed** Trixie image (not the dev Pi) and
  confirm a from-scratch build works.
- Capture the result as a distributable `.img` (shrink, or a pi-gen build).
- **License check**: confirm the SDRplay API terms allow redistribution inside a shared image.
- Decide the image's default-user model (currently `ham_user` = the connecting user).
