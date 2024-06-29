#!/bin/bash
set -e
trap 'echo "[ERROR] Error in line $LINENO when executing: $BASH_COMMAND"' ERR
renice 10 $$ &>/dev/null

ADSBEXCHANGEUSERNAME=$1
RECEIVERLATITUDE=$2
RECEIVERLONGITUDE=$3

IPATH=/usr/local/share/adsbexchange

## we need to install stuff that require root, check for that
if [ "$(id -u)" != "0" ]; then
  echo -e "\033[33m"
  echo "This script must be ran using sudo or as root."
  echo -e "\033[37m"
  exit 1
fi

## REFUSE INSTALLATION ON ADSBX IMAGE

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

NOSPACENAME="$(echo -n -e "${ADSBEXCHANGEUSERNAME}" | tr -c '[a-zA-Z0-9]_\- ' '_')"
if [[ "$NOSPACENAME" != 0 ]]; then
  MSG="For MLAT the precise location of your antenna is required.\
  \n\nA small error of 15m/45ft will cause issues with MLAT!\
  \n\nTo get your location, use any online map service or this website: https://www.mapcoordinates.net/en"
else
  MSG="MLAT DISABLED!.\
  \n\n For some local functions the approximate receiver location is still useful, it won't be sent to the server."
fi
echo MSG

#((-90 <= RECEIVERLATITUDE <= 90))
LAT_OK=`awk -v LAT="$RECEIVERLATITUDE" 'BEGIN {printf (LAT<90 && LAT>-90 ? "1" : "0")}'`
if [[ ! $LAT_OK -eq 1 ]]; then
  ERR_MSG="The receivers precise latitude in degrees with 5 decimal places is required\n(Example: 32.36291)"
  echo -e ERR_MSG
  exit 1
fi

#((-180<= RECEIVERLONGITUDE <= 180))
LON_OK=`awk -v LON="$RECEIVERLONGITUDE" 'BEGIN {printf (LON<180 && LON>-180 ? "1" : "0")}'`
if [[ ! $LON_OK -eq 1 ]]; then
  ERR_MSG="The receivers longitude in degrees with 5 decimal places is required\n(Example: -64.71492)"
  echo -e ERR_MSG
  exit 1
fi

ALT=0
if [[ "$NOSPACENAME" != 0 ]] && [[ ! $ALT =~ ^(-?[0-9]*)ft$ ]] && [[ ! $ALT =~ ^(-?[0-9]*)m$ ]]; then
  ERR_MSG="The value is required when MLAT is enabled!\
  \nThe receivers altitude above sea level should including the unit, no spaces:\
  \nin feet like this:                   255ft\
  \nor in meters like this:              78m"
  echo -e ERR_MSG
  exit 1
fi

if [[ $ALT =~ ^-(.*)ft$ ]]; then
  NUM=${BASH_REMATCH[1]}
  NEW_ALT=`echo "$NUM" "3.28" | awk '{printf "-%0.2f", $1 / $2 }'`
  ALT=$NEW_ALT
fi
if [[ $ALT =~ ^-(.*)m$ ]]; then
  NEW_ALT="-${BASH_REMATCH[1]}"
  ALT=$NEW_ALT
fi

RECEIVERALTITUDE="$ALT"

INPUT="127.0.0.1:30005"
INPUT_TYPE="dump1090"

if [[ $(hostname) == "radarcape" ]] || pgrep rcd &>/dev/null; then
  INPUT="127.0.0.1:10003"
  INPUT_TYPE="radarcape_gps"
fi

tee /etc/default/adsbexchange >/dev/null <<EOF
INPUT="$INPUT"
REDUCE_INTERVAL="0.5"

# feed name for checking MLAT sync (adsbx.org/sync)
# also displayed on the MLAT map: map.adsbexchange.com/mlat-map
USER="$NOSPACENAME"

LATITUDE="$RECEIVERLATITUDE"
LONGITUDE="$RECEIVERLONGITUDE"

ALTITUDE="$RECEIVERALTITUDE"

# this is the source for 978 data, use port 30978 from dump978 --raw-port
# if you're not receiving 978, don't worry about it, not doing any harm!
UAT_INPUT="127.0.0.1:30978"

RESULTS="--results beast,connect,127.0.0.1:30104"
RESULTS2="--results basestation,listen,31003"
RESULTS3="--results beast,listen,30157"
RESULTS4="--results beast,connect,127.0.0.1:30154"
# add --privacy between the quotes below to disable having the feed name shown on the mlat map
# (position is never shown accurately no matter the settings)
PRIVACY=""
INPUT_TYPE="$INPUT_TYPE"

MLATSERVER="feed.adsbexchange.com:31090"
TARGET="--net-connector feed1.adsbexchange.com,30004,beast_reduce_out,feed2.adsbexchange.com,64004"
NET_OPTIONS="--net-heartbeat 60 --net-ro-size 1280 --net-ro-interval 0.2 --net-ro-port 0 --net-sbs-port 0 --net-bi-port 30154 --net-bo-port 0 --net-ri-port 0 --write-json-every 1"
JSON_OPTIONS="--max-range 450 --json-location-accuracy 2 --range-outline-hours 24"
EOF



