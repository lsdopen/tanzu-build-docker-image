FROM ubuntu:22.10

ARG USER=lsd
ARG UID=1000
ARG GROUP=lsd
ARG GID=1000
ARG WORKDIR="/home/lsd"

# Base stuff
RUN set -eux; \
    apt-get -yqq update
RUN set -eux; \
    apt-get -yqq install \
    iptables openssl pigz curl git bash nocache unzip dnsutils ntpdate

# Install Terraform
ARG TERRAFORM_VERSION="1.3.6"
RUN set -eux; \
    curl -Lo ./terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip; \
    unzip terraform.zip; \
    rm terraform.zip; \
    chmod +x ./terraform; \
    mv ./terraform /usr/local/bin/terraform 

# Install Tanzu CLI, Tanzu Kubectl and Carvel Tools
ARG KUBECTL_VERSION="kubectl-linux-v1.23.8+vmware.2"
ARG YTT_VERSION="ytt-linux-amd64-v0.41.1+vmware.1"
ARG KAPP_VERSION="kapp-linux-amd64-v0.49.0+vmware.1"
ARG KBLD_VERSION="kbld-linux-amd64-v0.34.0+vmware.1"
ARG IMGPKG_VERSION="imgpkg-linux-amd64-v0.29.0+vmware.1"
ARG VENDIR_VERSION="vendir-linux-amd64-v0.27.0+vmware.1"
ARG TKG_TOOL_VERSION="TKG-160"

RUN set -eux \
    && curl -Lo tanzu-cli-bundle-linux-amd64.tar.gz https://download3.vmware.com/software/${TKG_TOOL_VERSION}/tanzu-cli-bundle-linux-amd64.tar.gz \
    && curl -Lo kubectl-linux-v1.23.8+vmware.2.gz https://download3.vmware.com/software/${TKG_TOOL_VERSION}/${KUBECTL_VERSION}.gz \
    && tar -xzf tanzu-cli-bundle-linux-amd64.tar.gz \
    && gunzip ${KUBECTL_VERSION}.gz  \
    && install cli/core/v0.25.0/tanzu-core-linux_amd64 /usr/local/bin/tanzu \
    && install ${KUBECTL_VERSION} /usr/local/bin/kubectl
RUN set -eux \
    && gunzip cli/${YTT_VERSION}.gz \
    && gunzip cli/${KAPP_VERSION}.gz \
    && gunzip cli/${KBLD_VERSION}.gz \
    && gunzip cli/${IMGPKG_VERSION}.gz \
    && gunzip cli/${VENDIR_VERSION}.gz \
    && install cli/${YTT_VERSION} /usr/local/bin/ytt \
    && install cli/${KAPP_VERSION} /usr/local/bin/kapp \
    && install cli/${IMGPKG_VERSION} /usr/local/bin/imgpkg \
    && install cli/${VENDIR_VERSION} /usr/local/bin/vendir \
    && tanzu plugin sync \
    && rm -rf cli \
    && rm tanzu-cli-bundle-linux-amd64.tar.gz \
    && rm ${KUBECTL_VERSION}

# Install Kind
RUN set -eux; \
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64; \
    chmod +x ./kind; \
    mv ./kind /usr/local/bin/kind

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

# Install kubectx and kubens
ARG KUBEBINS_VERSION="v0.9.4"
RUN set -eux \
    && curl -Lo kubectx https://github.com/ahmetb/kubectx/releases/download/${KUBEBINS_VERSION}/kubectx \
    && curl -Lo kubens https://github.com/ahmetb/kubectx/releases/download/${KUBEBINS_VERSION}/kubens \
    && install kubectx /usr/local/bin/kubectx \
    && install kubens /usr/local/bin/kubens \
    && rm kubectx \
    && rm kubens

# Install docker
RUN set -eux; \
    curl -fsSL https://get.docker.com | sh

RUN set -eux; \
    groupadd -g ${GID} ${GROUP}; \
    useradd -d ${WORKDIR} -G ${GROUP} -u ${UID} -g docker ${USER}; \
    mkdir -p ${WORKDIR}; \
    chown ${USER}:${GROUP} -R ${WORKDIR}

WORKDIR ${WORKDIR}

USER ${USER}
