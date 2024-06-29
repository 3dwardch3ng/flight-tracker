#!/bin/bash
set -e

IPATH=/usr/local/share/adsbexchange-stats

mkdir -p $IPATH

if ! id -u adsbexchange &>/dev/null
then
  adduser --system --home $IPATH --no-create-home --quiet adsbexchange >/dev/null || adduser --system --home-dir $IPATH --no-create-home adsbexchange
fi

# commands used
COMMANDS="curl jq gzip host perl"

for CMD in $COMMANDS; do
    if ! command -v $CMD &>/dev/null; then
    install=1
    fi
done

mkdir -p /usr/local/bin
cp /tmp/setup/adsbexchange-stats/adsbexchange-showurl /usr/local/bin/adsbexchange-showurl

hash -r

cp /tmp/setup/adsbexchange-stats/json-status $IPATH
cp /tmp/setup/adsbexchange-stats/create-uuid.sh $IPATH
chmod +x $IPATH/json-status
chmod +x $IPATH/create-uuid.sh
cp /tmp/setup/adsbexchange-stats/uninstall.sh $IPATH

if [ -f /boot/adsb-config.txt ] && ! [ -d /run/adsbexchange-feed ] && ! [ -f /etc/default/adsbexchange-stats ]
then
    echo "USE_OLD_PATH=1" > /etc/default/adsbexchange-stats
fi

cp /tmp/setup/adsbexchange-stats/adsbexchange-stats.service /etc/systemd/system/adsbexchange-stats.service

# add adsbexchange user to video group for vcgencmd get_throttled if the system has that command and it works:
if vcgencmd get_throttled &>/dev/null; then
    adduser adsbexchange video
fi

# exit success for chroot
if ischroot; then
    exit 0
fi

bash $IPATH/create-uuid.sh

# output uuid
echo "#####################################"
UUID_FILE="/boot/adsbx-uuid"
if ! [[ -f "$UUID_FILE" ]]; then
    UUID_FILE="/usr/local/share/adsbexchange/adsbx-uuid"
fi
cat $UUID_FILE
echo "#####################################"
sed -e 's$^$https://www.adsbexchange.com/api/feeders/?feed=$' $UUID_FILE
echo "#####################################"