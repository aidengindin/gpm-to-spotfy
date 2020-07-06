from gmusicapi import Mobileclient
import sys

api = Mobileclient()
device_id = sys.argv[1]

# log in
api.oauth_login(device_id=device_id)

# get albums

# albums_file = open("albums.tmp", "a")
# 
# # get list of all songs
# songs = api.get_all_songs()
# 
# # get rid of duplicate albums
# dedup = [] # for deduplicated
# ids = []
# for song in songs:
#     if song.get("albumId") not in ids:
#         dedup.append(song)
#         ids.append(song.get("albumId"))
# 
# for song in dedup:
#     try:
#         album = api.get_album_info(song.get("albumId"), include_tracks=False)
#         albums_file.write(album.get('name') + '|' + album.get('albumArtist'))
#     except:
#         sys.stderr.write("Couldn't retrieve info for album: " + song.get("album") + "\n")
# albums_file.close()

# get playlists
playlists_file = open("playlists.tmp", "a")
playlists = [playlist for playlist in api.get_all_user_playlist_contents() if not playlist.get("deleted")]
for playlist in playlists:
    playlists_file.write("PLAYLIST ENTRY: " + playlist.get("name") + "\n")
    for track in playlist.get("tracks"):
        try:
            track_info = api.get_track_info(track.get("trackId"))
            playlists_file.write(track_info.get("title") + "|" + track_info.get("artist") + "\n")
        except:
            sys.stderr.write("Couldn't retrieve info for song " + track.get("id") + " on playlist " + playlist.get("name") + "\n")
playlists_file.close()
