FROM debian:bookworm-slim AS builder

#ARG RB_SHARING_KEY
#ARG PI_AWARE_UNIQUE_IDENTIFIER
ARG RB_SHARING_KEY=a1bacf5c88d5c02f5a7125f0d1d3cc43
ARG PI_AWARE_UNIQUE_IDENTIFIER=e9338725-70e1-488f-b773-87372425b414
ARG ADSBEXCHANGEUSERNAME=edeedeeed
ARG RECEIVERLATITUDE=-33.69053068423495
ARG RECEIVERLONGITUDE=151.1023288301973
ARG ALT=196m

USER root

WORKDIR /tmp

ADD ./setup/ ./

# Prepare APT repos
RUN dpkg -i ./flightaware-apt-repository_1.2_all.deb

RUN apt update && apt full-upgrade -y && apt install -y --no-install-recommends --no-install-suggests \
    build-essential cmake curl debhelper dh-python git gnuradio-dev gr-osmosdr libasound2-dev libjack-jackd2-dev \
    libpulse-dev libusb-1.0-0-dev lsb-release ncurses-dev pkg-config portaudio19-dev python3-dev python3-setuptools \
    python3-venv qt6-base-dev qt6-svg-dev qt6-wayland socat unzip uuid-runtime wget zlib1g-dev zlib1g
RUN apt list | grep gr-osmosdr
RUN apt list | grep gnuradio-osmosdr

# Install dump1090-fa
# After installing dump1090-fa, the service is feeding data on port 30005 and UI is on port 8080
RUN apt install -y dump1090-fa

# Install mlat-client
WORKDIR /tmp/mlat-client
RUN dpkg-buildpackage -b -uc \
    && dpkg -i ../mlat-client_*.deb

# Install rtl-sdr
WORKDIR /tmp/rtl-sdr-blog
# If you already have some other drivers installed, purge them from your system as below:
RUN apt purge ^librtlsdr -y \
    && rm -rvf /usr/lib/librtlsdr* /usr/include/rtl-sdr* /usr/local/lib/librtlsdr* \
    /usr/local/include/rtl-sdr* /usr/local/include/rtl_* /usr/local/bin/rtl_* \
# see ref: https://www.rtl-sdr.com/tag/install-guide/
RUN echo 'blacklist dvb_usb_rtl28xxu' | tee --append /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf
RUN mkdir -p /etc/udev/rules.d && cp rtl-sdr.rules /etc/udev/rules.d/
RUN cmake . -DINSTALL_UDEV_RULES=ON && make && make install
RUN ldconfig

WORKDIR /tmp

# Install rbfeeder
RUN echo n | bash ./inst_rbfeeder.sh

# Install piaware for Flight Aware
RUN apt install piaware -y

# Install ads-b exchange
 RUN bash ./feedclient/setup.sh ${ADSBEXCHANGEUSERNAME} ${RECEIVERLATITUDE} ${RECEIVERLONGITUDE} ${ALT}

# Install Planefinder
RUN dpkg -i ./pfclient.deb

WORKDIR /tmp

# Clean up apt cache
RUN apt autoremove -y && apt clean
RUN rm -rf /var/lib/apt/lists/*