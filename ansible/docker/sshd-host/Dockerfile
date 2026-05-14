FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      openssh-server \
      curl \
      ca-certificates \
      gnupg \
      apt-transport-https && \
    mkdir -p /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

COPY start.sh /start.sh
CMD ["/start.sh"]
