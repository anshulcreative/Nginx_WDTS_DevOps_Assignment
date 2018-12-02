 #!/bin/bash
printf "Memory\t\tDisk\t\tCPU\n"
end=$((SECONDS+3600))
while [ $SECONDS -lt $end ]; do
MEMORY=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }') > server_stats.txt
DISK=$(df -h | awk '$NF=="/"{printf "%s\t\t", $5}') >> server_stats.txt
CPU=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}') >>server_stats.txt
echo "$MEMORY$DISK$CPU"
sleep 5
mail -s "Server1 Stats"  testmail@test.com  < ./server_stats.txt
done