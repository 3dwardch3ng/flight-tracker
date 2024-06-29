#!/bin/bash
set -e

IPATH=/usr/local/share/adsbexchange
GIT="$IPATH/git"
LOGFILE="$IPATH/lastlog"

function revision() {
  git rev-parse HEAD 2>/dev/null || echo "$RANDOM-$RANDOM"
}

## we need to install stuff that require root, check for that
if [ "$(id -u)" != "0" ]; then
  echo -e "\033[33m"
  echo "This script must be ran using sudo or as root."
  echo -e "\033[37m"
  exit 1
fi

if [ -f /boot/adsb-config.txt ]; then
  echo --------
  echo "You are using the adsbx image, the feed setup script does not need to be installed."
  echo "You should already be feeding, check here: https://adsbexchange.com/myip/"
  echo "If the feed isn't working, check/correct the configuration using nano:"
  echo --------
  echo "sudo nano /boot/adsb-config.txt"
  echo --------
  echo "Hint for using nano: Ctrl-X to exit, Y(yes) and Enter to save."
  echo --------
  echo "Exiting."
  exit 1
fi

READSB_GIT="$IPATH/readsb-git"
READSB_BIN="$IPATH/feed-adsbx"

# SETUP FEEDER TO SEND DUMP1090 DATA TO ADS-B EXCHANGE
echo
echo "Compiling / installing the readsb based feed client"
echo

#compile readsb
echo 72

mkdir -p $READSB_GIT
cp -r /tmp/setup/readsb/. $READSB_GIT >> $LOGFILE

cd "$READSB_GIT"

echo 74

make clean
make -j2 AIRCRAFT_HASH_BITS=12 >> $LOGFILE
echo 80
rm -f "$READSB_BIN"
cp -r readsb "$READSB_BIN"
revision > $IPATH/readsb_version || rm -f $IPATH/readsb_version

echo
#end compile readsb

cp "$GIT"/scripts/adsbexchange-feed.service /lib/systemd/system

echo 82

# Remove old method of starting the feed scripts if present from rc.local
# Kill the old adsbexchange scripts in case they are still running from a previous install including spawned programs
for name in adsbexchange-netcat_maint.sh adsbexchange-socat_maint.sh adsbexchange-mlat_maint.sh; do
  if grep -qs -e "$name" /etc/rc.local; then
    sed -i -e "/$name/d" /etc/rc.local || true
  fi
  if PID="$(pgrep -f "$name" 2>/dev/null)" && PIDS="$PID $(pgrep -P $PID 2>/dev/null)"; then
    echo killing: $PIDS >> $LOGFILE 2>&1 || true
    kill -9 $PIDS >> $LOGFILE 2>&1 || true
  fi
done