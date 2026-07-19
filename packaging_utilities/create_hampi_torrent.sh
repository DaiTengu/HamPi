#!/usr/bin/env bash
# HamPi64 (github.com/DaiTengu/HamPi64) — 64-bit port of HamPi for Raspberry Pi OS Trixie / Pi 5.
# Copyright (C) 2020-2024 Dave Slotter, W3DJS (original HamPi); (C) 2026 HamPi64 contributors.
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Create a .torrent for a HamPi64 image, with an HTTP **web seed** so the same file
# hosted on kd9qhq.com serves BOTH direct downloaders and torrent clients — no separate
# seedbox strictly required (though seeding still helps). Needs `transmission-create`.
#
# Usage: create_hampi_torrent.sh <path/to/hampi64-YYYY-MM-DD.img.xz> [download-url]
#   download-url defaults to https://kd9qhq.com/hampi64/<filename>
set -euo pipefail

IMG="${1:?usage: create_hampi_torrent.sh <image.img.xz> [https://host/path/image.img.xz]}"
[ -f "$IMG" ] || { echo "ERROR: not found: $IMG" >&2; exit 1; }
NAME="$(basename "$IMG")"
URL="${2:-https://kd9qhq.com/hampi64/${NAME}}"
OUT="${NAME}.torrent"

command -v transmission-create >/dev/null 2>&1 || {
  echo "ERROR: transmission-create not found (install 'transmission-cli')." >&2; exit 1; }

echo "==> Creating $OUT  (web seed: $URL)"
transmission-create -o "$OUT" \
  -w "$URL" \
  -t udp://tracker.opentrackr.org:1337/announce \
  -t udp://tracker.torrent.eu.org:451/announce \
  -t udp://open.demonii.com:1337/announce \
  -c "HamPi64 (github.com/DaiTengu/HamPi64) — 64-bit HamPi for Raspberry Pi OS Trixie / Pi 5. Please seed!" \
  "$IMG"

echo "==> Done: $OUT"
echo "    Publish alongside the image so clients can find the web seed:"
echo "      $URL"
echo "    (If your transmission-create lacks -w/--webseed, use: mktorrent -w \"$URL\" ...)"
