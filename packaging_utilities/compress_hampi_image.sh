#!/usr/bin/env bash
# HamPi64 (github.com/DaiTengu/HamPi64) — 64-bit port of HamPi for Raspberry Pi OS Trixie / Pi 5.
# Copyright (C) 2020-2024 Dave Slotter, W3DJS (original HamPi); (C) 2026 HamPi64 contributors.
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Compress a captured HamPi64 image to .img.xz and emit a SHA-256 checksum.
# (Skip this if you already produced the .xz with `pishrink -Z`.)
#
# Usage: compress_hampi_image.sh <path/to/hampi64-YYYY-MM-DD.img>
#   Set KEEP=1 in the environment to keep the raw .img (default: removed after compress).
set -euo pipefail

IMG="${1:?usage: compress_hampi_image.sh <image.img>}"
[ -f "$IMG" ] || { echo "ERROR: not found: $IMG" >&2; exit 1; }
KEEP_FLAG=""; [ "${KEEP:-0}" = "1" ] && KEEP_FLAG="-k"

echo "==> Compressing $IMG  (xz, all cores)"
# -T0: use every core; default level 6 is a good size/speed balance for a multi-GB image.
xz -T0 -v $KEEP_FLAG "$IMG"
XZ="${IMG}.xz"

echo "==> SHA-256"
( cd "$(dirname "$XZ")" && sha256sum "$(basename "$XZ")" | tee "$(basename "$XZ").sha256" )

echo "==> Done: $XZ  (+ .sha256 alongside it)"
