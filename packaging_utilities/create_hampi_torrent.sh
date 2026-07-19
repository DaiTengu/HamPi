#!/bin/bash
#
# HamPi64 — a 64-bit fork of HamPi for Raspberry Pi OS Trixie / Pi 5 (github.com/DaiTengu/HamPi64).
# Copyright (C) 2020-2024 Dave Slotter, W3DJS (original HamPi); (C) 2026 HamPi64 contributors.
# SPDX-License-Identifier: GPL-3.0-or-later
#

VERSION=3.0

transmission-create -o "HamPi Image Beta v${VERSION} (compressed).torrent" \
-t udp://tracker.opentrackr.org:1337/announce \
-c "HamPi Image Beta v${VERSION} by W3DJS - Please seed this torrent as long as possible!" \
"HamPi v${VERSION} by W3DJS"
