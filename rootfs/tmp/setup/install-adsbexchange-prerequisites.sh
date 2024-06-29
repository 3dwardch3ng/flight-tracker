#!/bin/bash
set -e

IPATH=/usr/local/share/adsbexchange
GIT="$IPATH/git"

mkdir -p $GIT

LOGFILE="$IPATH/lastlog"
rm -f $LOGFILE
touch $LOGFILE

cp -r /tmp/setup/feedclient/. $GIT >> $LOGFILE

ls -la $GIT

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

if [ -f /boot/adsb-config.txt ]; then
  source /boot/adsb-config.txt
  source /boot/adsbx-env
else
  touch /etc/default/adsbexchange
  cat >> /etc/default/adsbexchange <<"EOF"
  # this is the source for 978 data, use port 30978 from dump978 --raw-port
  # if you're not receiving 978, don't worry about it, not doing any harm!
  UAT_INPUT="127.0.0.1:30978"

EOF
fi

rm -rf /usr/local/share/adsb-exchange &>/dev/null
cp $GIT/uninstall.sh $IPATH
cp $GIT/scripts/*.sh $IPATH

UNAME=adsbexchange
if ! id -u "${UNAME}" &>/dev/null
then
  # 2nd syntax is for fedora / centos
  adduser --system --home "$IPATH" --no-create-home --quiet "$UNAME" || adduser --system --home-dir "$IPATH" --no-create-home "$UNAME"
fi

echo 4
sleep 0.25

progress=4
echo "Checking and installing prerequesites ..."

# Check that the prerequisite packages needed to build and install mlat-client are installed.

# only install chrony if chrony and ntp aren't running
if ! systemctl status chrony &>/dev/null && ! systemctl status ntp &>/dev/null; then
  required_packages="chrony "
fi

echo
bash "$IPATH/git/create-uuid.sh"

VENV=$IPATH/venv
if [[ -f /usr/local/share/adsbexchange/venv/bin/python3.7 ]] && command -v python3.9 &>/dev/null;
then
  rm -rf "$VENV"
fi