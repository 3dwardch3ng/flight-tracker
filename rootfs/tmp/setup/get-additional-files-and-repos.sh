#!/bin/bash
set -e

# Prepare files
curl -L -o flightaware-apt-repository_1.2_all.deb \
    https://www.flightaware.com/adsb/piaware/files/packages/pool/piaware/f/flightaware-apt-repository/flightaware-apt-repository_1.2_all.deb
curl -L -o pfclient.deb http://client.Planefinder.net/pfclient_5.1.440_arm64.deb
curl -L -o flightradar24.pub https://repo-feed.flightradar24.com/flightradar24.pub
# curl -L -o inst_rbfeeder.sh http://apt.rb24.com/inst_rbfeeder.sh

# Prepare repos
git clone --depth 1 --single-branch --branch master https://github.com/adsbexchange/mlat-client.git /tmp/setup/adsbexchange-mlat
git clone --depth 1 --single-branch --branch master https://github.com/adsbexchange/adsbexchange-stats.git
git clone --depth 1 --single-branch --branch master https://github.com/adsbexchange/feedclient.git
git clone --depth 1 --single-branch --branch master https://github.com/mutability/mlat-client.git
git clone --depth 1 --single-branch --branch master https://github.com/adsbexchange/readsb.git
git clone --depth 1 --single-branch --branch master https://github.com/rtlsdrblog/rtl-sdr-blog.git