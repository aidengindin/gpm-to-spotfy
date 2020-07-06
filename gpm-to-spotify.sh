#! /bin/bash

# check for dependencies
if ! ( which pip3 > /dev/null ) ; then
    echo 'Error: pip not installed'
    exit 1
fi

if ! ( which node > /dev/null ) ; then
    echo 'Error: node not installed'
    exit 1
fi

if ! ( which jq > /dev/null ); then
    echo 'Error: jq not installed'
    exit 1
fi

if ! ( which urlencode > /dev/null ); then
    echo 'Error: gridsite-clients not installed'
    exit 1
fi

# install gmusicapi
echo "Installing gmusicapi..."
pip3 install gmusicapi

# get oauth credentials for GPM
read -p "Do you have OAuth credentials already set up for GPM? (y/N) " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    python3 oauth.py
fi

# get device ids in a very, very hacky way
echo "About to throw an error..."
python3 error.py
read -p "Please enter one of the device ids listed above: " deviceid

# get albums from GPM
echo "Getting albums and playlists from GPM (this may take some time)..."
python3 download.py $deviceid

# Upload music
./upload.sh

# clean up
rm albums.tmp playlists.tmp
