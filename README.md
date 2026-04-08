VLC Kiosk via VNC
==

This image runs VLC inside Xvfb + Fluxbox, exposes desktop through x11vnc, and publishes noVNC for browser access.

Quick Start
--

1. Build and run with docker compose:

  ```sh
   docker compose up -d --build
  ```

1. Set your media source in docker-compose.yml:

  ```env
  VLC_MEDIA=https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
  ```

1. Connect with your VNC client to port 5900.

1. Open browser view with sound at <http://localhost:6080/vlc.html>

Performance Defaults
--

- VNC runs at 16-bit color depth by default to reduce bandwidth.
- x11vnc is started with options tuned for smoother remote interaction:
  -noxdamage -threads -wait 10
- VLC is started with low-latency playback options:
  --drop-late-frames --skip-frames --avcodec-fast

Important Environment Variables
--

- VNC_SCREEN_SIZE: virtual screen size (default: 1280x720)
- VNC_COLOR_DEPTH: color depth for Xvfb/VNC (default: 16)
- VNC_PASSWORD: optional VNC password
- VLC_MEDIA: file path or URL to play
- VLC_NETWORK_CACHING: VLC network cache in milliseconds (default: 150)
- VLC_PREFERRED_RESOLUTION: cap adaptive stream quality (default: 480)
- BROWSER_AUDIO_ENABLED: enable browser audio proxy stream (default: 1)
- BROWSER_AUDIO_PORT: browser audio stream port (default: 8090)
- VLC_OPTS_OVERRIDE: fully override VLC options if needed
- X11VNC_OPTS_OVERRIDE: fully override x11vnc options if needed

Audio Notes
--

- noVNC itself does not carry audio. Browser sound is provided by an FFmpeg MP3 proxy on BROWSER_AUDIO_PORT.
- The custom page /vlc.html loads both the noVNC session and the audio stream together.
- Browsers may block autoplay with sound; if so, click Start Audio once on the page.

Notes
--

- If VLC_MEDIA is not set, the container stays up and prints a message instead of crash-looping.
- To update VLC packages in a running container:

  ```sh
  docker exec --user=root <container_name> update
  ```
