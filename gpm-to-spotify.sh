#! /bin/bash

# check for dependencies
if ! (which pip3 > /dev/null) ; then
    echo 'Error: pip not installed'
    exit 1
fi

# install gmusicapi
echo "Installing gmusicapi..."
pip3 install gmusicapi

# get oauth credentials
read -p "Do you have OAuth credentials already set up? (y/N) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    python3 oauth.py
fi

# get list of albums
# method for reading commnd into array comes from: https://stackoverflow.com/questions/11426529/reading-output-of-a-command-into-an-array-in-bash
mapfile -t albums < <( python3 download.py )
