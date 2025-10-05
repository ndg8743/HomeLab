#!/bin/bash

# Monitor script to check site health and alert on issues

SITE="https://gopee.dev"
EMAIL="ndg8743@gmail.com"
LOG_FILE="/var/log/site-monitor.log"

check_site() {
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$SITE")

    if [ "$response" != "200" ]; then
        echo "$(date): Site is DOWN! HTTP Status: $response" >> "$LOG_FILE"
        # Send email alert (requires mailutils)
        # echo "Site $SITE is down! HTTP Status: $response" | mail -s "ALERT: Site Down" "$EMAIL"
        return 1
    else
        echo "$(date): Site is UP. HTTP Status: $response" >> "$LOG_FILE"
        return 0
    fi
}

check_ssl() {
    expiry=$(echo | openssl s_client -servername gopee.dev -connect gopee.dev:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
    expiry_epoch=$(date -d "$expiry" +%s)
    current_epoch=$(date +%s)
    days_left=$(( ($expiry_epoch - $current_epoch) / 86400 ))

    echo "$(date): SSL certificate expires in $days_left days" >> "$LOG_FILE"

    if [ "$days_left" -lt 30 ]; then
        echo "$(date): WARNING: SSL certificate expires in $days_left days!" >> "$LOG_FILE"
        # Send email alert
        # echo "SSL certificate for $SITE expires in $days_left days!" | mail -s "WARNING: SSL Expiring Soon" "$EMAIL"
    fi
}

check_site
check_ssl
