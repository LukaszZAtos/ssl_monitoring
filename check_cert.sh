#!/bin/bash

# Function to check the SSL certificate expiration date from a file
check_ssl_certificate_from_file() {
    local file_path=$1
    local expiration_date=$(echo | openssl x509 -noout -dates -in "$file_path" 2>/dev/null | grep "notAfter" | cut -d "=" -f 2)

    check_ssl_certificate_common "$expiration_date" "$file_path"
}

# Function to check the SSL certificate expiration date from a URL
check_ssl_certificate_from_url() {
    local url=$1
    local expiration_date=$(echo | openssl s_client -connect "$url" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null | grep "notAfter" | cut -d "=" -f 2)

    check_ssl_certificate_common "$expiration_date" "$url"
}

# Common function to check the SSL certificate expiration date
check_ssl_certificate_common() {
    local expiration_date=$1
    local target=$2

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
        exit 1
    elif [ $days_remaining -lt 14 ]; then
        echo "WARNING: SSL certificate for $target will expire in $days_remaining days on $expiration_date"
        exit 1
    else
        echo "OK: SSL certificate for $target is still valid for $days_remaining days until $expiration_date"
    fi
}

while getopts ":f:u:" opt; do
    case $opt in
        f)
            if [ -f "$OPTARG" ]; then
                check_ssl_certificate_from_file "$OPTARG"
            else
                echo "File not found: $OPTARG"
                exit 1
            fi
            ;;
        u)
            check_ssl_certificate_from_url "$OPTARG"
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
