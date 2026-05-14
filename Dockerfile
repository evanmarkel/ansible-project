FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Python + APT bindings for Ansible
RUN apt-get update && \
    apt-get install -y python3 \
    python3-apt \
    unzip

# Install SSH server
RUN apt-get update && \
    apt-get install -y openssh-server && \
    mkdir -p /run/sshd && \
    ssh-keygen -A

# Create SSH directory for root
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Install authorized key for root
COPY ansible_key.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# Allow root login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Disable password authentication (key-only)
RUN sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
