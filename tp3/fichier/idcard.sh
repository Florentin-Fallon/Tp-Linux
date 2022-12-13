#!/bin/bash

echo "Machine name : $(hostnamectl hostname) "
echo "Os $(cat /etc/redhat-release) and kernel version is $(uname -v)"
echo "IP : $(hostname -I)"
echo "RAM : $(grep MemFree /proc/meminfo | tr -s ' ' | cut -d ' ' -f2) KB memory available on $(grep MemTotal /proc/meminfo | tr -s ' ' | cut -d ' ' -f2) KB total memory"
echo "Disk : $(df | grep /dev/vda1 | tr -s ' ' | cut -d ' ' -f4) KB space left"
echo "Top 5 processes by RAM usage : "
for i in $(ps aux | sort -rnk 4 | tr -s ' ' | head -5 | cut -d ' ' -f11)
do
    echo "-${i}"
done

echo "Listening ports :"
for i in $()
do
    echo "-${i}"
done
curl https://cataas.com/cat -o cat.png &> /dev/null
echo " Here is your random cat : cat.png "
