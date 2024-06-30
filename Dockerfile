FROM debian:bookworm-slim AS builder

SHELL ["/bin/bash", "-c"]

ENV SRV_MLAT_CLIENT=false
ENV SRV_FR24FEED=false
ENV SRV_INIT_FR24FEED=true
ENV SRV_RBFEEDER=false
ENV SRV_PIAWARE=false
ENV SRV_INIT_PIAWARE=true
ENV SRV_PARAM_PIAWARE_FEEDER_ID=null
ENV SRV_PARAM_PIAWARE_RECEIVER_HOST=null
ENV SRV_PARAM_PIAWARE_RECEIVER_PORT=null
ENV SRV_PARAM_PIAWARE_ALLOW_MLAT=null
ENV SRV_PARAM_PIAWARE_MLAT_RESULTS=null
ENV SRV_ADSBEXCHANGE=false
ENV SRV_INIT_ADSBEXCHANGE=true
ENV SRV_PARAM_ADSBEXCHANGE_ADSBEXCHANGEUSERNAME=null
ENV SRV_PARAM_ADSBEXCHANGE_RECEIVERLATITUDE=null
ENV SRV_PARAM_ADSBEXCHANGE_RECEIVERLONGITUDE=null
ENV SRV_ADSBEXCHANGE_STATS=false
ENV SRV_PFCLIENT=false
ENV SRV_PLANESPOTTERS=false
ENV SRV_INIT_PLANESPOTTERS=true

USER root

RUN adduser --system --group --uid 1000 --home /opt/flight-tracker --no-create-home --quiet --shell /bin/bash flight-tracker

RUN apt update && apt full-upgrade -y && apt install -y --no-install-recommends --no-install-suggests \
    bash-builtins bind9-host build-essential cmake curl debhelper dh-python dirmngr git gnupg2 gnuradio-dev gr-osmosdr \
    gzip jq libasound2-dev libjack-jackd2-dev libncurses-dev libpulse-dev libusb-1.0-0-dev libzstd1 libzstd-dev \
    lsb-release ncurses-bin ncurses-dev netcat-openbsd perl pkg-config portaudio19-dev python3-dev python3-setuptools python3-venv \
    qt6-base-dev qt6-svg-dev qt6-wayland socat unzip uuid-runtime wget zlib1g-dev zlib1g

RUN mkdir -p /tmp/setup/adsbexchange-mlat
COPY rootfs /
WORKDIR /tmp/setup

RUN source get-additional-files-and-repos

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
RUN source install-fr24feed
RUN systemctl disable fr24feed || echo OK

# Install rbfeeder
RUN source install_rbfeeder || echo OK
RUN systemctl disable rbfeeder || echo OK

# Install piaware for Flight Aware
RUN apt install piaware -y || echo OK
RUN systemctl disable piaware || echo OK

# Install ads-b exchange
RUN source install-adsbexchange-prerequisites
RUN source install-adsbexchange-mlat-client
RUN systemctl disable adsbexchange-mlat || echo OK
RUN source install-adsbexchange-feed
RUN systemctl disable adsbexchange-feed || echo OK

# Install adsbexchange-stats
RUN source install-adsbexchange-stats
RUN systemctl disable adsbexchange-stats || echo OK

# Install Planefinder
RUN dpkg -i ./pfclient.deb

# Install planespotters-feed and planespotters-mlat-client.service for Planespotters.net
RUN source install-planespotters
RUN systemctl disable planespotters-feed || echo OK \
    && systemctl disable planespotters-mlat-client.service || echo OK

WORKDIR /tmp

# Clean up apt cache
RUN apt autoremove -y && apt clean || echo OK
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 5432

ENTRYPOINT [ "/opt/flight-tracker/entrypoint.sh" ]

FROM builder AS runner

USER 1000