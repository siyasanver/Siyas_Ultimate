#!/system/bin/sh
# ================================================================
#  Siyas Game Boost - action.sh
#  Triggered when the user taps the Action button in
#  KernelSU / ResuKISU / Magisk Manager.
#
#  Shell: /system/bin/sh (POSIX sh, NOT bash)
#  Runs as: root
# ================================================================

MODDIR="${0%/*}"
LOG_FILE="/data/local/tmp/siyas_boost.log"
WEBROOT="$MODDIR/webroot"
PORT="8080"
HTTPD_PID="/data/local/tmp/siyas_httpd.pid"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ACTION] $1" >> "$LOG_FILE"
}

log "================================================"
log " Action button triggered — starting full boost  "
log "================================================"

# ── 1. CPU: switch to max performance governor ──────────────
# 'performance' locks the CPU at its highest frequency.
# We also set scaling_min_freq = scaling_max_freq to prevent
# the scheduler from ever clocking down during gameplay.
log "Step 1: CPU max performance"
for _cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
    [ -d "$_cpu" ] || continue
    echo "performance" > "$_cpu/scaling_governor" 2>/dev/null
    _max=""
    [ -f "$_cpu/cpuinfo_max_freq" ] && _max="$(cat "$_cpu/cpuinfo_max_freq")"
    [ -n "$_max" ] && echo "$_max" > "$_cpu/scaling_min_freq" 2>/dev/null
done
log "CPU: performance governor, all cores at max freq"

# ── 2. GPU: force maximum frequency ─────────────────────────
# devfreq is the kernel's dynamic frequency scaling for
# devices like the GPU. Setting governor to 'performance'
# and min_freq = max_freq locks it at the ceiling.
log "Step 2: GPU max performance"
for _gpu in /sys/class/devfreq/*/; do
    [ -d "$_gpu" ] || continue
    _max=""
    [ -f "${_gpu}max_freq" ] && _max="$(cat "${_gpu}max_freq")"
    [ -n "$_max" ] && echo "$_max" > "${_gpu}min_freq"  2>/dev/null
    echo "performance" > "${_gpu}governor" 2>/dev/null
done
log "GPU: max frequency locked"

# ── 3. Kill background processes ────────────────────────────
# 'am kill-all' asks ActivityManager to kill cached
# background processes — this is the safe, official API.
log "Step 3: Kill background processes"
am kill-all 2>/dev/null
log "Background processes cleared via am kill-all"

# ── 4. Flush kernel caches ──────────────────────────────────
# echo 3 to drop_caches flushes:
#   1 = page cache
#   2 = dentries and inodes
#   3 = all of the above combined
# We sync first to flush dirty pages to storage safely.
log "Step 4: Cache flush"
sync
echo "3" > /proc/sys/vm/drop_caches 2>/dev/null
log "Kernel caches flushed (sync + drop_caches=3)"

# Also clean app-level cache dirs
find /data/data/*/cache -maxdepth 0 -type d 2>/dev/null | while read -r _dir; do
    rm -rf "${_dir:?}"/* 2>/dev/null
done
log "App cache directories cleaned"

# ── 5. FPS — set display refresh rate ───────────────────────
# SurfaceFlinger service call 1016 sets the display's
# preferred refresh rate. We request 90Hz by default.
log "Step 5: Display refresh rate -> 90Hz"
service call SurfaceFlinger 1016 i32 90 2>/dev/null
log "Display target: 90fps"

# ── 6. Touch sampling rate ───────────────────────────────────
# These sysfs nodes vary by touchscreen driver/vendor.
# We write to every known path; silent failure on absent nodes.
log "Step 6: Touch sampling -> 240Hz"
for _node in \
    /sys/bus/i2c/devices/*/report_rate          \
    /sys/bus/i2c/devices/*/touch_sample_rate    \
    /proc/touchpanel/report_rate                \
    /sys/devices/virtual/touch/touch/report_rate_enable; do
    [ -e "$_node" ] && echo "240" > "$_node" 2>/dev/null
done
log "Touch sampling: 240Hz applied to available nodes"

# ── 7. Boost detected game process ──────────────────────────
# We scan for known game packages and apply kernel-level
# scheduling boosts to whatever process we find running.
log "Step 7: Boosting game PID"
_game_pid=""
for _pkg in \
    com.pubg.imobile                      \
    com.mobile.legends                    \
    com.tencent.ig                        \
    com.dts.freefireth                    \
    com.miHoYo.GenshinImpact              \
    com.activision.callofduty.shooter     \
    com.HoYoverse.hkrpgoversea; do
    _pid="$(pgrep -f "$_pkg" 2>/dev/null | head -1)"
    if [ -n "$_pid" ]; then
        _game_pid="$_pid"
        log "Found game: $_pkg (PID $_pid)"
        break
    fi
done

if [ -n "$_game_pid" ]; then
    # SCHED_FIFO priority 99 — highest real-time scheduling class
    chrt -f -p 99 "$_game_pid" 2>/dev/null
    # renice to -20 = highest priority in normal scheduler
    renice -20 "$_game_pid"    2>/dev/null
    # Move to top-app cpuset so it gets the big cores
    echo "$_game_pid" > /dev/cpuset/top-app/tasks    2>/dev/null
    echo "$_game_pid" > /dev/cpuset/foreground/tasks 2>/dev/null
    # OOM score -1000 = this process will NEVER be killed by lmkd
    echo "-1000" > "/proc/$_game_pid/oom_score_adj"  2>/dev/null
    log "PID $_game_pid: SCHED_FIFO 99, top-app cpuset, OOM=-1000"
else
    log "No active game process found (launch your game first)"
fi

# ── 8. Ensure WebUI is running ───────────────────────────────
log "Step 8: Ensuring WebUI is alive"
_webui_alive=false
if [ -f "$HTTPD_PID" ]; then
    _pid="$(cat "$HTTPD_PID")"
    kill -0 "$_pid" 2>/dev/null && _webui_alive=true
fi

if [ "$_webui_alive" = "false" ]; then
    log "WebUI not running — starting now"
    if busybox httpd --help > /dev/null 2>&1; then
        busybox httpd -p "$PORT" -h "$WEBROOT" -f &
        echo "$!" > "$HTTPD_PID"
        log "WebUI started: busybox httpd PID=$!"
    else
        while true; do
            {
                printf "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n"
                cat "$WEBROOT/index.html"
            } | nc -l -p "$PORT" -q 1 2>/dev/null
        done &
        echo "$!" > "$HTTPD_PID"
        log "WebUI started: nc fallback PID=$!"
    fi
else
    log "WebUI already running on port $PORT"
fi

# ── 9. Open WebUI in device browser ─────────────────────────
am start -a android.intent.action.VIEW \
         -d "http://localhost:$PORT"   \
         > /dev/null 2>&1
log "Browser launched -> http://localhost:$PORT"

log "================================================"
log " Full boost sequence complete                   "
log "================================================"
