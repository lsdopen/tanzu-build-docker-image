FROM docker:20.10.22-dind

# ARG USER=lsd
# ARG UID=1000
# ARG GROUP=lsd
# ARG WORKDIR="/home/lsd"

# WORKDIR ${WORKDIR}

# RUN set -eux; \
#     adduser -h ${WORKDIR} -D -u ${UID} ${USER} ${GROUP}; \
#     echo "${USER}:200000:65536" > /etc/subuid; \
#     echo "${USER}:200000:65536" > /etc/subgid; \
#     chown ${USER}:${GROUP} -R ${WORKDIR}

# tanzu cli
RUN set -eux; \
    apk add --no-cache \
    btrfs-progs e2fsprogs e2fsprogs-extra ip6tables iptables openssl \
    shadow-uidmap xfsprogs xz pigz curl git bash perl-utils

# Install Terraform
ARG TERRAFORM_VERSION="1.3.6"
RUN set -eux; \
    curl -Lo ./terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip; \
    unzip terraform.zip; \
    rm terraform.zip; \
    chmod +x ./terraform; \
    mv ./terraform /usr/local/bin/terraform 

# Install Kind
RUN set -eux; \
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64; \
    chmod +x ./kind; \
    mv ./kind /usr/local/bin/kind

# Install Kubectl
RUN set -eux; \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; \
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"; \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
ARG BASE_URL="https://get.helm.sh"
ARG HELM_VERSION="3.10.2"
RUN set -eux; \
    case `uname -m` in \
    x86_64) ARCH=amd64; ;; \
    armv7l) ARCH=arm; ;; \
    aarch64) ARCH=arm64; ;; \
    ppc64le) ARCH=ppc64le; ;; \
    s390x) ARCH=s390x; ;; \
    *) echo "un-supported arch, exit ..."; exit 1; ;; \
    esac && \
    curl -L ${BASE_URL}/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz | tar -xz && \
    mv linux-${ARCH}/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf linux-${ARCH}

# Install Tanzu CLI and Carvel Tools
ARG YTT_VERSION="ytt-linux-amd64-v0.41.1+vmware.1"
ARG KAPP_VERSION="kapp-linux-amd64-v0.49.0+vmware.1"
ARG KBLD_VERSION="kbld-linux-amd64-v0.34.0+vmware.1"
ARG IMGPKG_VERSION="imgpkg-linux-amd64-v0.29.0+vmware.1"
ARG VENDIR_VERSION="vendir-linux-amd64-v0.27.0+vmware.1"
ARG TKG_TOOL_VERSION="TKG-160"
RUN set -eux; \
    curl -Lo tanzu-cli-bundle-linux-amd64.tar.gz https://download3.vmware.com/software/${TKG_TOOL_VERSION}/tanzu-cli-bundle-linux-amd64.tar.gz; \
    tar -xzf tanzu-cli-bundle-linux-amd64.tar.gz; \
    install cli/core/v0.25.0/tanzu-core-linux_amd64 /usr/local/bin/tanzu; \
    gunzip cli/${YTT_VERSION}.gz; \
    chmod ugo+x cli/${YTT_VERSION}; \
    mv cli/${YTT_VERSION} /usr/local/bin/ytt; \
    gunzip cli/${KAPP_VERSION}.gz; \
    chmod ugo+x cli/${KAPP_VERSION}; \
    mv cli/${KAPP_VERSION} /usr/local/bin/kapp; \
    gunzip cli/${KBLD_VERSION}.gz; \
    chmod ugo+x cli/${KBLD_VERSION}; \
    mv cli/${KBLD_VERSION} /usr/local/bin/kapp; \
    gunzip cli/${IMGPKG_VERSION}.gz; \
    chmod ugo+x cli/${IMGPKG_VERSION}; \
    mv cli/${IMGPKG_VERSION} /usr/local/bin/kapp; \
    gunzip cli/${VENDIR_VERSION}.gz; \
    chmod ugo+x cli/${VENDIR_VERSION}; \
    mv cli/${VENDIR_VERSION} /usr/local/bin/kapp; \
    cd cli; \
    tanzu plugin sync; \
    cd ..; \
    rm -rf cli; rm tanzu-cli-bundle-linux-amd64.tar.gz

# Install rootless kit
# RUN set -eux; \
#     \
#     apkArch="$(apk --print-arch)"; \
#     case "$apkArch" in \
#     'x86_64') \
#     url='https://download.docker.com/linux/static/stable/x86_64/docker-rootless-extras-20.10.22.tgz'; \
#     ;; \
#     'aarch64') \
#     url='https://download.docker.com/linux/static/stable/aarch64/docker-rootless-extras-20.10.22.tgz'; \
#     ;; \
#     *) echo >&2 "error: unsupported 'rootless.tgz' architecture ($apkArch)"; exit 1 ;; \
#     esac; \
#     \
#     wget -O 'rootless.tgz' "$url"; \
#     \
#     tar --extract \
#     --file rootless.tgz \
#     --strip-components 1 \
#     --directory /usr/local/bin/ \
#     'docker-rootless-extras/rootlesskit' \
#     'docker-rootless-extras/rootlesskit-docker-proxy' \
#     'docker-rootless-extras/vpnkit' \
#     ; \
#     rm rootless.tgz; \
#     \
#     rootlesskit --version; \
#     vpnkit --version

# RUN set -eux; \
#     mkdir -p /home/${USER}/.docker/run; \
#     chown -R ${USER}:${GROUP} /home/${USER}/.docker/run

# ENV XDG_RUNTIME_DIR=/home/${USER}/.docker/run

# # pre-create "/var/lib/docker" for our  user
# RUN set -eux; \
#     mkdir -p /home/${USER}/.local/share/docker; \
#     chown -R ${USER}:${GROUP} /home/${USER}/.local/share/docker

# USER ${USER}

ENTRYPOINT []

CMD ["dockerd-entrypoint.sh"]
