#!/system/bin/sh
MODDIR=${0%/*}
BASE=/data/adb/cj7_boot_guard
[ -d "$BASE" ] || exit 0
export CJ7_BASE=$BASE CJ7_LOG_DIR=$BASE/logs CJ7_MODDIR=$MODDIR
. "$MODDIR/scripts/logger.sh"
. "$MODDIR/scripts/health_check.sh"
. "$MODDIR/scripts/boot_monitor.sh"
cj7_config_load
# Bounded readiness watch; one property read every 5 seconds, then exit.
waited=0
while [ "$waited" -lt "$boot_wait_seconds" ]; do
    if [ "$(getprop sys.boot_completed 2>/dev/null)" = 1 ]; then
        cj7_boot_success
        cj7_health_scripts
        exit 0
    fi
    sleep 5
    waited=$((waited + 5))
done
cj7_log 'WARN' "Boot completion was not observed within ${boot_wait_seconds} seconds; failure count retained."
