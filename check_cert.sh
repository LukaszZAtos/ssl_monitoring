#!/bin/bash

# Function to check the SSL certificate expiration date
check_ssl_certificate() {
    local target=$1
    local expiration_date=$(echo | openssl s_client -connect "$target" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null | grep "notAfter" | cut -d "=" -f 2)

    # Convert expiration date to seconds since epoch
    local expiration_epoch=$(date -d "$expiration_date" +%s)
    local current_epoch=$(date +%s)

    # Calculate the number of seconds in 2 weeks (14 days)
    local two_weeks=$((14 * 24 * 3600))

    # Calculate the time remaining in seconds
    local time_remaining=$((expiration_epoch - current_epoch))

    # Calculate the number of days remaining
    local days_remaining=$((time_remaining / 86400))

    if [ $days_remaining -lt 0 ]; then
        echo "WARNING: SSL certificate for $target has expired on $expiration_date"
    elif [ $days_remaining -lt 14 ]; then
        echo "WARNING: SSL certificate for $target will expire in $days_remaining days on $expiration_date"
    else
        echo "OK: SSL certificate for $target is still valid for $days_remaining days until $expiration_date"
    fi
}

while getopts ":f:u:" opt; do
    case $opt in
        f)
            if [ -f "$OPTARG" ]; then
                check_ssl_certificate <(openssl x509 -noout -text -in "$OPTARG")
            else
                echo "File not found: $OPTARG"
                exit 1
            fi
            ;;
        u)
            check_ssl_certificate "$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done
