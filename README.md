# CJ7 AI BOOT GUARD

**Version:** 1.0.0  
**Developer:** CJ7  
**Description:** Intelligent Universal Android Bootloop Protection & Recovery System.  
**License:** GPL-3.0

CJ7 AI BOOT GUARD uses transparent shell rules. It counts root-manager boot starts that have not yet reached `sys.boot_completed=1`, logs readiness and compatibility information, and recognizes repeated unsuccessful starts. It does not use machine learning, network access, continuous polling, or performance tuning.

## Safety model

Automatic recovery is enabled by default but is deliberately constrained. It only creates the standard reversible `disable` marker for a module when BOTH conditions are met:

1. Its exact module ID appears one per line in `/data/adb/cj7_boot_guard/recovery_allowlist`.
2. The module directory contains a regular file named `cj7_managed`.

The target is searched only under `/data/adb/modules/` and `/data/adb/modules_update/`. CJ7 does not create ownership markers, scan for suspected offenders, disable unrelated modules, delete module files, or restore arbitrary files. The administrator opts a CJ7-owned module into recovery by placing its marker and allowlist entry. A threshold recovery attempt happens at post-fs-data stage and normally prevents later module stages on that boot; scripts already run earlier in the stage cannot be undone. Recovery history records each successful change.

No universal shell heuristic can reliably identify which module caused a failed boot. The allowlist therefore represents administrator identification, not an AI diagnosis. If the list is absent or empty, automatic recovery is a logged no-op.

## Install

1. Download or copy the `CJ7-AI-Boot-Guard` directory to a computer.
2. Zip the **contents** of the directory so `module.prop` is at the ZIP root. For example, from inside the directory: `zip -r ../CJ7-AI-Boot-Guard-v1.0.0.zip .`.
3. In Magisk, KernelSU, or APatch, choose Install from storage and select the ZIP. This package intentionally refuses recovery-mode installation.
4. Reboot and confirm status with `su -c '/data/adb/modules/cj7_ai_boot_guard/status.sh'` (the manager's installed module path may differ if the ID was changed).

Designed for Android 10+ (API 29+), with conservative shell-only fallbacks. Root managers differ in lifecycle details; unsupported or unreadable environment data is logged and does not cause system changes. No module can guarantee compatibility with every vendor build or root manager.

## Configuration

Runtime config: `/data/adb/cj7_boot_guard/config.conf`. It is parsed as data and never sourced as shell code. Values outside supported bounds are ignored, leaving defaults for that key. Edit atomically and use numeric values only:

| Key | Default | Meaning |
|---|---:|---|
| `automatic_recovery` | 1 | Allow constrained allowlist recovery at threshold |
| `boot_failure_threshold` | 3 | Unconfirmed starts before recovery (2–10) |
| `debug_logging` | 0 | Reserved verbose diagnostic switch |
| `manual_recovery_mode` | 0 | When 1, threshold never changes module markers |
| `boot_wait_seconds` | 900 | Documented readiness window; bounded to 60–1800 |

Example: set `manual_recovery_mode=1` for observation-only operation. Runtime config is preserved on uninstall for review. `post-fs-data.sh` initializes it only if absent.

## Explicit recovery enrollment

Only enroll modules you own and can recover. As root, for example:

```sh
mkdir -p /data/adb/modules/my_cj7_module
: > /data/adb/modules/my_cj7_module/cj7_managed
printf '%s\n' my_cj7_module >> /data/adb/cj7_boot_guard/recovery_allowlist
chmod 0600 /data/adb/cj7_boot_guard/recovery_allowlist
```

Do not enroll another developer's module. The example path is illustrative; only put the marker inside a real module directory you control. To reverse a recovery, inspect the history and remove only the generated `disable` marker from that module directory, then reboot when safe.

## Commands and logs

Root-manager-installed top-level scripts:

```sh
su -c '/data/adb/modules/cj7_ai_boot_guard/status.sh'
su -c '/data/adb/modules/cj7_ai_boot_guard/recovery.sh status'
su -c '/data/adb/modules/cj7_ai_boot_guard/recovery.sh allowlist'
su -c '/data/adb/modules/cj7_ai_boot_guard/recovery.sh run'
su -c '/data/adb/modules/cj7_ai_boot_guard/backup.sh'
su -c '/data/adb/modules/cj7_ai_boot_guard/restore.sh'
```

`recovery.sh run` is an explicit manual pass over the same allowlist and ownership checks. Backup/restore utilities operate only on files under the CJ7 state directory and its `backups` subdirectory. Logs and reports are stored under `/data/adb/cj7_boot_guard/logs/`: `current.log`, `history.log`, `boot_history.log`, `recovery_history.log`, and `compatibility.txt`.

If a device cannot boot, use the root manager's safe mode/disable feature, or remove only the module's own module directory using that manager's documented recovery procedure. Do not delete arbitrary `/data/adb/modules` entries. If a previously enrolled module was disabled, remove its `disable` marker after diagnosis. User data and original system files are not touched by this module.

## Safe testing (no real bootloop)

Use an emulator or spare test device when possible. Keep root-manager safe mode and ADB/recovery access available. Do not make boot scripts fail and do not reboot repeatedly to test thresholds.

1. Install and boot normally; check that `boot_count` returns to `0` after `sys.boot_completed=1`, and inspect compatibility and boot logs.
2. Set `manual_recovery_mode=1`, then use a disposable copy of the state directory in a shell sandbox to exercise malformed counters/config values. Confirm invalid data does not trigger target changes.
3. On a disposable test module only, create `cj7_managed`, allowlist its exact ID, and invoke `recovery.sh run`. Confirm only that test module receives a `disable` marker and the recovery history is written. Remove the marker afterward.
4. Repeat with an allowlisted module lacking the ownership marker and confirm it is skipped. Never test against unrelated or production modules.
5. To simulate a threshold without rebooting, in a disposable emulator set the private state counter to threshold minus one, set manual mode to 0 and automatic recovery to 1, then source/call the boot monitor with a temporary `CJ7_BASE` and a test-only fake modules tree. The installed recovery implementation is intentionally fixed to `/data/adb/modules*`; do not alter production module paths to conduct this test.

For the strongest safe test, review the scripts statically and run shell syntax checks on a Linux host with `sh -n`. Actual vendor boot failure detection cannot be fully validated without a controlled test environment.

## Files

- `module.prop`: root manager identity and release metadata.
- `customize.sh`: installer compatibility message and API detection.
- `post-fs-data.sh`: private runtime state initialization and compatibility report; begins the boot counter.
- `service.sh`: bounded, five-second readiness watch that exits on success or timeout.
- `uninstall.sh`: leaves logs and state for diagnostics; no unrelated path is touched.
- `config.conf`: shipped default configuration template.
- `recovery.sh`, `status.sh`, `backup.sh`, `restore.sh`: root-facing command wrappers.
- `scripts/boot_monitor.sh`: safe config parser, atomic counter, boot attempt and success records.
- `scripts/recovery.sh`: strict ID validation and allowlist plus ownership-marker enforcement.
- `scripts/health_check.sh`: Android/root-manager report and required-file checks.
- `scripts/logger.sh`: bounded current log and append-only history logging.
- `scripts/backup.sh`, `scripts/restore.sh`, `scripts/status.sh`: constrained state operations and diagnostics.
- `META-INF/...`: explicitly refuses unsupported recovery-mode installation.
