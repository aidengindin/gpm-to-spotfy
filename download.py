from gmusicapi import Mobileclient
import sys

api = Mobileclient()
device_id = sys.argv[1]

# log in
api.oauth_login(device_id=device_id)

# get list of all songs
songs = [song for song in api.get_all_songs()]

# get rid of duplicate albums
dedup = [] # for deduplicated
ids = []
for song in songs:
    if song.get("albumId") not in ids:
        dedup.append(song)
        ids.append(song.get("albumId"))

for song in dedup:
    try:
        album = api.get_album_info(song.get("albumId"), include_tracks=False)
        print(album.get('name') + '|' + album.get('albumArtist'))
    except:
        sys.stderr.write("Couldn't retrieve info for album: " + song.get("album") + "\n")
