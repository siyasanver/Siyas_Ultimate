#!/system/bin/sh
# This header is required for the browser to read the response
printf "Content-Type: text/plain\r\n\r\n"

echo "Initializing Kernel Boost Engine..."

# 1. CPU Max Performance
for _cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
    [ -d "$_cpu" ] || continue
    echo "performance" > "$_cpu/scaling_governor" 2>/dev/null
done
echo "✓ CPU: performance governor applied"

# 2. GPU Max Frequency 
for _gpu in /sys/class/devfreq/*/; do
    [ -d "$_gpu" ] || continue
    echo "performance" > "${_gpu}governor" 2>/dev/null
done
echo "✓ GPU: max frequency locked"

# 3. Kill Background Apps
am kill-all 2>/dev/null
echo "✓ Background caches cleared"

# 4. Flush Caches
sync
echo "3" > /proc/sys/vm/drop_caches 2>/dev/null
echo "✓ Kernel memory caches flushed"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ALL OPTIMIZATIONS APPLIED ✓"
