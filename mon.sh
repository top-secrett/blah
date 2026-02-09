#!/bin/bash
# скрипт напсисан на скорую руку, можно оптимальнее, но работает :)
logfile="/var/log/monitoring"
n=0
while true; do
cpu_tot=$(ps -eo %cpu --no-headers | awk '{ sum += $1 } END { print sum }')
cpus=$(lscpu | grep '^CPU(s)\:' | awk '{print$2}')
cpu_load=$(echo "$cpu_tot / $cpus" | bc)

mem_av=$(free -m | grep Mem | awk '{print$7}')
mem_tot=$(free -m | grep Mem | awk '{print$2}')
mem_usage=$(( ($mem_av * 100) / $mem_tot ))
disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/\%//')
uptime=$(uptime | awk -F 'load average: ' '{print $2}')

if [[ $cpu_load -gt 80 ]]; then
        result="High CPU load: $cpu_load%, "
        (( n = n + 1 ))
fi
if [[ $mem_usage -gt 80 ]]; then
        result="$result High MEM load: $mem_usage%, "
        (( n = n + 1 ))
fi
if [[ $disk_usage -gt 90 ]]; then
        result="$result High Disk load: $disk_usage%, "
        (( n = n + 1 ))
fi
if [[ $n -ge 1 ]]; then
        (( n = n + 1 ))
        date_=$(date "+%Y-%m-%d %H:%M:%S")
        result="$result Averege Load: $uptime"
        echo "$date_ $result" >> $logfile
fi
n=0
sleep 60;
done
