#!/bin/bash
set -e

if [[ -z "${VLC_MEDIA}" ]]; then
  echo "VLC_MEDIA is empty. Set VLC_MEDIA to a local file path or stream URL."
  echo "Example: VLC_MEDIA=https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
  exit 1
fi

exec /usr/bin/vlc ${VLC_OPTS} "${VLC_MEDIA}"