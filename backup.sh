#!/system/bin/sh
MODDIR=${0%/*}
export CJ7_BASE=/data/adb/cj7_boot_guard CJ7_LOG_DIR=/data/adb/cj7_boot_guard/logs CJ7_MODDIR=$MODDIR
exec "$MODDIR/scripts/backup.sh" "$@"
