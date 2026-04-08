#!/bin/bash
set -e

: ${BROWSER_AUDIO_ENABLED:='1'}
: ${BROWSER_AUDIO_PORT:='8090'}

if [[ "${BROWSER_AUDIO_ENABLED}" != "1" ]]; then
  echo "Browser audio proxy disabled (BROWSER_AUDIO_ENABLED=${BROWSER_AUDIO_ENABLED})."
  exec tail -f /dev/null
fi

if [[ -z "${VLC_MEDIA}" ]]; then
  echo "VLC_MEDIA is empty; cannot start browser audio proxy."
  exec tail -f /dev/null
fi

exec /usr/bin/ffmpeg \
  -nostdin \
  -loglevel warning \
  -reconnect 1 \
  -reconnect_streamed 1 \
  -reconnect_delay_max 2 \
  -i "${VLC_MEDIA}" \
  -vn \
  -ac 2 \
  -ar 44100 \
  -b:a 128k \
  -f mp3 \
  -listen 1 \
  "http://0.0.0.0:${BROWSER_AUDIO_PORT}/"
