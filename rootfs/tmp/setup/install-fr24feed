#!/bin/bash
set -e

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [ ! -e "/etc/apt/keyrings" ]; then
	mkdir /etc/apt/keyrings
	chmod 0755 /etc/apt/keyrings
fi

# Import GPG key for the APT repository
# C969F07840C430F5
#gpg --dearmor /tmp/setup/flightradar24.pub > /etc/apt/trusted.gpg.d/flightradar24.gpg
wget -O- https://repo-feed.flightradar24.com/flightradar24.pub | gpg --dearmor > /etc/apt/keyrings/flightradar24.gpg

# Add APT repository to the config file, removing older entries if exist
#mv /etc/apt/sources.list /etc/apt/sources.list.bak
#grep -v flightradar24 /etc/apt/sources.list.bak > /etc/apt/sources.list || echo OK
echo "deb [signed-by=/etc/apt/keyrings/flightradar24.gpg] https://repo-feed.flightradar24.com flightradar24 raspberrypi-stable" > /etc/apt/sources.list.d/fr24feed.list

apt update -y
apt install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y fr24feed || echo OK