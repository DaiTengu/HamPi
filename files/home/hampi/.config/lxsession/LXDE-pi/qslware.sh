#!/usr/bin/env bash
#
# HamPi64 — a 64-bit fork of HamPi for Raspberry Pi OS Trixie / Pi 5 (github.com/DaiTengu/HamPi64).
# Copyright (C) 2020-2024 Dave Slotter, W3DJS (original HamPi); (C) 2026 Mike Miller, KD9QHQ (HamPi64 fork).
# SPDX-License-Identifier: GPL-3.0-or-later
#

export TEXTDOMAIN=pprompt

zenity --warning --width=400 --title "QSLWARE NOTICE" --timeout=59 --text "Please note that HamPi is QSLware. If you use it, please send me (W3DJS) a QSL card by postal mail. If you do not have a QSL card, then a postcard will suffice. My postal address is on QRZ.com.\n\nOnce I receive your QSL card or postcard by mail, I will email instructions on how to remove this dialog. So please include your email address on the QSL card or postcard.\n\nBy operating this image, you agree to the terms and conditions in the license agreement."
