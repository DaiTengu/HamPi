#!/usr/bin/env bash
# HamPi64 (github.com/DaiTengu/HamPi64) — 64-bit port of HamPi for Raspberry Pi OS Trixie / Pi 5.
# Copyright (C) 2020-2024 Dave Slotter, W3DJS (original HamPi); (C) 2026 HamPi64 contributors.
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
#
# HamPi64 — standalone installer for DroidStar (nostar) + the md380 AMBE vocoder.
# Ported from tasks/install_droidstar.yml. Runs as root (system-wide installs); the
# CALLER handles opt-in — either the "HamPi64 Extras" launcher (after you accept the
# patent/firmware notice) or the gated Ansible task (-e include_nonfree=true).
#
# DroidStar itself is GPL, but its digital-voice modes use the AMBE/AMBE+2 vocoder,
# which is patent-encumbered (DVSI) and run via firmware extracted from a TYT MD-380.
# HamPi64 does not redistribute the vocoder; it is built here, on this device.
#
# Copyright (C) 2026 HamPi64 contributors
# SPDX-License-Identifier: GPL-3.0-or-later

die() { echo "ERROR: $*" >&2; exit 1; }
retry() { local n=0 max=3; until "$@"; do n=$((n+1)); [ "$n" -ge "$max" ] && return 1; echo "  ... attempt $n/$max failed, retrying in 3s: $*" >&2; sleep 3; done; }

[ "$(id -u)" -eq 0 ] || die "must run as root (use sudo)"

echo ">>> [1/5] Installing Qt6 build dependencies (apt)"
export DEBIAN_FRONTEND=noninteractive
retry apt-get update || die "apt-get update failed"
retry apt-get install -y \
  git cmake g++ \
  qt6-base-dev qt6-base-private-dev qt6-multimedia-dev qt6-declarative-dev \
  qt6-serialport-dev qt6-tools-dev qt6-tools-dev-tools \
  libgl1-mesa-dev xxd unzip python3 libboost-dev libfmt-dev \
  || die "apt-get install of Qt6 build dependencies failed"

echo ">>> [2/5] Cloning md380_vocoder_dynarmic (dynarmic AMBE vocoder)"
MD_SRC=/usr/local/src/md380_vocoder_dynarmic
if [ ! -d "$MD_SRC/.git" ]; then
  rm -rf "$MD_SRC"
  retry git clone --depth 1 https://github.com/nostar/md380_vocoder_dynarmic.git "$MD_SRC" \
    || die "git clone md380_vocoder_dynarmic failed"
else
  echo "  already cloned: $MD_SRC"
fi

echo ">>> [3/5] Building + installing md380_vocoder"
if [ ! -f /usr/local/lib/libmd380_vocoder.a ]; then
  cd "$MD_SRC"
  rm -rf build && mkdir build && cd build
  cmake -DCMAKE_BUILD_TYPE=Release ..
  make -j"$(nproc)"
  # makelib.sh re-archives with `ar -qc` (no symbol index)...
  [ -f ../makelib.sh ] && sh ../makelib.sh || true
  # ...so ranlib is REQUIRED to add the index, or DroidStar fails to link the
  # bundled fmt/dynarmic back-references inside the static lib.
  ranlib libmd380_vocoder.a
  # -print -quit: stop at the first match (no `| head -1`, which would SIGPIPE
  # `find` and, under `set -o pipefail`, abort the script even on success).
  a=$(find /usr/local/src/md380_vocoder_dynarmic -name 'libmd380_vocoder.a' -print -quit)
  [ -n "$a" ] || die "libmd380_vocoder.a not found after build"
  install -m 0644 "$a" /usr/local/lib/libmd380_vocoder.a
  h=$(find /usr/local/src/md380_vocoder_dynarmic -name 'md380_vocoder.h' -print -quit)
  [ -n "$h" ] || die "md380_vocoder.h not found after build"
  install -m 0644 "$h" /usr/local/include/md380_vocoder.h
  ldconfig
else
  echo "  already built: /usr/local/lib/libmd380_vocoder.a (skipping)"
fi

echo ">>> [4/5] Cloning DroidStar (nostar)"
DS_SRC=/usr/local/src/DroidStar
if [ ! -d "$DS_SRC/.git" ]; then
  rm -rf "$DS_SRC"
  retry git clone --depth 1 https://github.com/nostar/DroidStar.git "$DS_SRC" \
    || die "git clone DroidStar failed"
else
  # force parity: discard local edits (e.g. the CMakeLists.txt seds from a prior
  # run) so the seds below apply to a pristine tree.
  echo "  refreshing existing checkout (force)"
  retry git -C "$DS_SRC" fetch --depth 1 origin HEAD || die "git fetch DroidStar failed"
  git -C "$DS_SRC" reset --hard FETCH_HEAD
  git -C "$DS_SRC" clean -fd
fi

echo ">>> [5/5] Building + installing DroidStar"
if [ ! -f /usr/local/bin/DroidStar ]; then
  cd "$DS_SRC"
  # Debian ships the Qt6::CorePrivate target but no separate Qt6CorePrivate package
  # config; drop it from find_package COMPONENTS (the target link still resolves).
  sed -i 's/ CorePrivate)/)/' CMakeLists.txt
  # md380_vocoder.a references (header-only) fmt v10 vprint; link system libfmt AFTER it.
  sed -i 's/^\( *\)md380_vocoder$/\1md380_vocoder\n\1fmt/' CMakeLists.txt
  rm -rf build && mkdir build && cd build
  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local ..
  cmake --build . -j"$(nproc)"
  cmake --install .
  [ -f /usr/local/bin/DroidStar ] || die "build did not produce /usr/local/bin/DroidStar"
else
  echo "  already installed: /usr/local/bin/DroidStar (skipping)"
fi

echo ">>> DroidStar + md380 vocoder installation complete."
