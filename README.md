# gpm-to-spotfy
This is a tool for exporting your Google Play Music library (albums and playlists) to Spotify.

To get some disclaimers out of the way: I created this project for personal use only in 2020. It may not work in the future (actually, with GPM shutting down, I can guarantee it won't). I've only tested this on Ubuntu 20.04 and have no plans to support anything else, though it probably should work on other Linux distros, MacOS, or Windows with WSL.

## Getting started
You'll need to make sure you have `pip`, `nodejs`, `jq`, and `gridsite-clients` installed. On Ubuntu:

```
$ sudo apt install python3-pip nodejs jq gridsite-clients
```

Make sure `gpm-to-spotify.sh` is executable:

```
$ chmod +x gpm-to-spotify.sh
```

From there, just execute `gpm-to-spotify.sh` and it should walk you through the rest. Use the `-d` flag for a dry run to see what the script would do without actually pushing any changes to Spotify.

## Getting the client secret
A file called `secret`, containing my Spotify client secret key, is missing from this repository; the project won't work without it. This is because I don't want someone stealing the key and using it to gain access to the Spotify accounts of this project's users. Unless you can get my secret, you'll have to create your own project through the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/applications) and use your own client ID and secret key. You'll also have to add `http://localhost:8080/callback` as a redirect URI in the project settings in the dashboard.
