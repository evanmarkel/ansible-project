# Ansible-Project (Docker + Ansible + Alloy + Prometheus + Grafana)

## Project Overview
This environment builds a local observability stack with:
• Two SSH‑enabled hosts (host‑a, host‑b)
• Prometheus for metrics collection
• Grafana for visualization
• Ansible for provisioning and Alloy deployment
All components run on a shared Docker network called observability.

## Architecture Diagram

```mermaid
flowchart TD

    G[Grafana<br>Port 3000]
    P[Prometheus<br>Port 9090]

    HA[host-a<br>SSH 2222<br>Alloy 12345]
    HB[host-b<br>SSH 2223<br>Alloy 12346]

    G --> P
    P --> HA
    P --> HB
```

## Directory Overview

<img width="188" height="390" alt="Screenshot 2026-05-15 at 09 13 51" src="https://github.com/user-attachments/assets/a2de9554-fcb3-49d9-8891-14bd20514b99" />


## Runbook

### Startup**

```bash
docker compose up --build -d
```
### Validate SSH
```bash
ssh -i ssh/id_rsa root@127.0.0.1 -p 2222
ssh -i ssh/id_rsa root@127.0.0.1 -p 2223
```
### Validate SSH and Provision Hosts 
Run from root directory of project
```bash
./run.sh
```
## Service Flow
```mermaid
sequenceDiagram
    autonumber

    participant Dev as Developer
    participant Ansible as Ansible Controller
    participant HA as host-a (Alloy)
    participant HB as host-b (Alloy)
    participant P as Prometheus
    participant G as Grafana

    Dev->>Ansible: Run ./run.sh
    Ansible->>HA: SSH → Install Alloy → Deploy config
    Ansible->>HB: SSH → Install Alloy → Deploy config
    HA->>P: Expose metrics on 12345
    HB->>P: Expose metrics on 12346
    P->>G: Provide metrics for dashboards
```
### SSH
SSHD Dockerfile installs sshd on provisioned Ubuntu machines ```host-a, host-b```

### Ansible
Playbook pulls Alloy and deploys to hosts ```/ec/alloy/config.alloy```

### Alloy
Federated deployment that sends metrics to Prometheus writing to volume

## Prometheus
Ingests Alloy metrics and local scrape config. UI targets found at 
```
http://localhost:9090/targets
```
Host alert rules
* High CPU Usage
  * targets down >2m
* High Memory Usage
  * > 90% of virtual memory for 5m
* Low Disk Space
  * < 10% disk space
* Slow Scrapes
  * p90 scrape > 5s for 10m

## Grafana
```
http://localhost:3000
```
Metrics for host-a and host-b with prometheus alert rules. Templated Label to switch between hosts and services

### SRE Observability Dashboard
<img width="1608" height="836" alt="Screenshot 2026-05-15 at 09 26 54" src="https://github.com/user-attachments/assets/39d3fc92-cf64-4fa3-9774-747496b442b2" />

### Teardown
