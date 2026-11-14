#!/system/bin/sh
# Root manager invokes this when removing the module. Delete CJ7 runtime state only.
BASE=/data/adb/cj7_boot_guard
[ -d "$BASE" ] || exit 0
# Preserve logs and recovery evidence; config and counters are also retained for review.
exit 0
