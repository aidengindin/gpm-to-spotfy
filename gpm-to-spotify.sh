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

# install gmusicapi
echo "Installing gmusicapi..."
pip3 install gmusicapi

# get oauth credentials for GPM
read -p "Do you have OAuth credentials already set up for GPM? (y/N) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    python3 oauth.py
fi


# get list of albums
python3 albums.py > albums.tmp

./upload.sh