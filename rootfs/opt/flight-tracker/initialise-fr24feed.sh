#!/bin/bash
set -e

fr24feed --signup
chmod a+rw /etc/fr24feed.ini

echo ""
echo "Starting the fr24feed service, it may take a while if dump1090 needs to be installed..."