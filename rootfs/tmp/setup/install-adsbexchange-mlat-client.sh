#!/bin/bash
set -e

IPATH=/usr/local/share/adsbexchange
GIT="$IPATH/git"
MLAT_GIT="$IPATH/mlat-client-git"
LOGFILE="$IPATH/lastlog"

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

VENV=$IPATH/venv
if [[ -f /usr/local/share/adsbexchange/venv/bin/python3.7 ]] && command -v python3.9 &>/dev/null;
then
  rm -rf "$VENV"
fi

echo
echo "Installing mlat-client to virtual environment"
echo

MLAT_GIT="$IPATH/mlat-client-git"

mkdir -p $MLAT_GIT
cp -r /tmp/setup/adsbexchange-mlat/. $MLAT_GIT >> $LOGFILE

cd $MLAT_GIT

echo 34

rm "$VENV-backup" -rf
mv "$VENV" "$VENV-backup" -f &>/dev/null || true
if /usr/bin/python3 -m venv $VENV >> $LOGFILE \
  && echo 36 \
  && source $VENV/bin/activate >> $LOGFILE \
  && echo 38 \
  && python3 setup.py build >> $LOGFILE \
  && echo 40 \
  && python3 setup.py install >> $LOGFILE \
  && echo 46 \
  && revision > $IPATH/mlat_version || rm -f $IPATH/mlat_version \
  && echo 48 \
; then
  rm "$VENV-backup" -rf
else
  rm "$VENV" -rf
  mv "$VENV-backup" "$VENV" &>/dev/null || true
  echo "--------------------"
  echo "Installing mlat-client failed, if there was an old version it has been restored."
  echo "Will continue installation to try and get at least the feed client working."
  echo "Please repot this error to the adsbexchange forums or discord."
  echo "--------------------"
fi

echo 50

# copy adsbexchange-mlat service file
cp "$GIT"/scripts/adsbexchange-mlat.service /lib/systemd/system

echo 60
echo 70

