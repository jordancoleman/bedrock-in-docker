#!/bin/bash
# Test internet connectivity first
wget --quiet -U "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)" --timeout=30 http://www.minecraft.net/ -O /dev/null
if [ "$?" != 0 ]; then
    echo "Unable to connect to update website (internet connection may be down).  Skipping update ..."
else
    if [ "$BEDROCK_DOWNLOAD_URL" ]; then
      # Use specified version
      DownloadURL="$BEDROCK_DOWNLOAD_URL"
    else
      # Download server index.html to check latest version
      wget --no-verbose -U "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)" --timeout=30 -O /downloads/version.html https://minecraft.net/en-us/download/server/bedrock/
      DownloadURL=$(grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' /downloads/version.html)
    fi
    DownloadFile=$(echo "$DownloadURL" | sed 's#.*/##')

    # Download latest version of Minecraft Bedrock dedicated server if a new one is available
    if [ -f "/downloads/$DownloadFile" ]
    then
        echo "Minecraft Bedrock server is up to date..."
    else
        echo "New version $DownloadFile is available.  Updating Minecraft Bedrock server ..."
        rm -f /downloads/*
        wget --no-verbose -O "/downloads/$DownloadFile" "$DownloadURL"
        if [ -f "/bedrock/server.properties" ]
        then
          unzip -q -o "/downloads/$DownloadFile" -x "*server.properties*" "*permissions.json*" "*allowlist.json*" -d /bedrock/
        else
          unzip -q -o "/downloads/$DownloadFile" -d /bedrock/
        fi
        chmod +x /bedrock/bedrock_server
    fi
fi
