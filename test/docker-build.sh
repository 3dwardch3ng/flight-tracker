#!/usr/bin/bash
set -e

# Cleanup files
rm ./setup/*.*
rm -rf ./setup/mlat-client
rm -rf ./setup/rtl-sdr-blog

# Download .deb packages
curl -L -o ./setup/flightaware-apt-repository_1.2_all.deb https://www.flightaware.com/adsb/piaware/files/packages/pool/piaware/f/flightaware-apt-repository/flightaware-apt-repository_1.2_all.deb
curl -L -o ./setup/pfclient.deb http://client.Planefinder.net/pfclient_5.1.440_arm64.deb

# Download script files
curl -L -o ./setup/inst_rbfeeder.sh http://apt.rb24.com/inst_rbfeeder.sh

# Download repos
mkdir ./setup/mlat-client
git clone https://github.com/mutability/mlat-client.git ./setup/mlat-client
mkdir ./setup/rtl-sdr-blog
git clone https://github.com/rtlsdrblog/rtl-sdr-blog.git ./setup/rtl-sdr-blog

docker build -t edeedeeed/flight-tracker:v0.0.1 .