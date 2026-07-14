# HamPi Trixie/Pi 5 — Milestone 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Get a fresh 64-bit Raspberry Pi OS Trixie Pi 5 provisioned with the ~20 core amateur-radio apps via a clean, modern Ansible playbook, each verified working on-device.

**Architecture:** A new, clean Milestone-1 playbook (`tasks/hampi_trixie.yml`) run from a **controller** (this box) over SSH against the Pi. Reworked arch/OS facts, a controller inventory, and group vars carrying feature flags + version pins. Apps resolve by the tiered rule: **Trixie arm64 apt** for the ~19 well-packaged apps, **upstream official arm64 `.deb`** for WSJT-X Improved / GridTracker / Pat. Legacy per-app files and multi-platform conditionals are left untouched (untested) — M1 builds the clean path alongside them.

**Tech Stack:** Ansible (≥2.12), Debian 13 Trixie apt, `get_url` + `apt: deb=` for upstream `.deb`s, SSH key auth.

> **Testing model (read first):** This is infrastructure, not unit-tested code. A task's "test" is: **run the relevant play against the Pi, then verify on-device** (binary present, `--version`, and idempotence: a second run reports `changed=0`). There is no pytest. "Expected output" in steps means the SSH/ansible output to look for.

## Global Constraints

- Target: Raspberry Pi OS **Trixie (Debian 13), arm64, Raspberry Pi 5** — verified reference device, passwordless sudo present. Real host/user/key live only in a local, gitignored `inventory/hampi.ini` (see `inventory/hampi.ini.example`).
- Ansible version floor: **2.12** (existing repo assertion).
- Tiered install rule: (1) upstream official arm64 artifact → (2) Trixie arm64 apt → (3) source build. Versions pinned as **variables**, never HTML-scraped.
- Optional/heavy apps gated by `install_*` boolean flags, not commented-out imports.
- `ham_user` = the connecting user (from your inventory), never hard-coded elsewhere.
- **Git:** commit messages are one line, conventional-commit style, **no body, no Claude trailer**. Identity is repo-local `DaiTengu <3505235+DaiTengu@users.noreply.github.com>` (already set); commits are SSH-signed (already configured). Work on branch `trixie-port`.
- Do **not** touch HamClock, or the legacy multi-platform (`hampc`/`iq`) code paths.

---

### Task 1: Controller inventory + reachability

**Files:**
- Create: `inventory/hampi.ini.example` (committed); real `inventory/hampi.ini` is local + gitignored
- Create: `inventory/group_vars/hampi.yml`

**Interfaces:**
- Produces: inventory group `hampi` (your Pi), and group vars `ham_user`, the `install_*` flags, and version-pin vars consumed by every later task.

- [ ] **Step 1: Write the example inventory (committed) + your local gitignored copy**

`inventory/hampi.ini.example` (copy to `inventory/hampi.ini`, gitignored, and fill in real values):
```ini
[hampi]
<pi-hostname> ansible_host=<pi-ip>

[hampi:vars]
ansible_user=<pi-user>
ansible_ssh_private_key_file=~/.ssh/<your-key>
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args=-o StrictHostKeyChecking=accept-new
```

- [ ] **Step 2: Write group vars (flags + version pins + ham_user)**

`inventory/group_vars/hampi.yml`:
```yaml
---
ham_user: "{{ ansible_user }}"          # the connecting user

# Feature flags (optional/upstream apps). Core apt apps are always on.
install_wsjtx_improved: true            # replaces mainline WSJT-X
install_wsjtz: false                    # opt-in: source build (later tranche)
install_gridtracker: true
install_pat: true

# Upstream .deb version pins (bump = one-line edit)
wsjtx_improved_version: "3.1.0"
wsjtx_improved_build: "260522"
wsjtx_improved_variant: "PLUS"          # PLUS | AL_PLUS | widescreen_PLUS
wsjtx_improved_os: "trixie"             # match target OS codename
gridtracker_version: "2.260705.2"
```

- [ ] **Step 3: Verify reachability + become**

Run:
```bash
cd /home/daitengu/ham/HamPi
ansible -i inventory/hampi.ini hampi -m ping
ansible -i inventory/hampi.ini hampi -b -m command -a 'id' | grep -q 'uid=0(root)' && echo "become OK"
```
Expected: `<your-pi> | SUCCESS => ... "ping": "pong"`, and `become OK`.

- [ ] **Step 4: Commit**

```bash
git add inventory/hampi.ini inventory/group_vars/hampi.yml
git commit -m "feat: add Trixie controller inventory and group vars"
```

---

### Task 2: Fix arch/OS facts for aarch64 + Trixie

**Files:**
- Modify: `library/set_facts.yml`

**Interfaces:**
- Produces: correct `is_arm_64` (true only on aarch64) and new `is_trixie` fact, consumed by any conditional task logic.

- [ ] **Step 1: Fix the `is_arm_64` bug**

In `library/set_facts.yml`, the "Set facts for 64-bit ARM CPU" block currently fires for `armhf`/`armv7l`/`aarch64`. Change its `when` to fire only on aarch64:
```yaml
  - name: Set facts for 64-bit ARM CPU
    set_fact:
      is_arm: True
      is_arm_64: True
      is_x86_64: False
    when: ansible_architecture == "aarch64"
```

- [ ] **Step 2: Add Trixie release fact**

Add after the Bookworm block:
```yaml
  - name: Set facts for Debian Trixie
    set_fact:
      is_buster: False
      is_bullseye: False
      is_bookworm: False
      is_trixie: True
      is_jammy: False
    when: (is_debian|bool or is_ubuntu|bool) and ansible_distribution_release == "trixie"
```

- [ ] **Step 3: Verify facts resolve correctly on the device**

Run:
```bash
ansible -i inventory/hampi.ini hampi -m include_role -a name=nonexistent 2>/dev/null; \
ansible-playbook -i inventory/hampi.ini library/set_facts.yml \
  -e 'verify=1' --tags always 2>&1 | tail -5
# Then confirm the values:
ansible -i inventory/hampi.ini hampi -m setup -a 'filter=ansible_architecture,ansible_distribution_release'
```
Expected: `ansible_architecture: aarch64`, `ansible_distribution_release: trixie` (confirming the `when` conditions above will match). `set_facts.yml` runs without assertion errors.

- [ ] **Step 4: Commit**

```bash
git add library/set_facts.yml
git commit -m "fix: correct is_arm_64 to aarch64-only and add is_trixie fact"
```

---

### Task 3: Core apt apps

**Files:**
- Create: `tasks/core_apt_apps.yml`

**Interfaces:**
- Consumes: inventory group `hampi`, `ham_user`.
- Produces: the 19 apt-installed core apps on the device.

- [ ] **Step 1: Write the play**

`tasks/core_apt_apps.yml`:
```yaml
#
# Core amateur-radio apps available in Trixie arm64 apt (Tier 2).
# Versions confirmed on-device 2026-07-14 (see plan).
#
- name: Install Trixie apt core apps
  hosts: hampi
  become: yes
  tags: core_apt
  tasks:
    - name: apt-install core ham apps
      apt:
        update_cache: yes
        state: present
        name:
          - libhamlib-utils        # 4.6.2  rig control (rigctl/rigctld)
          - flrig                  # 2.0.05 rig control GUI
          - fldigi                 # 4.2.06 digital modes
          - flmsg                  # 4.0.23 ICS-213 forms
          - flamp                  # 2.2.14 amateur multicast
          - jtdx                   # 2.2.159+improved  FT8/FT4 (alt)
          - direwolf               # 1.7    AX.25/APRS TNC
          - xastir                 # 2.2.0  APRS GUI
          - cqrlog                 # 2.5.2  logging
          - klog                   # 2.4.1  logging
          - xlog                   # 2.0.24 logging
          - trustedqsl             # 2.8.1  LoTW (tqsl)
          - soapysdr-tools         # 0.8.1  SDR abstraction (SoapySDRUtil)
          - soapysdr-module-all    # 0.8.1  all Soapy driver modules
          - rtl-sdr                # 2.0.2  RTL-SDR tools
          - gqrx-sdr               # 2.17.6 SDR receiver GUI
          - gpredict               # 2.3+   satellite tracking
          - qsstv                  # 9.5.8  slow-scan TV
          - chirp                  # 20250502 radio programming (chirp-next)
          - js8call                # 2.2.0  JS8 messaging (apt baseline; upstream 2.3.1 later)
```

- [ ] **Step 2: Run it against the Pi**

Run:
```bash
ansible-playbook -i inventory/hampi.ini tasks/core_apt_apps.yml
```
Expected: `changed` on first run, `failed=0`.

- [ ] **Step 3: Verify binaries present on-device**

Run:
```bash
ssh -i ~/.ssh/<your-key> <pi-user>@<pi-host> '
for b in rigctl flrig fldigi flmsg flamp jtdx direwolf xastir cqrlog klog xlog tqsl SoapySDRUtil rtl_test gqrx gpredict qsstv chirp js8call; do
  command -v "$b" >/dev/null 2>&1 && echo "OK  $b" || echo "MISSING $b"
done'
```
Expected: `OK` for every binary. (`rigctl` from libhamlib-utils, `tqsl` from trustedqsl, `SoapySDRUtil` from soapysdr-tools, `rtl_test` from rtl-sdr.)

- [ ] **Step 4: Verify idempotence**

Run: `ansible-playbook -i inventory/hampi.ini tasks/core_apt_apps.yml`
Expected: `changed=0` (all already present).

- [ ] **Step 5: Commit**

```bash
git add tasks/core_apt_apps.yml
git commit -m "feat: add Trixie apt core-apps play (19 apps)"
```

---

### Task 4: WSJT-X Improved (Tier 1 upstream .deb, replaces mainline WSJT-X)

**Files:**
- Modify (rewrite): `tasks/install_wsjtx.yml`

**Interfaces:**
- Consumes: `install_wsjtx_improved`, `wsjtx_improved_*` vars from group_vars.
- Produces: the `wsjtx` binary (DG2YCB Improved build) on the device.

- [ ] **Step 1: Rewrite the play**

Replace the contents of `tasks/install_wsjtx.yml` with:
```yaml
#
# WSJT-X Improved (DG2YCB) — official arm64 .deb, replaces mainline WSJT-X.
#
- name: Install WSJT-X Improved
  hosts: hampi
  become: yes
  tags: wsjtx
  tasks:
    - name: Download WSJT-X Improved .deb
      when: install_wsjtx_improved | default(true) | bool
      get_url:
        url: "https://sourceforge.net/projects/wsjt-x-improved/files/WSJT-X_v{{ wsjtx_improved_version }}/Raspberry%20Pi/wsjtx-{{ wsjtx_improved_version }}_improved_{{ wsjtx_improved_variant }}_{{ wsjtx_improved_build }}_Rpi_{{ wsjtx_improved_os }}_arm64.deb/download"
        dest: "/tmp/wsjtx-improved.deb"
        mode: "0644"
      retries: 3
      delay: 10
      register: dl
      until: dl is succeeded

    - name: Install WSJT-X Improved (apt resolves deps)
      when: install_wsjtx_improved | default(true) | bool
      apt:
        deb: "/tmp/wsjtx-improved.deb"
```

- [ ] **Step 2: Run it**

Run: `ansible-playbook -i inventory/hampi.ini tasks/install_wsjtx.yml`
Expected: `changed`, `failed=0`. (If apt reports an unmet Qt dependency, the fix is to add the missing `libqt5*` package to the play and note it — Qt5 is present in Trixie, so this is not expected.)

- [ ] **Step 3: Verify it's the Improved build**

Run:
```bash
ssh -i ~/.ssh/<your-key> <pi-user>@<pi-host> \
  'dpkg-query -W -f="${Version}\n" wsjtx; wsjtx --version 2>/dev/null | head -1'
```
Expected: version string containing `3.1.0` / `improved`.

- [ ] **Step 4: Commit**

```bash
git add tasks/install_wsjtx.yml
git commit -m "feat: install WSJT-X Improved arm64 .deb, replacing mainline WSJT-X"
```

---

### Task 5: GridTracker (Tier 1 upstream .deb)

**Files:**
- Modify (rewrite): `tasks/install_gridtracker.yml`

**Interfaces:**
- Consumes: `install_gridtracker`, `gridtracker_version`.
- Produces: `gridtracker2` package on the device.

- [ ] **Step 1: Rewrite the play**

Replace `tasks/install_gridtracker.yml` with:
```yaml
#
# GridTracker 2 — official arm64 .deb (gridtracker.org).
#
- name: Install GridTracker 2
  hosts: hampi
  become: yes
  tags: gridtracker
  tasks:
    - name: Download GridTracker 2 arm64 .deb
      when: install_gridtracker | default(true) | bool
      get_url:
        url: "https://download2.gridtracker.org/GridTracker2-{{ gridtracker_version }}-arm64.deb"
        dest: "/tmp/gridtracker2.deb"
        mode: "0644"
      retries: 3
      delay: 10
      register: dl
      until: dl is succeeded

    - name: Install GridTracker 2 (apt resolves deps)
      when: install_gridtracker | default(true) | bool
      apt:
        deb: "/tmp/gridtracker2.deb"
```

- [ ] **Step 2: Run it**

Run: `ansible-playbook -i inventory/hampi.ini tasks/install_gridtracker.yml`
Expected: `changed`, `failed=0`.

- [ ] **Step 3: Verify**

Run:
```bash
ssh -i ~/.ssh/<your-key> <pi-user>@<pi-host> \
  'dpkg -l | grep -i gridtracker; ls /opt/GridTracker2 2>/dev/null || command -v gridtracker2'
```
Expected: gridtracker2 package listed / launcher present.

- [ ] **Step 4: Commit**

```bash
git add tasks/install_gridtracker.yml
git commit -m "feat: install GridTracker 2 official arm64 .deb"
```

---

### Task 6: Pat Winlink (Tier 1 upstream .deb via GitHub release)

**Files:**
- Modify (rewrite): `tasks/install_pat.yml`

**Interfaces:**
- Consumes: `install_pat`.
- Produces: `pat` binary on the device.

- [ ] **Step 1: Rewrite the play (fetch latest arm64 .deb from GitHub releases)**

Replace `tasks/install_pat.yml` with:
```yaml
#
# Pat (Winlink) — latest official arm64 .deb from GitHub releases (la5nta/pat).
#
- name: Install Pat Winlink
  hosts: hampi
  become: yes
  tags: pat
  tasks:
    - name: Query latest Pat release
      when: install_pat | default(true) | bool
      uri:
        url: https://api.github.com/repos/la5nta/pat/releases/latest
        return_content: yes
      register: pat_rel

    - name: Resolve arm64 .deb asset URL
      when: install_pat | default(true) | bool
      set_fact:
        pat_deb_url: "{{ (pat_rel.json.assets | selectattr('name','search','linux_arm64\\.deb$') | map(attribute='browser_download_url') | list | first) }}"

    - name: Download Pat arm64 .deb
      when: install_pat | default(true) | bool
      get_url:
        url: "{{ pat_deb_url }}"
        dest: "/tmp/pat.deb"
        mode: "0644"

    - name: Install Pat
      when: install_pat | default(true) | bool
      apt:
        deb: "/tmp/pat.deb"
```

- [ ] **Step 2: Run it**

Run: `ansible-playbook -i inventory/hampi.ini tasks/install_pat.yml`
Expected: `changed`, `failed=0`. (If `pat_deb_url` resolves empty, inspect the asset names with
`curl -s https://api.github.com/repos/la5nta/pat/releases/latest | grep -o '"name": "[^"]*\.deb"'`
and adjust the `search` regex — the current one matches `..._linux_arm64.deb`.)

- [ ] **Step 3: Verify**

Run:
```bash
ssh -i ~/.ssh/<your-key> <pi-user>@<pi-host> 'pat version 2>/dev/null || pat --version'
```
Expected: a Pat version (≥1.0.0).

- [ ] **Step 4: Commit**

```bash
git add tasks/install_pat.yml
git commit -m "feat: install Pat Winlink latest arm64 .deb from GitHub releases"
```

---

### Task 7: Milestone-1 master playbook + run wrapper

**Files:**
- Create: `tasks/hampi_trixie.yml`
- Create: `run_trixie`

**Interfaces:**
- Consumes: all task plays above.
- Produces: single entry point that provisions the whole core set.

- [ ] **Step 1: Write the master playbook**

`tasks/hampi_trixie.yml`:
```yaml
#
# HamPi Trixie / Pi 5 — Milestone 1 master playbook.
#
- import_playbook: ../library/set_facts.yml
- import_playbook: core_apt_apps.yml
- import_playbook: install_wsjtx.yml
- import_playbook: install_gridtracker.yml
- import_playbook: install_pat.yml
```

- [ ] **Step 2: Write the run wrapper**

`run_trixie`:
```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
ansible-playbook -i inventory/hampi.ini tasks/hampi_trixie.yml "$@"
```
Then: `chmod +x run_trixie`

- [ ] **Step 3: Full clean run**

Run: `./run_trixie`
Expected: `failed=0` across all plays.

- [ ] **Step 4: Full idempotence run**

Run: `./run_trixie`
Expected: `changed=0` (nothing to do on a second run; download tasks may re-fetch — acceptable, note any that do).

- [ ] **Step 5: Commit**

```bash
git add tasks/hampi_trixie.yml run_trixie
git commit -m "feat: add Milestone-1 master playbook and run wrapper"
```

---

### Task 8: Milestone-1 verification + install docs

**Files:**
- Create: `docs/install-milestone-1.md`

**Interfaces:**
- Consumes: the running system.
- Produces: a documented, reproducible install + a recorded pass/fail matrix.

- [ ] **Step 1: On-device verification sweep**

Run:
```bash
ssh -i ~/.ssh/<your-key> <pi-user>@<pi-host> '
for b in rigctl flrig fldigi flmsg flamp jtdx direwolf xastir cqrlog klog xlog tqsl \
         SoapySDRUtil rtl_test gqrx gpredict qsstv chirp js8call wsjtx pat; do
  command -v "$b" >/dev/null 2>&1 && echo "OK  $b" || echo "MISSING $b"
done
dpkg -l | grep -iE "gridtracker" >/dev/null && echo "OK  gridtracker2" || echo "MISSING gridtracker2"'
```
Expected: `OK` for all. Record any `MISSING` and resolve before closing the milestone.

- [ ] **Step 2: Write the install doc**

`docs/install-milestone-1.md` documents: flashing Raspberry Pi OS (64-bit) Trixie; enabling SSH + the user; installing ansible on the controller; the inventory (`inventory/hampi.ini`); running `./run_trixie`; the feature flags; and the verification sweep above. (Full end-user content — this is the first page of the in-repo docs plan.)

- [ ] **Step 3: Commit**

```bash
git add docs/install-milestone-1.md
git commit -m "docs: add Milestone-1 install guide and verification sweep"
```

---

## Self-Review

**Spec coverage** (against `2026-07-14-hampi-trixie-port-design.md`):
- Tiered rule → Tasks 3 (apt) + 4/5/6 (upstream .deb). ✅
- Framework: arch/OS facts → Task 2 ✅; controller run-mode/inventory → Task 1 ✅; version-as-variables → group_vars (Task 1) ✅; optional-app flags → group_vars + `when` guards ✅.
- Build flags (`-mcpu=cortex-a76`), PEP 668 pipx/venv, NetworkManager, labwc, audio: **not exercised in M1** because M1 has no on-device source builds, no pip installs, and no network/desktop reconfiguration (all apps are apt/.deb with their own launchers). These framework items are **deferred to the tranche that first needs them** (e.g., a source-built or pip app) — noted here so the gap is intentional, not missed. WSJT-X mainline replacement → Task 4 ✅. WSJT-Z disabled → flag in Task 1 (`install_wsjtz: false`), build deferred to a tranche ✅.
- Core-set (18–20 apps) → Tasks 3–6 cover all listed core apps. ✅
- Docs → Task 8 ✅.
- Non-goals (HamClock, rpitx, multi-platform) → untouched. ✅

**Placeholder scan:** No TBDs. The two "if it fails, adjust" notes (WSJT-X Qt dep, Pat asset regex) are concrete fallback instructions with exact diagnostic commands, not placeholders.

**Type/naming consistency:** Var names (`install_wsjtx_improved`, `wsjtx_improved_*`, `gridtracker_version`, `install_pat`) are defined in Task 1 group_vars and consumed identically in Tasks 4/5/6. Inventory path `inventory/hampi.ini` and group `hampi` used consistently. Binary names in verification match the packages installed.

**Deferred-but-tracked:** js8call stays at apt 2.2.0 for M1 (upstream 2.3.1 is a later tranche); CHIRP uses apt `20250502` (pipx-latest optional later); Direwolf apt 1.7 (upstream 1.8.1 optional later). These are recorded so "apt for now" is a logged decision, not silent staleness.
