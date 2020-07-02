# gpm-to-spotfy
This is a tool for exporting your Google Play Music library (albums and playlists) to Spotify.

To get some disclaimers out of the way: I created this project for personal use only in 2020. It may not work in the future (actually, with GPM shutting down, I can guarantee it won't). I have no plans to support any platforms other than Linux, so don't ask; if you want that, submit a pull request.

## Getting started
You'll need to make sure you have `pip`, `nodejs`, and `jq` installed. On Ubuntu:

```
$ sudo apt install python3-pip nodejs jq
```

Make sure `gpm-to-spotify.sh` is executable:

```
$ chmod +x gpm-to-spotify.sh
```

From there, just execute `gpm-to-spotify.sh` and it should walk you through the rest.
