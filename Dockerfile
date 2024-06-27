FROM debian:latest AS builder

ARG RB_SHARING_KEY=a1bacf5c88d5c02f5a7125f0d1d3cc43

USER root

RUN apt update && apt full-upgrade -y && apt install \
    build-essential debhelper python3-dev dh-python python3-setuptools libusb-1.0-0-dev \
    cmake pkg-config build-essential lsb-release -y

WORKDIR /installation

# Install dump1090-fa
# After installing dump1090-fa, the service is feeding data on port 30005 and UI is on port 8080
ADD ./flightaware-apt-repository_1.2_all.deb ./
RUN dpkg -i /installation/flightaware-apt-repository_1.2_all.deb \
    && apt update \
    && apt install -y dump1090-fa

# Install mlat-client
ADD mlat-client/ mlat-client/
WORKDIR /installation/mlat-client
RUN dpkg-buildpackage -b -uc \
    && dpkg -i ../mlat-client_*.deb

WORKDIR /installation

# Install rtl-sdr
# If you already have some other drivers installed, purge them from your system as below:
RUN apt purge ^librtlsdr -y \
    && rm -rvf /usr/lib/librtlsdr* /usr/include/rtl-sdr* /usr/local/lib/librtlsdr* \
    /usr/local/include/rtl-sdr* /usr/local/include/rtl_* /usr/local/bin/rtl_* \
# see ref: https://www.rtl-sdr.com/tag/install-guide/
RUN pwd
ADD rtl-sdr-blog/ rtl-sdr-blog/
RUN echo 'blacklist dvb_usb_rtl28xxu' | tee --append /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf
WORKDIR /installation/rtl-sdr-blog
RUN mkdir -p /etc/udev/rules.d && cp rtl-sdr.rules /etc/udev/rules.d/
RUN cmake . -DINSTALL_UDEV_RULES=ON && make && make install
RUN ldconfig

WORKDIR /installation

# Install rbfeeder
ADD ./inst_rbfeeder.sh ./
RUN bash ./inst_rbfeeder.sh -y

# Clean up apt cache
RUN rm -rf /var/lib/apt/lists/*