#!/bin/bash

echo "=== FIX: SOURCES.LIST ==="
sudo bash -c 'cat > /etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu jammy main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu jammy-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse
EOF'

echo "=== FIX: TIMEZONE ==="
sudo timedatectl set-timezone America/Sao_Paulo

echo "=== FIX: NTP CONFIG ==="
sudo bash -c 'cat > /etc/systemd/timesyncd.conf <<EOF
[Time]
NTP=pool.ntp.org
EOF'

echo "=== RESTART NTP ==="
sudo systemctl restart systemd-timesyncd

echo "=== FORCE NTP RESYNC ==="
sudo timedatectl set-ntp false
sleep 2
sudo timedatectl set-ntp true

echo "=== WAIT SYNC ==="
sleep 10

echo "=== CHECK CLOCK ==="
timedatectl

echo "=== FORCE SYNC IF NEEDED ==="
if ! timedatectl | grep -q "System clock synchronized: yes"; then
    echo "Forçando sync manual..."
    sudo apt update
    sudo apt install -y ntpdate
    sudo systemctl stop systemd-timesyncd
    sudo ntpdate pool.ntp.org
    sudo systemctl start systemd-timesyncd
fi

echo "=== FINAL CLOCK STATUS ==="
timedatectl

echo "=== UPDATE SYSTEM ==="
sudo apt update && sudo apt upgrade -y

echo "=== START UPGRADE TO 24.04 ==="
sudo do-release-upgrade -d

echo "=== DONE ==="
