FROM ghcr.io/linuxserver/baseimage-kasmvnc:arch

# set version label
ARG BUILD_DATE
ARG VERSION
ARG WPSOFFICE_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=WPS-Office \
    LC_ALL=zh_CN.UTF-8 \
    NO_FULL=true

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/wps-office-icon.png && \
  echo "**** install packages ****" && \
  pacman -Sy --noconfirm --needed \
    chromium \
    mousepad \
    xfce4 \
    xfce4-pulseaudio-plugin \
    noto-fonts-cjk \
    git \
    qt6-base \
    tint2 \
    thunar && \
  echo "**** install wps-office ****" && \
  cd /tmp && \
  git clone https://aur.archlinux.org/wps-office-cn.git && \
  chown -R abc:abc wps-office-cn && \
  cd wps-office-cn && \
  sudo -u abc makepkg -sAci --skipinteg --noconfirm --needed && \
  mkdir /tmp/fonts && \
  curl -o \
    /tmp/fonts.tar.gz -L \
    "https://github.com/BannedPatriot/ttf-wps-fonts/archive/refs/heads/master.tar.gz" && \
  tar xf \
    /tmp/fonts.tar.gz -C \
    /tmp/fonts/ --strip-components=1 && \
  cd /tmp/fonts && \
  bash install.sh && cd / && \
  ln -s \
    /usr/lib/libtiff.so.6 \
    /usr/lib/libtiff.so.5 && \
  echo "**** application tweaks ****" && \
  mv \
    /usr/bin/chromium \
    /usr/bin/chromium-real && \
  sed -i \
    's#^Exec=.*#Exec=/usr/local/bin/wrapped-chromium#g' \
    /usr/share/applications/chromium.desktop && \
  mv /usr/bin/exo-open /usr/bin/exo-open-real && \
  echo "**** xfce tweaks ****" && \
  rm -f \
    /etc/xdg/autostart/xfce4-power-manager.desktop \
    /etc/xdg/autostart/xfce-polkit.desktop \
    /etc/xdg/autostart/xscreensaver.desktop \
    /usr/share/xfce4/panel/plugins/power-manager-plugin.desktop && \
  echo "**** cleanup ****" && \
  pacman -Rsn --noconfirm \
    git \
    $(pacman -Qdtq) && \
  rm -rf \
    /config/.cache \
    /tmp/* \
    /var/cache/pacman/pkg/* \
    /var/lib/pacman/sync/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config
