# HamPi Trixie/Pi 5 — Coverage Map

_Original HamPi app set vs. the Trixie/Pi 5 port. Generated 2026-07-15._

## General / rig-control

| App | Category | Our status |
|---|---|---|
| HamLib | General/rig-control | ✅ **Installed** — apt `libhamlib-utils` (core_apt_apps.yml) |
| grig | General/rig-control | ✅ **Installed** — apt `grig` (install_misc.yml) |
| wfview | General/rig-control | ❓ **Not yet addressed** |
| D-RATS | General/rig-control | ❓ **Not yet addressed** |
| QTel (EchoLink client) | General/rig-control | ❓ **Not yet addressed** |
| splat | General/rig-control | ✅ **Installed** — apt `splat` (install_antenna_modeling.yml) |

## Digital modes & weak-signal

| App | Category | Our status |
|---|---|---|
| WSJT-X | Digital modes | ✅ **Installed** — upstream .deb (WSJT-X Improved, DG2YCB build) via install_wsjtx.yml |
| JS8Call | Digital modes | ✅ **Installed** — apt `js8call` (core_apt_apps.yml); apt is 2.2.0, upstream is 2.3.1 (version-bump noted in TODO) |
| JS8CallTools / JS8CallUtilities | Digital modes | ❓ **Not yet addressed** |
| JTDX | Digital modes | ✅ **Installed** — apt `jtdx` (core_apt_apps.yml) |
| GridTracker | Digital modes | ✅ **Installed** — upstream .deb via install_gridtracker.yml |
| gnss-sdr | Digital modes | ✅ **Installed** — apt `gnss-sdr` (install_sdr_drivers.yml) |
| linpsk | Digital modes | ❓ **Not yet addressed** |
| multimon (original) | Digital modes | ❓ **Not yet addressed** |
| multimon-ng | Digital modes | ✅ **Installed** — apt `multimon-ng` (install_sdr_drivers.yml) |
| psk31lx | Digital modes | ❓ **Not yet addressed** |
| twpsk | Digital modes | ❓ **Not yet addressed** |
| FreeDV | Digital modes | ⏭️ **Deferred** — build broken under Bookworm (original comment); not revisited |
| MSHV | Digital modes | ⏭️ **Deferred** — x86 build target, not viable on arm64 Pi (TODO, "Not viable on Pi") |
| acarsdec | Digital modes | ❓ **Not yet addressed** |
| flxmlrpc | Digital modes (FLDigi suite) | ✅ **Installed** — pulled in transitively as an apt dependency of fldigi/flrig |
| flrig | Digital modes (FLDigi suite) | ✅ **Installed** — apt `flrig` (core_apt_apps.yml) |
| fldigi | Digital modes (FLDigi suite) | ✅ **Installed** — apt `fldigi` (core_apt_apps.yml) |
| flaa | Digital modes (FLDigi suite) | ❓ **Not yet addressed** |
| flamp | Digital modes (FLDigi suite) | ✅ **Installed** — apt `flamp` (core_apt_apps.yml) |
| flarq | Digital modes (FLDigi suite) | ✅ **Installed** — bundled with the apt `fldigi` package (no separate original import line) |
| flcluster | Digital modes (FLDigi suite) | ❓ **Not yet addressed** |
| fllog | Digital modes (FLDigi suite) | ❓ **Not yet addressed** |
| flmsg | Digital modes (FLDigi suite) | ✅ **Installed** — apt `flmsg` (core_apt_apps.yml) |
| flnet | Digital modes (FLDigi suite) | ❓ **Not yet addressed** |
| flpost | Digital modes (FLDigi suite) | ❓ **Not yet addressed** |
| flwkey | Digital modes (FLDigi suite) | ❓ **Not yet addressed** |
| flwrap | Digital modes (FLDigi suite) | ❓ **Not yet addressed** |
| QRSS PIG | Digital modes | ❓ **Not yet addressed** |
| glfer | Digital modes | ❓ **Not yet addressed** |
| FLMoxgen | Digital modes | ❓ **Not yet addressed** |
| WsprryPi / TAPR WSPR | Digital modes | ❓ **Not yet addressed** |

## SDR drivers

| App | Category | Our status |
|---|---|---|
| Airspy | SDR drivers | ✅ **Installed** — apt `airspy` (install_sdr_drivers.yml) |
| AirspyHF | SDR drivers | ❓ **Not yet addressed** |
| SoapySDR (core) | SDR drivers | ✅ **Installed** — apt `soapysdr-tools` + `soapysdr-module-all` (core_apt_apps.yml) |
| SoapyAudio | SDR drivers | ✅ **Installed** — bundled in apt `soapysdr-module-all` |
| SoapyMultiSDR | SDR drivers | ✅ **Installed** — bundled in `soapysdr-module-all` |
| SoapyNetSDR | SDR drivers | ✅ **Installed** — bundled in `soapysdr-module-all` |
| SoapyRemote | SDR drivers | ✅ **Installed** — bundled in `soapysdr-module-all` |
| SoapyAirspy | SDR drivers | ✅ **Installed** — bundled in `soapysdr-module-all` (was "build broken under Bookworm") |
| SoapyAirspyHF | SDR drivers | ✅ **Installed** — bundled in `soapysdr-module-all` |
| SoapyBladeRF | SDR drivers | ✅ **Installed** — bundled in `soapysdr-module-all` |
| SoapyFCDPP | SDR drivers | ✅ **Installed** — bundled in `soapysdr-module-all` |
| SoapyHackRF | SDR drivers | ✅ **Installed** — apt `hackrf` + bundled `soapysdr-module-all` |
| SoapyOsmo | SDR drivers | ✅ **Installed** — apt `gr-osmosdr` + bundled `soapysdr-module-all` |
| SoapyPlutoSDR | SDR drivers | ✅ **Installed** — bundled in `soapysdr-module-all` |
| SoapyRedPitaya | SDR drivers | ✅ **Installed** — bundled in `soapysdr-module-all` |
| SoapyRTLSDR | SDR drivers | ✅ **Installed** — apt `rtl-sdr` + bundled `soapysdr-module-all` |
| SoapySDRPlay3 | SDR drivers | ✅ **Installed** — source-built against vendor SDRplay API (install_sdrplay.yml); was "fails to build under aarch64" originally |
| SoapyVolkConverters | SDR drivers | ❓ **Not yet addressed** — no confirmed apt coverage |
| SoapyUHD | SDR drivers | ✅ **Installed** — apt `uhd-host` + bundled `soapysdr-module-all` |
| inspectrum | SDR drivers | ✅ **Installed** — apt `inspectrum` (install_sdr_drivers.yml) |
| RTAudio | SDR drivers (support lib) | ✅ **Installed** — transitively via apt deps of fldigi/WSJT-X |

## SDR GUIs

| App | Category | Our status |
|---|---|---|
| cutesdr | SDR GUIs | ❓ **Not yet addressed** |
| LeanSDR | SDR GUIs | ⏭️ **Deferred** — "DJS SKIP FOR NOW" (original) |
| lysdr | SDR GUIs | ⏭️ **Deferred** — "DJS SKIP FOR NOW" (original) |
| GQRX | SDR GUIs | ✅ **Installed** — apt `gqrx-sdr` (core_apt_apps.yml) |
| CubicSDR | SDR GUIs | ✅ **Installed** — apt `cubicsdr` (install_sdr_drivers.yml) |
| SDR++ | SDR GUIs | ⏭️ **Deferred** — not in Trixie apt; needs source build or Flatpak (TODO) |
| SDRAngel | SDR GUIs | ⏭️ **Deferred** — not in Trixie apt, long build time; needs source build or Flatpak (TODO) |
| quisk | SDR GUIs | ❓ **Not yet addressed** |
| OpenWebRX | SDR GUIs | ❓ **Not yet addressed** |
| UHRR | SDR GUIs | ❓ **Not yet addressed** |
| piHPSDR | SDR GUIs | ❓ **Not yet addressed** |
| SparkSDR | SDR GUIs | ⏭️ **Deferred** — "Hold — enable when they finally support Raspberry Pi" (original) |

## APRS / packet

| App | Category | Our status |
|---|---|---|
| Xastir | APRS/packet | ✅ **Installed** — apt `xastir` (core_apt_apps.yml) |
| YAAC | APRS/packet | ⏭️ **Deferred** — Java download, not apt-packaged; deferred to source/download group (install_aprs_extras.yml comment; matches TODO) |
| DireWolf | APRS/packet | ✅ **Installed** — apt `direwolf` (core_apt_apps.yml); apt is 1.7, upstream 1.8.1 (version-bump noted in TODO) |
| aprsdigi | APRS/packet | ✅ **Installed** — apt `aprsdigi` (install_aprs_extras.yml) |
| aprx | APRS/packet | ✅ **Installed** — apt `aprx` (install_aprs_extras.yml) |
| soundmodem | APRS/packet | ✅ **Installed** — apt `soundmodem` (install_aprs_extras.yml) |
| linpac | APRS/packet | ❓ **Not yet addressed** |
| fbb (packet mailbox) | APRS/packet | ❓ **Not yet addressed** |
| APRS Message App for JS8Call | APRS/packet | ❓ **Not yet addressed** |

## DMR & digital voice

| App | Category | Our status |
|---|---|---|
| qdmr (DMR radio programmer) | DMR & digital voice | ✅ **Installed** — apt `qdmr` (install_dmr_apps.yml) |
| dmrconfig | DMR & digital voice | ✅ **Installed** — apt `dmrconfig` (install_dmr_apps.yml) |
| BlueDV | DMR & digital voice | ⏭️ **Deferred** — needs AMBE hardware dongle + AMBEServer; beta distribution (TODO) |
| OpenDV | DMR & digital voice | ⏭️ **Deferred** — build broken under Bookworm (original comment) |
| DroidStar | DMR & digital voice | ⏭️ **Deferred** — blocked on Trixie: CMake `find_package(Qt6 CorePrivate)` fails (TODO, detailed) |
| Brandmeister DMR (Seattle) | DMR & digital voice | ⏭️ **Deferred** — needs MMDVM hotspot hardware (TODO) |
| DMRlink | DMR & digital voice | ⏭️ **Deferred** — needs MMDVM hotspot hardware (TODO) |
| DMRHost (MMDVMHost) | DMR & digital voice | ⏭️ **Deferred** — needs MMDVM hotspot hardware (TODO) |

## Logging

| App | Category | Our status |
|---|---|---|
| TrustedQSL (tqsl) | Logging | ✅ **Installed** — apt `trustedqsl` (core_apt_apps.yml); original's dedicated source-build attempt (install_tqsl.yml) was broken under Bookworm, sidestepped now that Trixie apt ships it |
| CQRlog | Logging | ✅ **Installed** — apt `cqrlog` (core_apt_apps.yml) |
| PyQSO | Logging | ✅ **Installed** — apt `pyqso` (install_logging_extras.yml) |
| KLog | Logging | ✅ **Installed** — apt `klog` (core_apt_apps.yml) |
| tlf | Logging | ✅ **Installed** — apt `tlf` (install_logging_extras.yml) |
| tucnak2 | Logging | ✅ **Installed** — apt `tucnak` (install_logging_extras.yml; Trixie package renamed) |
| twlog | Logging | ❓ **Not yet addressed** |
| wsjtx_to_n3fjp | Logging | ⏭️ **Deferred** — listed as an item to add later (TODO, "Logging extras") |
| xlog | Logging | ✅ **Installed** — apt `xlog` (core_apt_apps.yml) |
| ADIF Merge | Logging | ❓ **Not yet addressed** |
| ADIFMT (ADIF Multitool) | Logging | ❓ **Not yet addressed** |
| Country files download (cty.dat etc.) | Logging | ❓ **Not yet addressed** |
| QSLware | Logging | ❓ **Not yet addressed** |
| SKCC Logger | Logging | ❓ **Not yet addressed** |
| Ten-Ten QSO Logger | Logging | ❓ **Not yet addressed** |
| HamRS | Logging | ❓ **Not yet addressed** |
| TRLog | Logging | ⏭️ **Deferred** — marked "#BROKEN" (original comment) |
| HLog | Logging | ⏭️ **Deferred** — marked "#BROKEN" (original comment) |
| DXSpider | Logging | ❓ **Not yet addressed** |
| Reverse Beacon Network client | Logging | ❓ **Not yet addressed** |

## WinLink

| App | Category | Our status |
|---|---|---|
| Pat WinLink | WinLink | ✅ **Installed** — upstream .deb from GitHub releases (la5nta/pat), install_pat.yml |
| ARDOP support / ARDOP-GUI / Find ARDOP | WinLink | ⏭️ **Deferred** — were 32-bit(armhf)-only; need arm64 sources (TODO) |
| AX25 support for Pat WinLink | WinLink | ❓ **Not yet addressed** |
| PMON | WinLink | ⏭️ **Deferred** — proprietary, no arm64 build (TODO, "Not viable on Pi") |

## Morse / CW

| App | Category | Our status |
|---|---|---|
| aldo | Morse/CW | ✅ **Installed** — apt `aldo` (install_morse.yml) |
| cw | Morse/CW | ✅ **Installed** — apt `cw` (install_morse.yml) |
| cwcp | Morse/CW | ✅ **Installed** — apt `cwcp` |
| xcwcp | Morse/CW | ✅ **Installed** — apt `xcwcp` |
| cwdaemon | Morse/CW | ✅ **Installed** — apt `cwdaemon` |
| ebook2cw | Morse/CW | ✅ **Installed** — apt `ebook2cw` |
| ebook2cwgui | Morse/CW | ✅ **Installed** — apt `ebook2cwgui` |
| morse (training program) | Morse/CW | ❓ **Not yet addressed** |
| morse2ascii | Morse/CW | ✅ **Installed** — apt `morse2ascii` |
| morsegen | Morse/CW | ❓ **Not yet addressed** |
| qrq | Morse/CW | ✅ **Installed** — apt `qrq` |
| twcw | Morse/CW | ❓ **Not yet addressed** |
| xdemorse | Morse/CW | ✅ **Installed** — apt `xdemorse` |
| rscw | Morse/CW | ❓ **Not yet addressed** |
| Wordsworth | Morse/CW | ❓ **Not yet addressed** |

## Antenna modeling

| App | Category | Our status |
|---|---|---|
| antennavis | Antenna modeling | ⏭️ **Deferred** — dropped from Trixie apt (install_antenna_modeling.yml comment) |
| gsmc | Antenna modeling | ⏭️ **Deferred** — dropped from Trixie apt (same comment) |
| nec2c | Antenna modeling | ✅ **Installed** — apt `nec2c` (install_antenna_modeling.yml) |
| xnecview | Antenna modeling | ⏭️ **Deferred** — dropped from Trixie apt; `xnec2c` covers the same gain-pattern visualization |
| xnec2c | Antenna modeling | ✅ **Installed** — apt `xnec2c` (install_antenna_modeling.yml); replaces xnecview/antennavis |
| yagiuda | Antenna modeling | ✅ **Installed** — apt `yagiuda` (install_antenna_modeling.yml) |
| AA Analyzer | Antenna modeling | ❓ **Not yet addressed** |
| F4HTB PNA | Antenna modeling | ❓ **Not yet addressed** |

## Satellite / weather

| App | Category | Our status |
|---|---|---|
| Gpredict | Satellite/weather | ✅ **Installed** — apt `gpredict` (core_apt_apps.yml) |
| predict-gsat | Satellite/weather | ❓ **Not yet addressed** |
| HamClock | Satellite/weather | ⏭️ **Deferred** — owner says ignore/dead |
| wxtoimg | Satellite/weather | ⏭️ **Deferred** — armhf abandonware (TODO) |
| Meteor Decoder (medet, Meteor-M LRPT) | Satellite/weather | ⏭️ **Deferred** — x86-only inline asm in `tim.pas`, won't build on aarch64; SatDump suggested as replacement (TODO) |
| noaa-apt | Satellite/weather | ✅ **Installed** — official aarch64 prebuilt binary (install_weather.yml); sidesteps original's broken Rust source-build |
| XWeFax | Satellite/weather | ❓ **Not yet addressed** |
| hamfax | Satellite/weather | ❓ **Not yet addressed** |
| acfax | Satellite/weather | ❓ **Not yet addressed** |

## Training / exam

| App | Category | Our status |
|---|---|---|
| fccexam | Training/exam | ✅ **Installed** — apt `fccexam` (install_exam.yml) |
| hamexam | Training/exam | ✅ **Installed** — apt `hamexam` (install_exam.yml) |

## Misc / utilities

| App | Category | Our status |
|---|---|---|
| WireGuard | Misc/utilities | ❓ **Not yet addressed** |
| CMake | Misc/utilities | ✅ **Installed** — installed on-demand as a build dependency in install_sdrplay.yml (SoapySDRPlay3 build) |
| wxWidgets | Misc/utilities | ❓ **Not yet addressed** |
| DRAWS support | Misc/utilities | ⏭️ **Deferred** — Node.js install broken under Bookworm (original comment) |
| lopora | Misc/utilities | ❓ **Not yet addressed** — app identity unclear from filename alone |
| PyBOMBS | Misc/utilities | ❓ **Not yet addressed** |
| BOINC | Misc/utilities | ❓ **Not yet addressed** |
| twclock | Misc/utilities | ⏭️ **Deferred** — "Website gone" (original comment) |
| twHamQTH | Misc/utilities | ⏭️ **Deferred** — "Website gone" (original comment) |
| dump1090 (ADS-B) | Misc/utilities | ⏭️ **Deferred** — build broken under Bookworm originally; modern replacement readsb/dump1090-fa needs a source build (TODO) |
| VOACAP | Misc/utilities | ✅ **Installed** — apt `voacapl` (install_misc.yml) |
| CygnusRFI | Misc/utilities | ❓ **Not yet addressed** |
| RadioExplorer | Misc/utilities | ⏭️ **Deferred** — Windows-only app (TODO, "Not viable on Pi") |
| CQRprop | Misc/utilities | ❓ **Not yet addressed** |
| Lady Heather | Misc/utilities | ❓ **Not yet addressed** |
| Go toolchain | Misc/utilities | ❓ **Not yet addressed** — likely moot now that Pat installs via prebuilt arm64 .deb (no source build needed) |
| CallRec | Misc/utilities | ⏭️ **Deferred** — marked "#BROKEN" (original comment) |
| TeamViewer Host | Misc/utilities | ⏭️ **Deferred** — proprietary, no arm64 build (TODO); original held with "#Hold" |
| colrconv | Misc/utilities | ❓ **Not yet addressed** |
| gcb | Misc/utilities | ❓ **Not yet addressed** |
| gnuais / gnuaisgui | Misc/utilities | ❓ **Not yet addressed** |
| Pi3/4 Stats Monitor (W1HKJ) | Misc/utilities | ❓ **Not yet addressed** |
| Auto WiFi Hotspot | Misc/utilities | ❓ **Not yet addressed** |
| GPS Support | Misc/utilities | ✅ **Installed** — apt `gpsd` + `gpsd-clients` (install_misc.yml) |
| Xdx | Misc/utilities | ✅ **Installed** — apt `xdx` (install_misc.yml) |
| wwl | Misc/utilities | ✅ **Installed** — apt `wwl` (install_misc.yml) |
| rpitx | Misc/utilities | ⏭️ **Deferred** — Pi 5 moved GPIO to the RP1 chip; no upstream support (TODO) |

## System / framework

| App | Category | Our status |
|---|---|---|
| set_facts | System/framework | ✅ **Installed** — direct equivalent (library/set_facts.yml) imported by tasks/hampi_trixie.yml |
| init_task | System/framework | ❓ **Not yet addressed** |
| configuration_tasks | System/framework | ❓ **Not yet addressed** |
| install_menus | System/framework | ❓ **Not yet addressed** |
| install_about | System/framework | ❓ **Not yet addressed** |
| install_wallpaper | System/framework | ❓ **Not yet addressed** |
| upgrade_debian_packages | System/framework | ❓ **Not yet addressed** |
| install_bookmarks | System/framework | ❓ **Not yet addressed** |

## Counts

- **Total original apps/capabilities:** 180
- **✅ Installed:** 74
- **⏭️ Deferred:** 33
- **❓ Not yet addressed:** 73

## ❓ Not yet addressed — the gaps requiring a decision

- **General/rig-control:** wfview, D-RATS, QTel/EchoLink
- **Digital modes:** JS8CallTools/Utilities, linpsk, multimon (original), psk31lx, twpsk, acarsdec, flaa, flcluster, fllog, flnet, flpost, flwkey, flwrap, QRSS PIG, glfer, FLMoxgen, WsprryPi/TAPR WSPR
- **SDR drivers:** AirspyHF, SoapyVolkConverters
- **SDR GUIs:** cutesdr, quisk, OpenWebRX, UHRR, piHPSDR
- **APRS/packet:** linpac, fbb, APRS Message App for JS8Call
- **Logging:** twlog, ADIF Merge, ADIFMT, country files download, QSLware, SKCC Logger, Ten-Ten QSO Logger, HamRS, DXSpider, Reverse Beacon Network client
- **WinLink:** AX25 support for Pat WinLink
- **Morse/CW:** morse (training program), morsegen, twcw, rscw, Wordsworth
- **Antenna modeling:** AA Analyzer, F4HTB PNA
- **Satellite/weather:** predict-gsat, XWeFax, hamfax, acfax
- **Misc/utilities:** WireGuard, wxWidgets, lopora, PyBOMBS, BOINC, CygnusRFI, CQRprop, Lady Heather, Go toolchain, colrconv, gcb, gnuais/gnuaisgui, Pi3/4 Stats Monitor, Auto WiFi Hotspot
- **System/framework:** init_task, configuration_tasks, install_menus, install_about, install_wallpaper, upgrade_debian_packages, install_bookmarks
