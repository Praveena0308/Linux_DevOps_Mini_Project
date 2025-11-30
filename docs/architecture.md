# Architecture Overview

This mini project runs a simple Python web app behind Nginx, managed by systemd, with a cron-based health check.

## High-Level Flow

```mermaid
flowchart TD
    subgraph Client
        B[Browser<br/>http://server-ip:80]
    end

    subgraph Server[Linux Server]
        N[Nginx<br/>listen: 80]
        A[Python Web App<br/>localhost:8080<br/>managed by systemd]
        C[Cron Job<br/>*/5 minutes]
        S[Health Check Script<br/>/usr/local/bin/mywebapp_health_check.sh]
        L[(Health Log<br/>/var/log/mywebapp_health.log)]
        NA[(Nginx Logs<br/>/var/log/nginx/*.log)]
    end

    B --> N
    N --> A

    %% Monitoring path
    C --> S
    S --> N
    S --> L

    %% Logging
    N --> NA
