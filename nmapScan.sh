#!/bin/bash

# Function to check if the input is a valid IP address
is_valid_ip() {
    local ip="$1"
    local stat=1
    # Check if the IP address matches the regular expression for a valid IPv4 address
    if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        local a b c d
        # Extract each octet of the IP address
        IFS=. read -r a b c d <<< "$ip"
        # Validate that each octet is between 0 and 255
        if (( a <= 255 && b <= 255 && c <= 255 && d <= 255 )); then
            stat=0
        fi
    fi
    return $stat
}

# Check if the IP is provided and valid
if [ -z "$1" ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    echo "Example: $0 10.10.10.55"
    exit 1
fi

ip="$1"

# Validate the IP address
if ! is_valid_ip "$ip"; then
    echo "Error: '$ip' is not a valid IP address."
    echo "Usage: $0 <IP_ADDRESS>"
    echo "Example: $0 10.10.10.55"
    exit 1
fi

# Step 1: Run nmap to get all open ports
echo "Running nmap to discover open ports on $ip..."
open_ports=$(nmap -T4 -p- "$ip" | grep 'open' | awk '{print $1}' | sed 's/\/.*//')

# Step 2: Check if open_ports is not empty
if [ -z "$open_ports" ]; then
    echo "No open ports found on $ip. Exiting."
    exit 1
fi

# Step 3: Format the open ports as a comma-separated list
formatted_ports=$(echo "$open_ports" | tr '\n' ',' | sed 's/,$//')

# Step 4: Run nmap with -A and the discovered open ports
echo "Running nmap -A on open ports..."
nmap -A -T4 -p "$formatted_ports" "$ip" > "${ip//./_}_nmapReport.txt"

# Notify the user that the report is saved
echo "Nmap report saved to ${ip//./_}_nmapReport.txt"
