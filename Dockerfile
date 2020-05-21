FROM python:3.8.3-alpine
ADD file:24352f4a071cb97b3f111253f3db695ba473c5e7985544889af3e34408ce32ff in /

COPY requirements.txt .

RUN apk add bash sudo shadow

RUN apk add --no-cache linux-headers \
    build-base \
    libffi-dev \
    openssl-dev \
    git \
    openssh \
    sshpass \
    && python3 -m pip install --no-cache-dir --upgrade pip \
    && python3 -m pip install --no-cache-dir -r requirements.txt \
    && rm -rf /var/cache/apk/* \
    && rm -rf /root/.cache

RUN /bin/sh -c rm -rf /var/lib/apt/lists/*
RUN /bin/sh -c set -xe          \
    && echo '#!/bin/sh' > /usr/sbin/policy-rc.d         \
    && echo 'exit 101' >> /usr/sbin/policy-rc.d         \
    && chmod +x /usr/sbin/policy-rc.d           \
    && dpkg-divert --local --rename --add /sbin/initctl         \
    && cp -a /usr/sbin/policy-rc.d /sbin/initctl        \
    && sed -i 's/^exit.*/exit 0/' /sbin/initctl                 \
    && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup                 \
    && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean       \
    && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean       \
    && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean          \
    && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages              \
    && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes           \
    && echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests
RUN /bin/sh -c mkdir -p /run/systemd \
    && echo 'docker' > /run/systemd/container
CMD ["/bin/bash"]
RUN /bin/bash

#ENTRYPOINT [ "ansible-lint" ]