FROM debian:bookworm-slim AS builder

USER root

RUN adduser --system --group --uid 1000 --user-group --home /opt/flight-tracker --no-create-home --quiet --shell /bin/bash flight-tracker

RUN apt update && apt full-upgrade -y && apt install -y --no-install-recommends --no-install-suggests \
    bash-builtins bind9-host build-essential cmake curl debhelper dh-python dirmngr git gnupg2 gnuradio-dev gr-osmosdr \
    gzip jq libasound2-dev libjack-jackd2-dev libpulse-dev libusb-1.0-0-dev libzstd1 libzstd-dev lsb-release \
    ncurses-dev netcat-openbsd perl pkg-config portaudio19-dev python3-dev python3-setuptools python3-venv qt6-base-dev \
    qt6-svg-dev qt6-wayland socat unzip uuid-runtime wget zlib1g-dev zlib1g

RUN mkdir -p /tmp/setup/adsbexchange-mlat
COPY rootfs /
WORKDIR /tmp/setup

RUN bash ./get-additional-files-and-repos.sh

# Install dump1090-fa
# After installing dump1090-fa, the service is feeding data on port 30005 and UI is on port 8080
RUN dpkg -i flightaware-apt-repository_1.2_all.deb
RUN apt update
RUN apt install -y dump1090-fa
RUN systemctl disable dump1090-fa || echo OK

# Install mlat-client
WORKDIR /tmp/setup/mlat-client
RUN dpkg-buildpackage -b -uc \
    && dpkg -i ../mlat-client_*.deb
RUN systemctl disable mlat-client || echo OK

# Install rtl-sdr
WORKDIR /tmp/setup/rtl-sdr-blog
# If you already have some other drivers installed, purge them from your system as below:
RUN apt purge ^librtlsdr -y \
    && rm -rvf /usr/lib/librtlsdr* /usr/include/rtl-sdr* /usr/local/lib/librtlsdr* \
    /usr/local/include/rtl-sdr* /usr/local/include/rtl_* /usr/local/bin/rtl_*
# see ref: https://www.rtl-sdr.com/tag/install-guide/
RUN echo 'blacklist dvb_usb_rtl28xxu' | tee --append /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf
RUN mkdir -p /etc/udev/rules.d && cp rtl-sdr.rules /etc/udev/rules.d/
RUN cmake . -DINSTALL_UDEV_RULES=ON && make && make install
RUN ldconfig

WORKDIR /tmp/setup

# Install fr24feed for Flightradar24
RUN bash install-fr24feed.sh
RUN systemctl disable fr24feed || echo OK

# Install rbfeeder
RUN bash ./install_rbfeeder.sh || echo OK
RUN systemctl disable rbfeeder || echo OK

# Install piaware for Flight Aware
RUN apt install piaware -y || echo OK
RUN systemctl disable piaware || echo OK

# Install ads-b exchange
RUN bash ./install-adsbexchange-prerequisites.sh
RUN bash ./install-adsbexchange-mlat-client.sh
RUN systemctl disable adsbexchange-mlat || echo OK
RUN bash ./install-adsbexchange-feed.sh
RUN systemctl disable adsbexchange-feed || echo OK

# Install adsbexchange-stats
RUN bash ./install-adsbexchange-stats.sh
RUN systemctl disable adsbexchange-stats || echo OK

# Install Planefinder
RUN dpkg -i ./pfclient.deb

WORKDIR /tmp

# Clean up apt cache
RUN apt autoremove -y && apt clean || echo OK
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 5432

ENTRYPOINT [ "/opt/flight-tracker/entrypoint.sh" ]

USER 1000