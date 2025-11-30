# Mini DevOps-Style Linux Project  
Python App + systemd + Nginx Reverse Proxy + Cron Health Check

## 1. Overview

This mini project is a hands-on exercise to practice basic DevOps skills on a Linux server:

- Run a simple **Python web app** on port `8080`
- Use **systemd** to keep the app running as a background service
- Put **Nginx** in front as a **reverse proxy** on port `80`
- Add a **cron-based health check** script that hits the app every 5 minutes and logs the result
- Use **logs** (Nginx, systemd, custom log file) to debug issues

It’s designed for learning, not production — but the patterns are the same as in real setups.

---

## 2. Architecture

High-level flow:

```text
Browser (http://server-ip:80)
        ↓
Nginx (reverse proxy on port 80)
        ↓
Python web app (listening on localhost:8080, managed by systemd)
        ↓
Cron job runs health-check script every 5 minutes
        ↓
Writes results to /var/log/mywebapp_health.log
text```

6. Useful Commands (Quick Reference)
Service & App
# systemd service
sudo systemctl status mywebapp.service
sudo systemctl restart mywebapp.service
sudo journalctl -u mywebapp.service -n 50

# Test app directly
curl http://localhost:8080

Nginx
sudo nginx -t
sudo systemctl status nginx
sudo systemctl reload nginx

sudo tail -n 50 /var/log/nginx/access.log
sudo tail -n 50 /var/log/nginx/error.log

Cron & Health Check
sudo crontab -e
sudo /usr/local/bin/mywebapp_health_check.sh
sudo tail -n 50 /var/log/mywebapp_health.log