#!/usr/bin/env bash
set -euo pipefail
#
# HamPi64 — standalone installer for the SDRplay RSP API (PROPRIETARY, © SDRplay Ltd)
# + the open-source SoapySDRPlay3 module. Ported from tasks/install_sdrplay.yml.
# Runs as root (system-wide installs); the CALLER handles opt-in — either the
# "HamPi64 Extras" launcher (after you accept SDRplay's terms) or the gated Ansible
# task (-e include_nonfree=true). The vendor .run is fetched from sdrplay.com here,
# on this device, under SDRplay's own license. HamPi64 does not redistribute it.
#
# Copyright (C) 2020-2024 Dave Slotter, W3DJS (original HamPi); (C) 2026 Mike Miller, KD9QHQ (HamPi64 fork).
# SPDX-License-Identifier: GPL-3.0-or-later

SDRPLAY_API_VERSION="3.15.2"          # vendor .run version
SDRPLAY_API_LIBVER="3.15"             # libsdrplay_api.so.<libver> in payload
SDRPLAY_SERVICE_DIR="/opt/sdrplay_api"
SOAPY_MODULE_DIR="/usr/local/lib/SoapySDR/modules0.8"

RUN_URL="https://www.sdrplay.com/software/SDRplay_RSP_API-Linux-${SDRPLAY_API_VERSION}.run"
RUN_FILE="/tmp/sdrplay_api.run"
PAYLOAD_DIR="/tmp/sdrplay_api_payload"

export DEBIAN_FRONTEND=noninteractive
die() { echo "ERROR: $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "must run as root (use sudo)"

echo "==> Downloading SDRplay API installer (${SDRPLAY_API_VERSION})"
# get_url parity: retries 3, delay 10 — but download to a .part and mv on success
# so an interrupted fetch can't leave a corrupt .run for the next extraction.
dl_ok=""
for attempt in 1 2 3; do
  if wget -q -O "${RUN_FILE}.part" "${RUN_URL}"; then
    mv -f "${RUN_FILE}.part" "${RUN_FILE}"; dl_ok="yes"; break
  fi
  rm -f "${RUN_FILE}.part"
  [ "${attempt}" -lt 3 ] && { echo "    download attempt ${attempt} failed; retrying in 10s..."; sleep 10; }
done
[ -n "${dl_ok}" ] || die "failed to download ${RUN_URL} after 3 attempts"
chmod 0755 "${RUN_FILE}"

echo "==> Extracting SDRplay API payload (Makeself, non-interactive)"
if [ ! -f "${PAYLOAD_DIR}/install_lib.sh" ]; then
  "${RUN_FILE}" --noexec --target "${PAYLOAD_DIR}" || die "extracting ${RUN_FILE} failed"
else
  echo "    payload already extracted; skipping"
fi

echo "==> Installing SDRplay API shared library (arm64)"
SRC_LIB="${PAYLOAD_DIR}/arm64/libsdrplay_api.so.${SDRPLAY_API_LIBVER}"
[ -f "${SRC_LIB}" ] || die "expected library not found: ${SRC_LIB}"
install -m 0644 "${SRC_LIB}" "/usr/local/lib/libsdrplay_api.so.${SDRPLAY_API_LIBVER}"

echo "==> Creating dev symlink (libsdrplay_api.so)"
ln -sf "libsdrplay_api.so.${SDRPLAY_API_LIBVER}" /usr/local/lib/libsdrplay_api.so

echo "==> Installing SDRplay API headers"
[ -d "${PAYLOAD_DIR}/inc" ] || die "header directory not found: ${PAYLOAD_DIR}/inc"
mkdir -p /usr/local/include
cp -a "${PAYLOAD_DIR}/inc/." /usr/local/include/
chmod 0755 /usr/local/include   # copy can clobber the dir's +x

echo "==> Creating SDRplay API service directory"
install -d -m 0755 "${SDRPLAY_SERVICE_DIR}"

echo "==> Installing SDRplay API service binary (arm64)"
SRC_SVC="${PAYLOAD_DIR}/arm64/sdrplay_apiService"
[ -f "${SRC_SVC}" ] || die "expected service binary not found: ${SRC_SVC}"
install -m 0755 "${SRC_SVC}" "${SDRPLAY_SERVICE_DIR}/sdrplay_apiService"

echo "==> Installing SDRplay udev rules"
install -d -m 0755 /etc/udev/rules.d
tee /etc/udev/rules.d/66-sdrplay.rules >/dev/null <<'EOF'
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1df7",ATTRS{idProduct}=="2500",MODE:="0666"
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1df7",ATTRS{idProduct}=="3000",MODE:="0666"
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1df7",ATTRS{idProduct}=="3010",MODE:="0666"
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1df7",ATTRS{idProduct}=="3020",MODE:="0666"
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1df7",ATTRS{idProduct}=="3030",MODE:="0666"
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1df7",ATTRS{idProduct}=="3050",MODE:="0666"
SUBSYSTEM=="usb",ENV{DEVTYPE}=="usb_device",ATTRS{idVendor}=="1df7",ATTRS{idProduct}=="3060",MODE:="0666"
EOF
chmod 0644 /etc/udev/rules.d/66-sdrplay.rules

echo "==> Installing SDRplay API systemd service"
tee /etc/systemd/system/sdrplay.service >/dev/null <<EOF
[Unit]
Description=SDRplay API Service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=on-failure
RestartSec=1
User=root
ExecStart=${SDRPLAY_SERVICE_DIR}/sdrplay_apiService

[Install]
WantedBy=multi-user.target
EOF
chmod 0644 /etc/systemd/system/sdrplay.service

echo "==> Refreshing linker cache (ldconfig)"
ldconfig

echo "==> Enabling and starting sdrplay API service"
systemctl daemon-reload
systemctl enable --now sdrplay

echo "==> Installing SoapySDRPlay3 build dependencies"
apt-get update
apt-get install -y git cmake g++ libsoapysdr-dev

echo "==> Cloning SoapySDRPlay3 (master)"
SOAPY_SRC="/usr/local/src/SoapySDRPlay3"
if [ ! -d "${SOAPY_SRC}/.git" ]; then
  mkdir -p /usr/local/src
  git clone https://github.com/pothosware/SoapySDRPlay3.git "${SOAPY_SRC}"
  git -C "${SOAPY_SRC}" checkout master
else
  git -C "${SOAPY_SRC}" fetch origin
  git -C "${SOAPY_SRC}" reset --hard origin/master
fi

echo "==> Building and installing SoapySDRPlay3"
if [ ! -f "${SOAPY_MODULE_DIR}/libsdrPlaySupport.so" ]; then
  cd "${SOAPY_SRC}"
  rm -rf build && mkdir build && cd build
  cmake .. -DCMAKE_BUILD_TYPE=Release
  make -j"$(nproc)"
  make install
  ldconfig
else
  echo "    SoapySDRPlay3 module already installed; skipping build"
fi

echo "==> SDRplay RSP support installed successfully."
