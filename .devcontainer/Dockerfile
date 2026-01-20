FROM mcr.microsoft.com/devcontainers/go:2-1.25-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV LANG=C.UTF-8

ARG ARG_MYUSER=dev
ARG http_proxy
ARG https_proxy
ARG no_proxy
ARG APT_DIRECT_HOSTS="deb.debian.org security.debian.org dl.yarnpkg.com"
ARG APT_SECURITY_MIRROR=""
ENV MYUSER=${ARG_MYUSER}

# Optional: allow faster mirrors and Go module proxy during build
ARG APT_MIRROR=""
ARG GOPROXY_MIRROR="https://goproxy.cn,direct"
ENV GOPROXY=${GOPROXY_MIRROR}

# Proxy config for apt and optional APT mirror (applied before apt-get update)
RUN mkdir -p /etc/apt/apt.conf.d && \
        if [ -n "$http_proxy" ]; then \
            echo "Acquire::http::Proxy \"${http_proxy}\";" > /etc/apt/apt.conf.d/00proxy && \
            echo "Acquire::https::Proxy \"${https_proxy}\";" >> /etc/apt/apt.conf.d/00proxy; \
            for host in $APT_DIRECT_HOSTS; do \
                echo "Acquire::http::Proxy::${host} \"DIRECT\";" >> /etc/apt/apt.conf.d/00proxy; \
                echo "Acquire::https::Proxy::${host} \"DIRECT\";" >> /etc/apt/apt.conf.d/00proxy; \
            done; \
        fi && \
        if [ -n "$APT_MIRROR" ]; then \
            echo "Using APT mirror: $APT_MIRROR"; \
            if [ -f /etc/apt/sources.list ]; then \
                sed -i "s|http://deb.debian.org/debian|${APT_MIRROR}|g" /etc/apt/sources.list; \
            fi; \
            if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
                sed -i -E "s|^(URIs: )https?://deb.debian.org/debian|\\1${APT_MIRROR}|g" /etc/apt/sources.list.d/debian.sources; \
            fi; \
        fi && \
        if [ -n "$APT_SECURITY_MIRROR" ]; then \
            echo "Using APT security mirror: $APT_SECURITY_MIRROR"; \
            if [ -f /etc/apt/sources.list ]; then \
                sed -i "s|http://deb.debian.org/debian-security|${APT_SECURITY_MIRROR}|g" /etc/apt/sources.list; \
            fi; \
            if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
                sed -i -E "s|^(URIs: )http://deb.debian.org/debian-security|\\1${APT_SECURITY_MIRROR}|g" /etc/apt/sources.list.d/debian.sources; \
            fi; \
        fi

RUN apt-get update && apt-get install -y sudo dnsutils curl git

# User configuration: rename 'vscode' to match $MYUSER if different
RUN if id -u vscode > /dev/null 2>&1; then \
        if [ "$MYUSER" != "vscode" ]; then \
            usermod -l $MYUSER -d /home/$MYUSER -m vscode && \
            groupmod -n $MYUSER vscode; \
        fi; \
    else \
        useradd -s /bin/bash -m $MYUSER; \
    fi \
    && echo "$MYUSER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$MYUSER \
    && chmod 0440 /etc/sudoers.d/$MYUSER \
    && if ! getent group docker > /dev/null 2>&1; then \
        groupadd docker; \
    fi \
    && usermod -aG docker,sudo $MYUSER
