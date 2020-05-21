FROM centos:7

LABEL org.opencontainers.image.title="jfbourque/ansible-lint" \
    org.opencontainers.image.description="Ansible-lint" \
    org.opencontainers.image.source="https://github.com/jfbourque/ansible-lint" \
    org.opencontainers.image.licenses="MIT"    

COPY requirements.txt .

RUN yum install -y epel-release \
    && yum upgrade -y \
    && yum install -y \
    openssh \
    sshpass \
    git \
    shadow-utils \
    python-pip \
    && python -m pip install --no-cache-dir --upgrade pip \
    && python -m pip install --no-cache-dir -r requirements.txt \
    && yum clean all \
    && rm -rf /var/cache/yum

VOLUME ["/mnt"]

WORKDIR /mnt

ENTRYPOINT [ "ansible-lint" ]