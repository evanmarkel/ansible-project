FROM ubuntu:22.04

RUN apt-get update && apt-get install -y ca-certificates curl && update-ca-certificates

# Copy Alloy binary from Ansible output
COPY alloy /usr/local/bin/alloy
RUN chmod +x /usr/local/bin/alloy

# Copy Alloy config from Ansible output
COPY config.yaml /etc/alloy/config.yaml

ENTRYPOINT ["/usr/local/bin/alloy"]
CMD ["run", "--config.file=/etc/alloy/config.yaml"]
