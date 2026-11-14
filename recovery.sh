#!/system/bin/sh
MODDIR=${0%/*}
export CJ7_BASE=/data/adb/cj7_boot_guard CJ7_LOG_DIR=/data/adb/cj7_boot_guard/logs CJ7_MODDIR=$MODDIR
[ "$(id -u 2>/dev/null)" = 0 ] || { echo 'ERROR: Run as root.'; exit 1; }
. "$MODDIR/scripts/logger.sh"
. "$MODDIR/scripts/boot_monitor.sh"
. "$MODDIR/scripts/recovery.sh"
case "${1:-status}" in
    allowlist) [ -f "$CJ7_BASE/recovery_allowlist" ] && cat "$CJ7_BASE/recovery_allowlist" || echo '(no allowlisted modules)';;
    run) cj7_manual_recover; echo 'Recovery pass complete; see recovery_history.log.';;
    *) echo 'Usage: recovery.sh {status|allowlist|run}'; echo 'run adds disable markers only to allowlisted modules carrying cj7_managed.';;
esac
