#!/bin/bash

URL="http://localhost/"
LOGFILE="/var/log/mywebapp_health.log"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
STATUS_CODE=$(curl -s -o /dev/null -w '%{http_code}' "$URL")

if [ "$STATUS_CODE" -eq 200 ]; then
    echo "$TIMESTAMP OK $STATUS_CODE" >> "$LOGFILE"
else
    echo "$TIMESTAMP FAILED $STATUS_CODE" >> "$LOGFILE"
fi
