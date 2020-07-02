#! /bin/bash

client_id='ffaf5398b2ec4b0084f38b39b7bdefdf'
client_secret=$(<secret)
redirect_uri='http%3A%2F%2Flocalhost%3A8080%2Fcallback'

# Start the webserver
echo "Starting webserver on port 8080..."
node server.js &
sleep 2  # wait a few seconds for the server to start

# Get an authorization code
xdg-open "https://accounts.spotify.com/authorize?response_type=code&client_id=${client_id}&scope=user-library-modify+user-library-read&redirect_uri=${redirect_uri}"

read -p "Follow the prompts in your browser, then paste the access code here: " code

# Get access token
token=$(curl -s -X POST \
     -d "grant_type=authorization_code&code=${code}&redirect_uri=${redirect_uri}&client_id=${client_id}&client_secret=${client_secret}" \
     "https://accounts.spotify.com/api/token" \
     | jq '."access_token"' \
     | sed 's/\"//g')

# Read albums
readarray -t albums < albums.tmp

# errors array contains albums that we couldn't find a match for
errors=()

# Where the magic happens
echo "Adding albums to Spotify (this may take some time...)"
for album in "${albums[@]}"; do
    encoded=$(urlencode $album)
    curl -s -X GET -H "Authorization: Bearer ${token}" "https://api.spotify.com/v1/search?q=${encoded}&type=album&limit=1"
    id=$(curl -s -X GET -H "Authorization: Bearer ${token}" "https://api.spotify.com/v1/search?q=${encoded}&type=album" \
        | jq '."albums"."items"[0]."id"' \
        | sed 's/\"//g')
    if [ $id == "null" ]; then
        errors[${#errors[@]}]=$album
    else
        curl -s -X PUT -H "Authorization: Bearer ${token}" "https://api.spotify.com/v1/me/albums?ids=${id}"
    fi
done

echo "No matches in Spotify were found for the following albums. You may want to add them manually."
for album in "${errors[@]}"; do
    echo "- ${album}"
done

# Stop the webserver
echo "Stopping webserver..."
killall node
