FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && mkdir -p /etc/apt/keyrings && \
    curl -sL https://deb.nodesource.com/gpgkey/nodesource.gpg.key -o /etc/apt/keyrings/nodesource.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.asc] https://deb.nodesource.com/node_18.x jammy main" > /etc/apt/sources.list.d/nodesource.list

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    gettext devscripts debhelper equivs \
    python3-setuptools python3-pip python3-dev \
    libssl-dev dh-virtualenv libpq-dev libssl-dev \
    build-essential nodejs git openssh-client \
    libfreetype-dev zlib1g-dev libjpeg-dev libffi-dev
RUN corepack enable
