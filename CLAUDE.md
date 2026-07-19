# HamPi64 — guide for contributors (and AI assistants)

HamPi64 is a 64-bit fork of Dave Slotter's (W3DJS) **HamPi**: an Ansible playbook that turns a
Raspberry Pi 5 running Raspberry Pi OS **"Trixie"** (Debian 13, aarch64) into a ready-to-use
amateur-radio workstation. Licensed **GPL-3.0-or-later** and shared as-is ("works for me"); contributions are welcome via fork + pull request.

This file orients a new contributor — human or AI — to how the repo is built and the conventions
to follow.

## Layout

- `tasks/hampi_trixie.yml` — the master playbook; it `import_playbook`s one file per app/group.
- `tasks/install_<app>.yml` — one installer per app (`install_<group>.yml` for apt bundles).
- `library/set_facts.yml` — arch/OS facts. `tasks/configuration_tasks.yml` — base config.
- `files/` — payloads copied onto the image (configs, launchers, patches, the non-free scripts).
- `inventory/hampi.ini` — your target Pi over SSH (copy from `hampi.ini.example`).
- `docs/coverage.md` — what's installed vs not (incl. the "Not in HamPi64" list); `docs/TODO.md` — roadmap.
- `CHANGELOG.md`, `LICENSE` (GPLv3), `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`.

## Running it

Controller mode — Ansible runs on your workstation and configures the Pi over SSH:

```
ansible-playbook -i inventory/hampi.ini tasks/hampi_trixie.yml
```

`--tags <name>` runs one app; `--syntax-check` validates without running.

## How installs are chosen (tiered — prefer the earliest that works)

1. **Trixie apt** — if the package exists and works on aarch64 (maintained, signed).
2. **Official upstream arm64 prebuilt** (`.deb` / AppImage) — if apt is missing or too stale.
3. **Source build** — last resort; keep any GCC 14 / Qt / aarch64 patches in `files/`.

## Adding an app

Create `tasks/install_<app>.yml` as its own play and add one `import_playbook` line to
`tasks/hampi_trixie.yml`. Every new file starts with this header:

```
# HamPi64 (github.com/DaiTengu/HamPi64) — 64-bit port of HamPi for Raspberry Pi OS Trixie / Pi 5.
# Copyright (C) 2020-2024 Dave Slotter, W3DJS (original HamPi); (C) 2026 HamPi64 contributors.
# SPDX-License-Identifier: GPL-3.0-or-later
```

A typical play: `hosts: hampi`, `become: yes`, a `tags:` matching the app, idempotent tasks
(use `creates:` / `state: present`).

## Non-free / patent-encumbered software

**Do not bake proprietary or patent-encumbered software into the image.** Gate its play:

```
- name: Deferred non-free — skip unless include_nonfree=true
  meta: end_play
  when: not (include_nonfree | default(false) | bool)
```

Put the real install in a shared `files/nonfree/<app>.sh` that the **HamPi64 Extras** launcher
runs on the user's own device, under the vendor's license (or bake with `-e include_nonfree=true`).
See `tasks/install_sdrplay.yml` + `tasks/install_nonfree_installer.yml` for the pattern.

## Username-agnostic image

The shipped image has **no fixed user** — the person who flashes it picks their username on first
boot (Raspberry Pi Imager, or the on-device wizard). So **never install into a specific user's
home** at build time. Instead:

- **System-wide** (`/usr`, `/opt`, `/usr/local`) for the app itself — most tasks already do this.
- **`/etc/skel/`** for per-user default files/config — Pi OS copies it into each new user's home
  when the account is created. If an app needs a writable per-user copy, ship the template in
  `/etc/skel` and have the launcher self-heal `~/…` from it (see `tasks/install_lopora.yml`).

`ham_user` (= the connecting/admin user) is used only to grant that admin dialout/plugdev + sudo;
it is NOT a place to install files.

## Building a release image

Two paths:

1. **Golden image (matches the tooling here):** run the playbook against a fresh Trixie Pi
   (non-free excluded by default), then run `packaging_utilities/prepare_image_for_release.sh` on
   that Pi to de-personalize it and re-arm first-boot user creation. Power off, capture the card as
   a `.img`, and **validate by flashing the capture to a spare card**.
2. **pi-gen (reproducible):** build offline in a chroot — no booted Pi, no user. More setup, but the
   cleanest for repeatable/CI builds. (Not wired up yet; see `docs/TODO.md`.)

## Licensing & attribution

GPL-3.0-or-later. Copyright is **additive** — keep Dave Slotter's (W3DJS) notice and add your own;
never add "all rights reserved". Installed third-party apps keep their own licenses; the GPL here
covers the playbook itself.

## Commits & AI assistance

Conventional, one-line subjects (`feat:`, `fix:`, `docs:` …). HamPi64 is developed with AI
assistance and credits it openly: commits may carry a `Co-Authored-By: Claude …` trailer, and
`CONTRIBUTORS.md` notes the AI-assisted development. Contributions of any kind — human or
AI-assisted — are welcome.

## Testing

- `ansible-playbook --syntax-check tasks/hampi_trixie.yml` before committing playbook changes.
- Run against a real Pi 5. GUI apps can be launch-checked headlessly with `xvfb-run`.
