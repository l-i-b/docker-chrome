#!/bin/bash
set -e

# VNC default no password
export X11VNC_AUTH="-nopw"

# look for VNC password file in order (first match is used)
passwd_files=(
  /home/chrome/.vnc/passwd
  /run/secrets/vncpasswd
)

for passwd_file in ${passwd_files[@]}; do
  if [[ -f ${passwd_file} ]]; then
    export X11VNC_AUTH="-rfbauth ${passwd_file}"
    break
  fi
done

# override above if VNC_PASSWORD env var is set (insecure!)
if [[ "$VNC_PASSWORD" != "" ]]; then
  export X11VNC_AUTH="-passwd $VNC_PASSWORD"
fi

# make sure .config dir exists
mkdir -p /home/chrome/.config
chown chrome:chrome /home/chrome/.config

# set defaults tuned for lower VNC bandwidth and smoother remote playback
: ${VNC_SCREEN_SIZE:='1280x720'}
: ${VNC_COLOR_DEPTH:='16'}

if [[ ! "${VNC_SCREEN_SIZE}" =~ ^[0-9]+x[0-9]+$ ]]; then
  echo "Invalid VNC_SCREEN_SIZE='${VNC_SCREEN_SIZE}', falling back to 1280x720"
  VNC_SCREEN_SIZE='1280x720'
fi

IFS='x' read SCREEN_WIDTH SCREEN_HEIGHT <<< "${VNC_SCREEN_SIZE}"
if (( SCREEN_WIDTH < 320 || SCREEN_HEIGHT < 240 )); then
  echo "VNC_SCREEN_SIZE too small (${VNC_SCREEN_SIZE}), falling back to 1280x720"
  SCREEN_WIDTH=1280
  SCREEN_HEIGHT=720
fi

export VNC_SCREEN="${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${VNC_COLOR_DEPTH}"

# x11vnc options are exposed for tuning by environment variables
export X11VNC_OPTS="${X11VNC_OPTS_OVERRIDE:- -wait 10 -forever -shared -repeat -noxdamage -threads}"

# VLC defaults prioritize smooth playback over quality for remote kiosk usage
: ${VLC_NETWORK_CACHING:='150'}
: ${VLC_PREFERRED_RESOLUTION:='480'}
: ${BROWSER_AUDIO_ENABLED:='1'}
: ${BROWSER_AUDIO_PORT:='8090'}

VLC_AUDIO_OPTS='--aout=dummy'

export VLC_OPTS="${VLC_OPTS_OVERRIDE:- --fullscreen --loop --no-video-title-show --drop-late-frames --skip-frames --avcodec-fast --network-caching=${VLC_NETWORK_CACHING} --file-caching=100 --preferred-resolution=${VLC_PREFERRED_RESOLUTION} ${VLC_AUDIO_OPTS}}"

exec "$@"
