from gmusicapi import Mobileclient
import uuid

api = Mobileclient()
mac = ':'.join(['{:02x}'.format((uuid.getnode() >> ele) & 0xff) for ele in range(0,8*6,8)][::-1]).upper()

# log in
api.oauth_login(device_id="55E93BCD8E7B")  # TODO: figure out how to get device ID

# get list of albums
albums = list(set([song.get("album") for song in api.get_all_songs()]))
for album in albums:
    print(album)
