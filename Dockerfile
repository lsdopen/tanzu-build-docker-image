FROM ubuntu:22.10
ARG USER=lsd
ARG UID=1000
ARG GROUP=lsd
ARG GID=1000
ARG WORKDIR="/home/lsd"

RUN set -x \
    && apt-get update -y \
    && apt-get install docker.io -y nocache \
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists
RUN set -x \
    && groupadd -g "$GID" "$GROUP" \
    && useradd -u "$UID" -d "$WORKDIR" -g "$GID" -G docker,root "$USER"
USER "$USER"
WORKDIR "$WORKDIR"


