# HamPi64 (Trixie / Pi 5) — TODO / Roadmap

Forward-looking work only. The big app-porting push is done — for the full picture of what's
installed vs. not, see [`coverage.md`](coverage.md) (including the "Not in HamPi64" gap list).

## Version bumps (apt is behind upstream)
- **JS8Call**: apt 2.2.0 → upstream 2.3.1
- **Direwolf**: apt 1.7 → upstream 1.8.1

## Opt-in / candidates to evaluate
- **OpenWebRX** — active + arm64-capable, but a full web-SDR server + service; add as a deliberate
  opt-in flag (like WSJT-Z / BOINC), not auto-installed.
- **SatDump** — modern, arm64, multi-satellite; the intended replacement for the (not-viable)
  medet + wxtoimg. Good candidate to add for weather/satellite imaging.
- **Zenith** satellite tracker + APRS — trial the hosted version (web.zenithtracker.org) first to
  decide if it earns a place; gpredict + Xastir already cover satellite + APRS.

## Deferred apps that could still be revisited
See the **"Deferred — feasible, just not done yet"** section of [`coverage.md`](coverage.md):
YAAC, ARDOP/Patmenu2/Find ARDOP, wsjtx_to_n3fjp, BlueDV, predict-gsat, fbb, twlog, twcw, acfax,
CygnusRFI, multimon (original), Pi3/4 Stats Monitor, Auto WiFi Hotspot, install_bookmarks,
country-files download, APRS Message App for JS8Call, Open Wouxun. Each is a per-app decision.

## Release / packaging (later milestone)
- Run the playbook against a **clean, freshly-flashed** Trixie image (not the dev Pi) and confirm a
  from-scratch build works end to end.
- Capture the result as a distributable `.img` (shrink, or a pi-gen build). Build the image with the
  non-free components **excluded** (the default); the **HamPi64 Extras** launcher installs those on
  first run under each vendor's license. (This replaces the old "confirm SDRplay redistribution terms"
  item — resolved by deferring non-free installs instead of baking them in.)
- **De-personalize before capture:** run `packaging_utilities/prepare_image_for_release.sh` on the
  build Pi (strips identity/secrets, re-arms first-boot user creation), then validate by flashing the
  captured image to a spare card.
- Default-user question is **settled**: the image ships **userless** and the operator picks their
  username on first boot (per-user data via `/etc/skel`) — no hardcoded `pi` / `ham_user`. A pi-gen
  (chroot) build is the reproducible alternative to golden-imaging.
