#!/usr/bin/env bash
# HamPi64 (github.com/DaiTengu/HamPi64) — 64-bit port of HamPi for Raspberry Pi OS Trixie / Pi 5.
# Copyright (C) 2026 HamPi64 contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# prepare_image_for_release.sh — de-personalize a BUILT HamPi64 Pi just before you capture its
# SD card as a distributable .img. Run this ON the build Pi (via sudo) as the LAST step, after
# the playbook finishes; then power off and image the card.
#
# It:
#   1) wipes machine identity (SSH host keys, machine-id),
#   2) STRIPS ALL CREDENTIALS the build/flash left behind — Wi-Fi, the build user's password,
#      SSH keys, and the whole cloud-init surface (see below),
#   3) clears build cruft (logs, caches, shell history),
#   4) re-arms Raspberry Pi OS's first-boot wizard so the operator creates their OWN user + Wi-Fi.
#
# ⚠  CREDENTIALS (step 2) are the part that bites: modern Raspberry Pi Imager applies its Wi-Fi /
#    username / password / SSH-key customization via CLOUD-INIT — `$BOOT/user-data` +
#    `$BOOT/network-config`, which get rendered into `/etc/netplan/*` and cached under
#    `/var/lib/cloud`. If any of that survives, the shipped image leaks YOUR Wi-Fi password, the
#    build user's password hash, and an authorized SSH key. Removing only NetworkManager
#    connections (as an earlier version did) is NOT enough.
#
# ⚠  ALWAYS VALIDATE on a spare card after capture: confirm it (a) boots to the piwiz wizard and
#    (b) has no baked Wi-Fi/credentials (`grep -r` your SSID in /boot + /etc + /var/lib/cloud).
#    For a fully reproducible build, prefer pi-gen (see CLAUDE.md → "Building a release image").
#    Do NOT run this on your daily-driver Pi.
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo." >&2; exit 1; }

BOOT=/boot/firmware; [ -d "$BOOT" ] || BOOT=/boot
BUILD_USER=$(getent passwd 1000 | cut -d: -f1 || true)

echo "==> 1/4  Machine identity"
rm -f /etc/ssh/ssh_host_*                          # regenerated on first boot
: > /etc/machine-id                                # regenerated on boot
rm -f /var/lib/dbus/machine-id && ln -sf /etc/machine-id /var/lib/dbus/machine-id

echo "==> 2/4  Credentials — Wi-Fi, passwords, SSH keys, cloud-init"
# NetworkManager Wi-Fi connections + runtime state (saved connections, seen SSIDs, leases)
rm -f /etc/NetworkManager/system-connections/* 2>/dev/null || true
rm -f /etc/wpa_supplicant/wpa_supplicant*.conf 2>/dev/null || true
rm -f /var/lib/NetworkManager/* 2>/dev/null || true
# cloud-init: the NoCloud seed, its rendered netplan, and its cached state (all hold the creds)
rm -f "$BOOT"/user-data "$BOOT"/network-config "$BOOT"/custom.toml "$BOOT"/firstrun.sh \
      "$BOOT"/userconf "$BOOT"/userconf.txt 2>/dev/null || true
rm -rf /var/lib/cloud 2>/dev/null || true
for f in /etc/netplan/*.yaml /etc/netplan/*.yml; do
  [ -e "$f" ] || continue
  if grep -qiE 'access-points|password|wifis|psk' "$f"; then rm -f "$f"; fi   # cloud-init Wi-Fi render
done
# SSH material for every account (authorized_keys, known_hosts, private keys)
rm -rf /root/.ssh
for h in /home/*; do [ -d "$h" ] && rm -rf "$h/.ssh" 2>/dev/null || true; done
# Remove the build user's baked password hash (piwiz sets a fresh one when it renames the account)
if [ -n "${BUILD_USER:-}" ]; then usermod -p '*' "$BUILD_USER" 2>/dev/null || true; fi

echo "==> 3/4  Build cruft (logs, caches, shell history)"
apt-get clean
rm -rf /var/log/* /var/lib/dhcp/* 2>/dev/null || true
journalctl --rotate --vacuum-time=1s 2>/dev/null || true
for h in /root /home/*; do
  [ -d "$h" ] || continue
  rm -f "$h/.bash_history" 2>/dev/null || true
  rm -rf "$h/.cache" "$h/.local/share/keyrings" 2>/dev/null || true
done

echo "==> 4/4  Re-arm first-boot user setup (desktop: rpi-first-boot-wizard + piwiz)"
# userconf-pi's rename-user creates the rpi-first-boot-wizard autologin user, writes
# /etc/xdg/autostart/piwiz.desktop (Exec=piwiz), points desktop autologin at the wizard, and
# enables userconfig.service. On first boot piwiz walks the operator through
# username/password/Wi-Fi/locale and renames the UID-1000 user to their choice.
# Catch: completing an Imager first-run leaves userconfig.service MASKED, so unmask it first.
if command -v rename-user >/dev/null 2>&1; then
  systemctl unmask userconfig.service 2>/dev/null || true
  rename-user -f -s        # -f: full wizard (fresh username); -s: set up only, don't reboot
  echo "    re-armed via rename-user — first boot runs the piwiz wizard."
else
  echo "    WARNING: rename-user (userconf-pi) not found. Verify first-boot user setup on a test flash."
fi

# NOTE: do NOT add a rootfs-resize trigger. Raspberry Pi OS Trixie auto-expands the rootfs to fill
# the card natively on first boot (verified on hardware). The classic init=/usr/lib/raspi-config/
# init_resize.sh HANGS on Trixie (it does `findmnt /boot`, but the firmware partition is mounted at
# /boot/firmware) — adding it produces a black screen / no boot.

echo
echo "==> Done. Power off, capture the card as a .img, then FLASH TO A SPARE CARD and confirm it"
echo "    (a) boots to the piwiz wizard and (b) has NO baked Wi-Fi/credentials."
