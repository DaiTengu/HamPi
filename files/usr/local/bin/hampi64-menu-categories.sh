#!/bin/sh
# HamPi64 (github.com/DaiTengu/HamPi64) — 64-bit port of HamPi for Raspberry Pi OS Trixie / Pi 5.
# Copyright (C) 2020-2024 Dave Slotter, W3DJS (original HamPi); (C) 2026 HamPi64 contributors.
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Organise the Ham Radio menu into sub-groups.
#
# Stock .desktop files scatter ham apps across "Internet" (Categories=Network) and
# "Accessories" (Categories=Utility), and the ones tagged plain "HamRadio" all pile into a
# single giant flat list. This rewrites each app's Categories= line to
#   Categories=HamRadio;HamRadio<Group>;
# so it lands in exactly one Ham Radio sub-menu (see hamradio.menu). Idempotent + re-runnable.
#
# ponytail: edits the installed .desktop in place. If apt upgrades an app it may ship a fresh
# .desktop and revert its category — just re-run this script (or `--tags menus`) to restore.
set -eu

APPDIRS="/usr/share/applications /usr/local/share/applications"

# set_cat <basename.desktop> <HamRadio group token>
set_cat() {
  for d in $APPDIRS; do
    f="$d/$1"
    [ -f "$f" ] || continue
    if grep -q '^Categories=' "$f"; then
      sed -i "s|^Categories=.*|Categories=HamRadio;$2;|" "$f"
    else
      sed -i "0,/^\[Desktop Entry\][[:space:]]*\$/s||[Desktop Entry]\nCategories=HamRadio;$2;|" "$f"
    fi
  done
}

# group <token> <app...>  — app names are .desktop basenames without the suffix.
# Missing apps are silently skipped, so opt-in / not-yet-installed apps are safe to list.
group() { tok="$1"; shift; for a in "$@"; do set_cat "$a.desktop" "$tok"; done; }

group HamRadioWeakSignal    wsjtx jtdx js8call message_aggregator gridtracker2 wsjtz
group HamRadioFldigi        fldigi flamp flarq flmsg flwrap flrig flwkey flnet fllog flcluster
group HamRadioDigital       psk31lx twpsk lopora linpsk
group HamRadioDigitalVoice  freedv qtel qdmr droidstar DroidStar
group HamRadioSDR           dk.gqrx.gqrx CubicSDR cutesdr quisk sdrpp sdrangel pihpsdr gnuradio-grc lime-suite
group HamRadioRigControl    grig wfview chirp
group HamRadioLogging       cqrlog klog xlog hamrs skcclogger tentenqsologger tucnak pyqso org.arrl.trustedqsl Xdx rbnc cqrprop
group HamRadioAPRS          xastir direwolf d-rats
group HamRadioSatImg        gpredict noaa-apt qsstv hamfax
group HamRadioMorseCode     qrq xcwcp xdemorse ebook2cwgui
group HamRadioAntennaAnalyzer nec2c xnec2c flaa
group HamRadioTraining      hamexam fccexam twclock

# refresh the desktop database so the panel menu picks up the new categories
for d in $APPDIRS; do
  [ -d "$d" ] || continue
  command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$d" 2>/dev/null || true
done
