#!/bin/bash

#####################################################################################
#                        ADS-B EXCHANGE SETUP SCRIPT                                #
#####################################################################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                                   #
# Copyright (c) 2020 ADSBx                                                          #
#                                                                                   #
# Permission is hereby granted, free of charge, to any person obtaining a copy      #
# of this software and associated documentation files (the "Software"), to deal     #
# in the Software without restriction, including without limitation the rights      #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell         #
# copies of the Software, and to permit persons to whom the Software is             #
# furnished to do so, subject to the following conditions:                          #
#                                                                                   #
# The above copyright notice and this permission notice shall be included in all    #
# copies or substantial portions of the Software.                                   #
#                                                                                   #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR        #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,          #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE       #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER            #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,     #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE     #
# SOFTWARE.                                                                         #
#                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

set -e
trap 'echo "[ERROR] Error in line $LINENO when executing: $BASH_COMMAND"' ERR
renice 10 $$ &>/dev/null

ADSBEXCHANGEUSERNAME=$1
RECEIVERLATITUDE=$2
RECEIVERLONGITUDE=$3
ALT=$4

IPATH=/usr/local/share/adsbexchange

function abort() {
    echo ------------
    echo "Setup canceled (probably using Esc button)!"
    echo "Please re-run this setup if this wasn't your intention."
    echo ------------
    exit 1
}

NOSPACENAME="$(echo -n -e "${ADSBEXCHANGEUSERNAME}" | tr -c '[a-zA-Z0-9]_\- ' '_')"

#((-90 <= RECEIVERLATITUDE <= 90))
LAT_OK=0
until [ $LAT_OK -eq 1 ]; do
    LAT_OK=`awk -v LAT="$RECEIVERLATITUDE" 'BEGIN {printf (LAT<90 && LAT>-90 ? "1" : "0")}'`
done

#((-180<= RECEIVERLONGITUDE <= 180))
LON_OK=0
until [ $LON_OK -eq 1 ]; do
    LON_OK=`awk -v LON="$RECEIVERLONGITUDE" 'BEGIN {printf (LON<180 && LON>-180 ? "1" : "0")}'`
done

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

