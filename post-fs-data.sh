#!/system/bin/sh
MODDIR=${0%/*}
BASE=/data/adb/cj7_boot_guard
umask 077
mkdir -p "$BASE/logs" "$BASE/backups" || exit 0
if [ ! -f "$BASE/config.conf" ]; then
    cp "$MODDIR/config.conf" "$BASE/config.conf.tmp" 2>/dev/null && mv "$BASE/config.conf.tmp" "$BASE/config.conf" 2>/dev/null
fi
[ -f "$BASE/config.conf" ] && [ ! -L "$BASE/config.conf" ] && chmod 0600 "$BASE/config.conf" 2>/dev/null
CJ7_BASE=$BASE CJ7_LOG_DIR=$BASE/logs CJ7_MODDIR=$MODDIR
export CJ7_BASE CJ7_LOG_DIR CJ7_MODDIR
. "$MODDIR/scripts/logger.sh"
. "$MODDIR/scripts/health_check.sh"
cj7_health_scripts
cj7_health_compatibility > "$BASE/logs/compatibility.txt.tmp" 2>/dev/null && mv "$BASE/logs/compatibility.txt.tmp" "$BASE/logs/compatibility.txt"
# Keep boot-stage work bounded and avoid sourcing untrusted configuration as shell.
. "$MODDIR/scripts/boot_monitor.sh"
cj7_boot_begin
