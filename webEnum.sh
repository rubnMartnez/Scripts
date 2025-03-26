#!/bin/bash

# Disclaimer: you have to have go installed and 
# assetfinder, Amass, httprobe and gowitness cloned before running this script

url=$1
run_amass=false

# Check for -a flag
if [[ "$2" == "-a" ]]; then
    run_amass=true
fi

# TODO add usage
# TODO add depency checks and clone them if not there

if [! -d "$url"];then
    mkdir $url
fi

if [! -d "$url/recon"];then
    mkdir $url/recon
fi

if [! -d "$url/recon/gowitness"];then
    mkdir $url/recon/gowitness
fi

echo "[+] Harvesting subdomains with assetfinder..."

assetfinder $url >> $url/recon/afAssets.txt
cat $url/recon/assets.txt | grep $url >> $url/recon/assetsOnScope.txt

# Run Amass only if -a flag is present
if [ "$run_amass" == true ]; then
    echo "[+] Harvesting subdomains with Amass..."
    amass enum -d "$url" > "$url/recon/amassAssets.txt"
    sort -u "$url/recon/amassAssets.txt" >> "$url/recon/assetsOnScope.txt"
fi

echo "[+] Checking if subdomains are alive with httprobe..."

cat $url/recon/assetsOnScope.txt | sort -u | httprobe >> alive.txt

echo "[+] Taking screenshot of the subdomains with gowitness..."

gowitness file -s $url/recon/alive.txt -d $url/recon/gowitness

echo "[+] Recon finished!"