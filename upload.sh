#! /bin/bash

client_id='ffaf5398b2ec4b0084f38b39b7bdefdf'
client_secret=$(<secret)
redirect_uri='http%3A%2F%2Flocalhost%3A8080%2Fcallback'

# Start the webserver
echo "Starting webserver on port 8080..."
node server.js &

# Get an authorization code
xdg-open "https://accounts.spotify.com/authorize?response_type=code&client_id=${client_id}&scope=user-library-modify&redirect_uri=${redirect_uri}"

read -p "Follow the prompts in your browser, then paste the access code here: " code

# Get tokens
curl -s -X POST \
     -d "grant_type=authorization_code&code=${code}&redirect_uri=${redirect_uri}&client_id=${client_id}&client_secret=${client_secret}" \
     "https://accounts.spotify.com/api/token" \
     | jq '[."access_token", ."refresh_token"] | .[]'

# Get the user's albums
# curl -X GET "https://api.spotify.com/v1/me/albums" -H "Authorization: Bearer ${code}"
