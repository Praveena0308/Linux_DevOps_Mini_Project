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
3. Components
3.1 Python Web App

Simple HTTP server (e.g. python -m http.server 8080)

Listens on: localhost:8080

Lives in (example):

/home/username/mywebapp/

3.2 systemd Service

Manages the Python app as a service

Starts on boot, restarts on failure

Example unit file path:

/etc/systemd/system/mywebapp.service

3.3 Nginx Reverse Proxy

Listens on port 80 (public)

Forwards incoming HTTP traffic to localhost:8080

Config file used in this project:

/etc/nginx/sites-available/default

3.4 Cron Health Check

Shell script calls curl http://localhost/

Logs status (OK/FAILED + HTTP code) to a custom log file

Script path (example):

/usr/local/bin/mywebapp_health_check.sh


Log file path:

/var/log/mywebapp_health.log


Scheduled via cron to run every 5 minutes.

4. Server File Locations (Cheat Sheet)

This project intentionally uses “typical” Linux locations:

Purpose	Example Path
Project code / HTML files	/home/username/mywebapp/
systemd service unit	/etc/systemd/system/mywebapp.service
Nginx main config	/etc/nginx/nginx.conf
Nginx site config (reverse proxy)	/etc/nginx/sites-available/default
Health-check script	/usr/local/bin/mywebapp_health_check.sh
Health-check log	/var/log/mywebapp_health.log
Nginx access log	/var/log/nginx/access.log
Nginx error log	/var/log/nginx/error.log

Rules of thumb:

/home/... → project files, source code

/etc/... → configuration (Nginx, systemd, etc.)

/usr/local/bin/... → custom executable scripts you created

/var/log/... → log files

5. Setup Steps (High-Level)


5.1 Python App

Create a project directory:

mkdir -p /home/praveena/mywebapp


Put some content there, e.g. an index.html file to serve.

Test locally (example):

cd /home/praveena/mywebapp
python3 -m http.server 8080


From the server:

curl http://localhost:8080


You should see your HTML.

5.2 systemd Service

Create a unit file at:

/etc/systemd/system/mywebapp.service


The service should:

Run as a non-root user (e.g. praveena)

Use your project directory as WorkingDirectory

Call Python to start the HTTP server on port 8080

Restart on failure

After creating the file:

sudo systemctl daemon-reload
sudo systemctl enable mywebapp.service
sudo systemctl start mywebapp.service
sudo systemctl status mywebapp.service


Test again:

curl http://localhost:8080

5.3 Nginx Reverse Proxy (80 → 8080)

Install Nginx (Debian/Ubuntu):

sudo apt update
sudo apt install nginx


Backup default config:

sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak


Edit /etc/nginx/sites-available/default and in the server { ... } block:

Keep listen 80 default_server;

In location / { ... }, forward to the app on localhost:8080.

Test Nginx config and reload:

sudo nginx -t
sudo systemctl reload nginx


Test:

From server: curl http://localhost/

From laptop: http://<server-ip>/

Both should show the app behind Nginx.

5.4 Cron Health Check

Create script:

sudo nano /usr/local/bin/mywebapp_health_check.sh


Script responsibilities (pseudo):

Set URL=http://localhost/

Set LOG_FILE=/var/log/mywebapp_health.log

Get current timestamp (date '+%Y-%m-%d %H:%M:%S')

Call curl (silent, only HTTP code)

If status code is 200 → log “TIMESTAMP OK STATUS”

Else → log “TIMESTAMP FAILED STATUS”

Make it executable:

sudo chmod +x /usr/local/bin/mywebapp_health_check.sh
sudo touch /var/log/mywebapp_health.log


Test manually:

sudo /usr/local/bin/mywebapp_health_check.sh
sudo tail /var/log/mywebapp_health.log


Add cron job (as root):

sudo crontab -e


Add:

*/5 * * * * /usr/local/bin/mywebapp_health_check.sh


After 5–10 minutes, check:

sudo tail /var/log/mywebapp_health.log

6. Useful Commands (Quick Reference)
Service & App
# systemd service
sudo systemctl status mywebapp.service
sudo systemctl restart mywebapp.service
sudo journalctl -u mywebapp.service -n 50

# Test app directly
curl http://localhost:8080


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
