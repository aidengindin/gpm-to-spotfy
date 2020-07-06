#! /bin/bash

client_id='ffaf5398b2ec4b0084f38b39b7bdefdf'
client_secret=$(<secret)
redirect_uri='http%3A%2F%2Flocalhost%3A8080%2Fcallback'

# Start the webserver
echo "Starting webserver on port 8080..."
node server.js &
sleep 2  # wait a few seconds for the server to start

# Get an authorization code
xdg-open "https://accounts.spotify.com/authorize?response_type=code&client_id=${client_id}&scope=user-library-modify+user-library-read+playlist-read-private+playlist-modify-private&redirect_uri=${redirect_uri}"

read -p "Follow the prompts in your browser, then paste the access code here: " code

# Get access token
token=$(curl -s -X POST \
             -d "grant_type=authorization_code&code=${code}&redirect_uri=${redirect_uri}&client_id=${client_id}&client_secret=${client_secret}" \
             "https://accounts.spotify.com/api/token" \
            | jq '."access_token"' \
            | sed 's/\"//g')

# Get user id
user_id=$(curl -s -X GET \
               -H "Authorization: Bearer ${token}" \
               "https://api.spotify.com/v1/me" \
              | jq '."id"' \
              | sed 's/\"//g')

# Read albums & artists
readarray -t lines < albums.tmp
albums=()
artists=()
for line in "${lines[@]}"; do
    IFS='|' read -ra line_arr <<< $line
    albums[${#albums[@]}]=${line_arr[0]}
    artists[${#artists[@]}]=${line_arr[1]}
done

# errors array contains albums that we couldn't find a match for
errors=()

# Add albums to Spotify
echo "Adding albums to Spotify (this may take some time...)"
for i in $(seq 1 ${#albums[@]}); do
    album=${albums[i]}
    artist=${artists[i]}
    encoded_album=$(urlencode $album)
    encoded_artist=$(urlencode $artist)
    id=$(curl -s -X GET -H "Authorization: Bearer ${token}" "https://api.spotify.com/v1/search?q=album:${encoded_album}+artist:${encoded_artist}&type=album" \
        | jq '."albums"."items"[0]."id"' \
        | sed 's/\"//g')
    if [[ $id == "null" ]]; then
        errors[${#errors[@]}]=$album
    else
        curl -s -X PUT -H "Authorization: Bearer ${token}" "https://api.spotify.com/v1/me/albums?ids=${id}"
    fi
done

# Show failed albums to the user
echo "No matches in Spotify were found for the following albums. You may want to add them manually."
for album in "${errors[@]}"; do
    echo "- ${album}"
done

# Get playlists
echo "Copying playlists to Spotify (this may take some time)..."

# Re-initialize errors array
errors=()
while read -r line; do

    # Lines marked with "PLAYLIST ENTRY" mark the beginning of a new playlist and contain the playlist name
    if [[ $line =~ "PLAYLIST ENTRY" ]]; then
        name=$(echo $line | awk '{$1=$2=""; print $0}')
        playlist_id=$(curl -s -X POST \
                           -H "Authorization: Bearer ${token}" \
                           -H "Content-Type: application/json" \
                           -d "{\"name\": \"${name}\", \"public\": false}" \
                           "https://api.spotify.com/v1/users/${user_id}/playlists" \
                          | jq '."id"' \
                          | sed 's/\"//g')
    else

        # Get the song id
        IFS='|' read -ra line_arr <<< $line
        song=${line_arr[0]}
        artist=${line_arr[1]}
        encoded_song=$(urlencode $song)
        encoded_artist=$(urlencode $artist)
        song_uri=$(curl -s -X GET \
                        -H "Authorization: Bearer ${token}" \
                        "https://api.spotify.com/v1/search?q=track:${encoded_song}+artist:${encoded_artist}&type=track" \
                       | jq '."tracks"."items"[0]."uri"' \
                       | sed 's/\"//g')

        # If it failed, add it to the error array
        if [[ $song_uri == "null" ]]; then
            errors[${#errors[@]}]="${song} in playlist ${name}"
        else
            # Add the song to the playlist
            encoded_uri=$(urlencode $song_uri)
            curl -s -X POST \
                 -H "Authorization: Bearer ${token}" \
                 -H "Content-Type: application/json" \
                 "https://api.spotify.com/v1/playlists/${playlist_id}/tracks?uris=${encoded_uri}" \
                 > /dev/null
        fi
    fi
done < playlists.tmp

# Notify the user of any songs that couldn't be added to playlists
echo "No matches in Spotify could be found for the following songs:"
for song in "${errors[@]}"; do
    echo "- ${song}"
done

# Stop the webserver
echo "Stopping webserver..."
killall node
