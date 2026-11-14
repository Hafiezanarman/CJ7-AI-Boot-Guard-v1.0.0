#!/system/bin/sh
SKIPUNZIP=0
ui_print '*******************************'
ui_print 'CJ7 AI BOOT GUARD 1.0.0'
ui_print 'Developer: CJ7'
ui_print '*******************************'
SDK=$(getprop ro.build.version.sdk 2>/dev/null)
case "$SDK" in ''|*[!0-9]*) abort 'Cannot determine Android API level; installation stopped safely.';; esac
if [ "$SDK" -lt 29 ]; then ui_print "- Android API $SDK detected (below Android 10); compatible shell fallback will be used."; else ui_print "- Android API $SDK detected."; fi
ui_print '- No boot image, partitions, kernel parameters, or unrelated modules will be modified.'
ui_print '- Automatic recovery affects only explicitly allowlisted CJ7-managed modules.'
MODPATH=${MODPATH:-${0%/*}}
for required in module.prop post-fs-data.sh service.sh uninstall.sh scripts/boot_monitor.sh scripts/recovery.sh scripts/health_check.sh scripts/logger.sh scripts/backup.sh scripts/restore.sh scripts/status.sh; do
    if [ ! -s "$MODPATH/$required" ]; then abort "Required module file missing or empty: $required"; fi
done
for required in post-fs-data.sh service.sh uninstall.sh scripts/boot_monitor.sh scripts/recovery.sh scripts/health_check.sh scripts/logger.sh scripts/backup.sh scripts/restore.sh scripts/status.sh; do
    if [ ! -x "$MODPATH/$required" ]; then abort "Required module script is not executable: $required"; fi
done
ui_print '- Required scripts and permissions are present.'
