FROM ubuntu:22.04

LABEL maintainer="Tomohisa Kusano <siomiz@gmail.com>"

ENV VNC_SCREEN_SIZE=1024x768
ENV DEBIAN_FRONTEND=noninteractive

COPY copyables /

# Update packages, install essential dependencies, and clean up
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    ffmpeg \
    fonts-noto-cjk \
    novnc \
    pulseaudio \
    supervisor \
    vlc \
    websockify \
    x11vnc \
    fluxbox \
    eterm \
    xvfb \
    xauth \
    wget && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    rm -rf /var/cache/* /var/log/apt/* /tmp/*

# Configure the environment
RUN groupadd -r pulse-access || true && \
    useradd -m -G audio,video,pulse-access chrome && \
    usermod -s /bin/bash chrome && \
    ln -s /update /usr/local/sbin/update && \
    cp /novnc-vlc.html /usr/share/novnc/vlc.html && \
    mkdir -p /home/chrome/.config /home/chrome/.fluxbox && \
    echo ' \n\
       session.screen0.toolbar.visible:        false\n\
       session.screen0.fullMaximization:       true\n\
       session.screen0.maxDisableResize:       true\n\
       session.screen0.maxDisableMove: true\n\
       session.screen0.defaultDeco:    NONE\n\
    ' >> /home/chrome/.fluxbox/init && \
    chown -R chrome:chrome /home/chrome/.config /home/chrome/.fluxbox

USER chrome

VOLUME ["/home/chrome"]

WORKDIR /home/chrome

EXPOSE 5900
EXPOSE 6080
EXPOSE 8090

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]