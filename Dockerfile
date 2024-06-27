FROM debian:latest AS builder

USER root

RUN apt update && apt full-upgrade -y && apt install \
    build-essential debhelper python3-dev dh-python python3-setuptools -y

WORKDIR /installation

# Install dump1090-fa
# After installing dump1090-fa, the service is feeding data on port 30005 and UI is on port 8080
ADD ./flightaware-apt-repository_1.2_all.deb /installation/
RUN dpkg -i /installation/flightaware-apt-repository_1.2_all.deb \
    && apt update \
    && apt install -y dump1090-fa