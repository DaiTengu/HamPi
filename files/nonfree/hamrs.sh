#!/usr/bin/env bash
# HamPi64 (github.com/DaiTengu/HamPi64) — 64-bit port of HamPi for Raspberry Pi OS Trixie / Pi 5.
# Copyright (C) 2020-2024 Dave Slotter, W3DJS (original HamPi); (C) 2026 HamPi64 contributors.
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
#
# HamPi64 — standalone installer for HamRS (closed-source freeware logger).
# Ported from tasks/install_hamrs.yml. Runs as root (system-wide installs); the
# CALLER handles opt-in — either the "HamPi64 Extras" launcher (after you accept
# HamRS's terms) or the gated Ansible task (-e include_nonfree=true). HamRS is
# fetched from the vendor here, on this device, under HamRS's own license.
# HamPi64 does not include or redistribute it.
#
# Copyright (C) 2026 HamPi64 contributors
# SPDX-License-Identifier: GPL-3.0-or-later

HAMRS_VERSION="2.52.0"
HAMRS_URL="https://hamrs-dist.s3.amazonaws.com/hamrs-pro-${HAMRS_VERSION}-linux-arm64.AppImage"
HAMRS_DIR="/opt/hamrs"
HAMRS_APPIMAGE="${HAMRS_DIR}/hamrs.AppImage"

export DEBIAN_FRONTEND=noninteractive
die() { echo "ERROR: $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "must run as root (use sudo)"

echo "==> Installing libfuse2t64 (AppImage runtime)"
apt-get install -y libfuse2t64 || die "apt-get install libfuse2t64 failed"

echo "==> Creating ${HAMRS_DIR}"
install -d -m 0755 "${HAMRS_DIR}" || die "could not create ${HAMRS_DIR}"

echo "==> Downloading HamRS AppImage ${HAMRS_VERSION} (arm64)"
if [ ! -f "${HAMRS_APPIMAGE}" ]; then
  tries=3; delay=10; ok=false
  for ((i=1; i<=tries; i++)); do
    echo "    attempt ${i}/${tries}: ${HAMRS_URL}"
    if wget -q -O "${HAMRS_APPIMAGE}.part" "${HAMRS_URL}"; then
      mv -f "${HAMRS_APPIMAGE}.part" "${HAMRS_APPIMAGE}"; ok=true; break
    fi
    rm -f "${HAMRS_APPIMAGE}.part"
    [ "${i}" -lt "${tries}" ] && { echo "    download failed; retrying in ${delay}s..."; sleep "${delay}"; }
  done
  [ "${ok}" = true ] || die "failed to download HamRS AppImage after ${tries} attempts"
fi
chmod 0755 "${HAMRS_APPIMAGE}"

echo "==> Writing launcher /usr/local/bin/hamrs"
tee /usr/local/bin/hamrs >/dev/null <<'EOF'
#!/bin/sh
exec /opt/hamrs/hamrs.AppImage "$@"
EOF
chmod 0755 /usr/local/bin/hamrs

echo "==> Writing desktop entry /usr/share/applications/hamrs.desktop"
tee /usr/share/applications/hamrs.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=HamRS
Comment=Ham radio logging application
Exec=hamrs
Terminal=false
Type=Application
Categories=HamRadio;
EOF
chmod 0644 /usr/share/applications/hamrs.desktop

echo "==> HamRS ${HAMRS_VERSION} installed."
