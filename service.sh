#!/system/bin/sh
# ================================================================
#  Siyas Game Boost - service.sh
# ================================================================

MODDIR="${0%/*}"
LOG_FILE="/data/local/tmp/siyas_boost.log"
WEBROOT="$MODDIR/webroot"
PORT="8080"
HTTPD_PID="/data/local/tmp/siyas_httpd.pid"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

for _gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$_gov" ] && echo "schedutil" > "$_gov" 2>/dev/null
done

# Ensure CGI directory exists and has executable permissions
mkdir -p "$WEBROOT/cgi-bin"
chmod -R 0755 "$WEBROOT/cgi-bin"

if [ -f "$HTTPD_PID" ]; then
    kill "$(cat "$HTTPD_PID")" 2>/dev/null
    rm -f "$HTTPD_PID"
fi

# Start busybox httpd with CGI support
if busybox httpd --help > /dev/null 2>&1; then
    busybox httpd -p "$PORT" -h "$WEBROOT" -f &
    echo "$!" > "$HTTPD_PID"
    log "WebUI: busybox httpd PID=$! on port $PORT"
else
    log "WebUI Error: Busybox httpd missing. CGI requires Busybox."
fi
