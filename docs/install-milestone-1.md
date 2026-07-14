# HamPi (Trixie / Pi 5) — Milestone 1 Install

> **Status:** Milestone 1 — the core amateur-radio app set on 64-bit Raspberry Pi OS
> **Trixie** (Raspberry Pi 5).
> The public **release will be a prebuilt, flashable image** — flash with Raspberry Pi
> Imager, boot, done. This page documents the **builder** workflow used to *produce* that
> system; end users won't run any of this.

## What Milestone 1 installs

**From Trixie apt (arm64):** Hamlib (`rigctl`/`rigctld`) + flrig, fldigi + flmsg + flamp,
JTDX, Direwolf, Xastir, CQRlog + KLog + xlog, TrustedQSL (`tqsl`), SoapySDR + all driver
modules + rtl-sdr, GQRX, Gpredict, QSSTV, CHIRP (`chirpw`), JS8Call.

**From each project's official arm64 `.deb`:** WSJT-X Improved (DG2YCB — replaces mainline
WSJT-X), GridTracker 2, Pat (Winlink).

## Prerequisites

- A Raspberry Pi 5 running **64-bit Raspberry Pi OS Trixie** (Debian 13). Flash
  "Raspberry Pi OS (64-bit)" with Raspberry Pi Imager; enable SSH and create your user.
- The Pi user needs **passwordless sudo** (or supply a become password to Ansible).
- A **controller** machine with **Ansible ≥ 2.12** and SSH access to the Pi.

## Setup

1. Clone this repo on the controller; check out the `trixie-port` branch.
2. Create your inventory from the example (the real file is gitignored):
   ```bash
   cp inventory/hampi.ini.example inventory/hampi.ini
   # edit inventory/hampi.ini: set your Pi's hostname/IP, user, and SSH key path
   ```
3. Make sure `ansible-playbook` is on your PATH (activate your Ansible venv if you use one).

## Run

```bash
./run_trixie
```

This runs `tasks/hampi_trixie.yml` against the `hampi` inventory group. Expect `failed=0`;
a second run is idempotent (`changed=0`).

## Feature flags

Set in `inventory/group_vars/hampi.yml` (or pass `--extra-vars`):

| Flag | Default | Effect |
|---|---|---|
| `install_wsjtx_improved` | `true`  | WSJT-X Improved (replaces mainline WSJT-X) |
| `install_gridtracker`    | `true`  | GridTracker 2 |
| `install_pat`            | `true`  | Pat (Winlink) |
| `install_wsjtz`          | `false` | WSJT-Z (source build; later tranche) |

Upstream `.deb` versions are pinned in the same file (`wsjtx_improved_*`,
`gridtracker_version`) — bump them in one place.

## Verify

```bash
ssh <pi-user>@<pi-host> 'for b in rigctl flrig fldigi flmsg flamp jtdx direwolf xastir \
  cqrlog klog xlog tqsl SoapySDRUtil rtl_test gqrx gpredict qsstv chirpw js8call wsjtx pat gridtracker2; do
  command -v "$b" >/dev/null && echo "OK $b" || echo "MISS $b"; done'
```

All 22 should report `OK`.

## Notes

- CHIRP's GUI binary is **`chirpw`** (CLI is `chirpc`); the apt package is `chirp`
  (a recent chirp-next build).
- WSJT-X Improved shares an icon file with `wsjtx-data` (required by JTDX/JS8Call); it's
  installed with `--force-overwrite` so all three coexist.
- **js8call** is the apt baseline (2.2.0); a later tranche can move it to the current
  upstream 2.3.1. Same for Direwolf (apt 1.7 vs upstream 1.8.1).
- Milestone 2+ adds the remaining ~80 apps in themed tranches, then a packaging milestone
  captures the release image.
