# HamPi64 — 64-bit Ham Radio for the Raspberry Pi 5

**HamPi64** is the 64-bit edition of **HamPi**, the comprehensive amateur-radio software
collection for the Raspberry Pi originally created by **Dave Slotter (W3DJS)** (as
"W3DJS Raspberry Pi for Ham Radio").

This fork — [**DaiTengu/HamPi64**](https://github.com/DaiTengu/HamPi64) — updates HamPi for
**64-bit Raspberry Pi OS "Trixie" (Debian 13) on the Raspberry Pi 5**. The 64-bit port is by **Mike Miller (KD9QHQ)**. Full credit for the original project goes to Dave Slotter and the HamPi
contributors (see [`CONTRIBUTORS.md`](CONTRIBUTORS.md)). HamPi is free software under the
**GNU GPL v3**.

> The HamPi64 port was developed with AI pair-programming assistance (Anthropic's Claude, via
> Claude Code), reviewed and tested on real hardware. See [`CONTRIBUTORS.md`](CONTRIBUTORS.md).

## Status & support

**"Works for me."** HamPi64 is shared as-is under the GPL — **no warranty and no support**.
It is built and used on this hardware:

- Icom **IC-7300**
- **Raspberry Pi 5 (8 GB)**
- **Raspberry Pi Touch Display 2** + an external **HDMI** monitor

Other rigs, HATs, and displays may or may not work. Nobody is promising to answer setup or
support questions — but bug reports and, especially, fixes are very welcome (see below).

## Contributing

Contributions are welcome — **fork the repo and open a pull request.** A new app, an aarch64
build fix, or a doc correction: a PR is the best way to improve HamPi64. See
[`CONTRIBUTING.md`](CONTRIBUTING.md) and [`CONTRIBUTORS.md`](CONTRIBUTORS.md).

## Documentation
- **This fork:** [`docs/`](docs/) — coverage map and roadmap
- **Original HamPi wiki:** <https://github.com/dslotter/HamPi/wiki>

## Licensing & non-free components

The HamPi64 **playbook** (this repository) is licensed **GNU GPL v3** — it is a fork of
HamPi and keeps Dave Slotter's (W3DJS) copyright alongside the HamPi64 contributors'.

The playbook *installs* a lot of third-party software, and **each program keeps its own
license** — the GPL here does not relicense them. Nearly all of it is free/open source.

A few components are **non-free** (proprietary or patent-encumbered) and are **not baked
into the image**. Instead the image ships a **HamPi64 Extras** launcher that downloads and
installs each on your own device, under that vendor's own license, only if you choose to.
Deferred this way: **SDRplay RSP API**, **DroidStar** (patented AMBE codec), and **HamRS**.
To build an image with them included anyway, run the playbook with `-e include_nonfree=true`.

## Getting the image (first boot)

HamPi64 is distributed as a flashable Raspberry Pi image. Flash it with **Raspberry Pi
Imager** — when it offers OS customisation, set your **username**, password, Wi-Fi and SSH.
If you skip that, the Pi prompts you to create your user on first boot. There is **no fixed
`pi` account**: you choose your own username, exactly like stock Raspberry Pi OS. Every app is
installed system-wide, so it's ready for whatever user you create.

The non-free extras (SDRplay, HamRS, DroidStar) are **not** in the image — install them any
time from the **HamPi64 Extras** launcher in the Hamradio menu, which fetches each under its
vendor's license.

## What's installed

The current app set. See [`docs/coverage.md`](docs/coverage.md) for the install method per app
and the list of original-HamPi apps that are **not** included.

### General / rig control
- **HamLib** — ham radio rig-control libraries (`rigctl` / `rigctld`)
- **grig** — GTK front-end to Hamlib
- **wfview** — Icom rig control (SDR / network / serial; IC-7300 etc.)
- **QTel** — EchoLink client (SvxLink)
- **splat** — point-to-point terrestrial RF path / coverage analysis
- **D-Rats** — D-STAR (and generic) data terminal: chat, files, forms, maps

### Digital modes & weak-signal
- **WSJT-X Improved** — weak-signal FT8/FT4/etc. (DG2YCB build)
- **JS8Call** — keyboard-to-keyboard messaging on the FT8 protocol
- **JTDX** — alternate FT8/FT4 client
- **GridTracker 2** — mapping companion for WSJT-X / JTDX
- **gnss-sdr** — GNSS software-defined receiver
- **linpsk** — PSK31 / RTTY via soundcard
- **multimon-ng** — multi-protocol digital transmission decoder
- **psk31lx** / **twpsk** — PSK31 clients
- **FreeDV** — free digital-voice vocoder
- **MSHV** — multi-mode weak-signal (MSK144 / FT8 / JT65 …)
- **acarsdec** — ACARS (aircraft datalink) decoder
- **FLDigi suite** — fldigi (digital modes), flrig (rig control), flmsg (ICS-213 forms), flamp
  (file transfer), flarq (ARQ), flwrap (file encapsulation), flcluster (DX cluster), fllog
  (logbook), flnet (net control), flwkey (Winkeyer)
- **glfer** — QRSS spectrogram display + QRSS keyer
- **QrssPiG** — QRSS grabber / spectrogram uploader
- **Fl_MoxGen** — Moxon-antenna dimension generator

### SDR drivers
- **Airspy / AirspyHF** — Airspy R2/Mini and HF+ / Discovery tools
- **HackRF** — HackRF tools + firmware
- **LimeSuite** — LimeSDR tools / library
- **UHD** — Ettus USRP tools + firmware
- **gr-osmosdr** — GNU Radio osmosdr source/sink
- **rtl-sdr** — RTL-SDR tools
- **rtl-433** — 433/868 MHz ISM-band decoder
- **SoapySDR** + all driver modules — vendor-neutral SDR support (RTL, HackRF, Airspy, AirspyHF,
  PlutoSDR, BladeRF, …) plus VOLK-accelerated converters
- **inspectrum** — captured-signal analysis GUI

### SDR GUIs
- **GQRX** — SDR receiver GUI
- **CubicSDR** — cross-platform SDR receiver
- **cutesdr** — simple demodulation + spectrum display
- **quisk** — SDR transceiver / panadapter
- **SDR++** — cross-platform SDR receiver
- **piHPSDR** — controller for HPSDR / Hermes / Red Pitaya transceivers
- **lysdr** — minimal JACK-based SDR
- **leansdr / leandvb** — lightweight DVB-S/S2 toolkit for amateur DATV
- **SDRangel** — full-featured SDR rx/tx GUI
- **UHRR** — browser-based rig remote control + audio

### APRS / packet
- **Xastir** — APRS GUI client / digipeater / igate
- **DireWolf** — software "soundcard" TNC (AX.25) + APRS modem
- **aprsdigi** — APRS digipeater
- **aprx** — APRS digipeater / iGate
- **soundmodem** — soundcard packet-radio modem
- **linpac** — AX.25 packet-radio terminal (mailbox client)
- **AX.25 stack** — libax25 + ax25-tools + ax25-apps

### DMR & digital voice
- **qdmr** — DMR codeplug programmer
- **dmrconfig** — alternative DMR codeplug tool (CLI)
- **DMRHost** — MMDVM digital-voice host daemon
- **DMRlink / HBlink3** — DMR IPSC / HBP network software
- **OpenDV (DStarRepeater)** — D-STAR repeater component
- **AMBEserver** — exposes a DV3000 / ThumbDV AMBE dongle over TCP
- **brandmeister-dmr-sea** — BrandMeister DMR network helper scripts

### Logging
- **TrustedQSL** — Logbook of the World (LoTW) client
- **CQRlog** / **KLog** / **xlog** — ham radio logging programs
- **PyQSO** — logging (Python / GTK)
- **tlf** — console contest logger
- **tucnak** — VHF/UHF/SHF contest logger
- **ADIF Merge** — ADIF log merge / convert / check (+ qsorep reporting)
- **ADIF Multitool (adifmt)** — ADIF filtering / conversion CLI
- **DXSpider** — DX-cluster node software
- **SKCCLogger** — Straight Key Century Club logger
- **Ten-Ten QSO Logger** — logger for the 10-10 International net
- **TR-Log** — console contest logger (trlinux)
- **Reverse Beacon Network client** — CW skimmer / RBN spotting

### Morse / CW
- **cw / cwcp / xcwcp** — console, ncurses, and GUI Morse senders (unixcw)
- **cwdaemon** — Morse keying daemon (serial / parallel port)
- **aldo** — Morse training program
- **qrq** — high-speed Morse trainer
- **ebook2cw / ebook2cwgui** — convert ebooks to Morse audio (MP3/OGG)
- **morse** — Morse training program
- **morse2ascii** — decode Morse from a PCM WAV file
- **morsegen** — convert files to ASCII Morse
- **xdemorse** — decode Morse signals to text
- **rscw** — CW / Morse decoder (matched filtering)
- **Wordsworth** — Morse-code trainer

### Antenna modeling
- **nec2c** — NEC2 method-of-moments engine (C port)
- **xnec2c** — NEC2 GUI: geometry + gain patterns (replaces antennavis/gsmc/xnecview)
- **yagiuda** — Yagi-Uda array performance analysis
- **flaa** — RigExpert AA-series antenna-analyzer control (W1HKJ)
- **aa-analyzer** — RigExpert AA plotter / controller (Perl)
- **F4HTBPanadapter** — standalone panadapter / PNA

### Satellite / weather
- **Gpredict** — satellite tracking / prediction
- **predict** — satellite tracking / prediction (ncurses)
- **noaa-apt** — NOAA APT weather-satellite image decoder
- **xwefax** — WEFAX / radio-fax decoder (GTK3 + Hamlib)
- **hamfax** — HF fax (WEFAX) send / receive
- **QSSTV** — slow-scan TV (and fax)

### Winlink
- **Pat** — Winlink client for the Raspberry Pi (and other platforms)

### Training / exam
- **fccexam** — study tool for US FCC commercial radio-license exams
- **hamexam** — study guide for US amateur-radio license exams

### Misc / utilities
- **VOACAP (voacapl)** — HF propagation prediction
- **gnuais / gnuaisgui** — AIS (Automatic Identification System) receiver
- **GPS (gpsd)** — GPS daemon + client tools
- **Xdx** — DX-cluster client
- **wwl** — distance + azimuth between two Maidenhead locators
- **twclock** — world clock + automatic CW ID timer
- **readsb + viewadsb** — ADS-B flight-tracking decoder + viewer
- **CQRprop** — HF propagation-forecast panel
- **Lady Heather** — GPS-disciplined-oscillator / timing monitor
- **JS8Call Utilities** — companion tools for JS8Call (APRS, telemetry, …)
- **WireGuard** — VPN
- **CallRec** — BrandMeister DMR call recorder

### Opt-in (present, off by default)
- **WSJT-Z** — WSJT-X fork with extended FT8/FT4 automation (`-e install_wsjtz=true`)
- **BOINC** — distributed computing; disabled by default, enable via `systemctl`

### Via the HamPi64 Extras launcher (non-free, not baked in)
- **SDRplay RSP API + SoapySDRPlay3** — SDRplay RSP receiver support (proprietary vendor API)
- **HamRS** — cross-platform logging app (closed-source freeware)
- **DroidStar** — D-STAR / DMR / YSF / P25 / NXDN / M17 hotspot client (uses the patented AMBE codec)
