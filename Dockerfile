FROM debian:latest AS builder

USER root

RUN apt update && apt full-upgrade -y && apt install \
    build-essential debhelper python3-dev dh-python python3-setuptools -y