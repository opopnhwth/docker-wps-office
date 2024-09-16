FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# set version label
ARG BUILD_DATE
ARG VERSION
ARG WPSOFFICE_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=WPS-Office

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/webtop-logo.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    chromium \
    chromium-l10n \
    libqt5gui5 \
    fcitx5 \
    fcitx5-pinyin \
    zsh \
    git \
    vim \
    fonts-noto-cjk \
    cmake \
    gcc \
    g++ \
    gfortran \
    p7zip-full \
    unrar \
    zip \
    libxfce4ui-utils \
    mousepad \
    tango-icon-theme \
    thunar \
    thunar-archive-plugin \
    xfce4-appfinder \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xfce4-taskmanager \
    xfce4-terminal \
    xfconf \
    xfdesktop4 \
    xfwm4  && \
  echo "**** install wps-office ****" && \
  if [ -z ${WPSOFFICE_VERSION+x} ]; then \
    WPSOFFICE_VERSION=$(curl -sL https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=wps-office \
    |awk -F'=' '/^pkgver=/ {print $2}'); \
  fi && \
  curl -o \
    /tmp/wps.deb -L \
    "https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/${WPSOFFICE_VERSION##*.}/wps-office_${WPSOFFICE_VERSION}.XA_amd64.deb" && \
  apt install -y /tmp/wps.deb && \
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
    /usr/lib/x86_64-linux-gnu/libtiff.so.6.0.0 \
    /usr/lib/x86_64-linux-gnu/libtiff.so.5 && \
  echo "**** openbox tweaks ****" && \
  sed -i \
    's/NLMC/NLIMC/g' \
    /etc/xdg/openbox/rc.xml && \
  echo "**** application tweaks ****" && \
  sed -i \
    's#^Exec=.*#Exec=/usr/local/bin/wrapped-chromium#g' \
    /usr/share/applications/chromium.desktop && \
  echo "**** xfce tweaks ****" && \
  rm -f \
    /etc/xdg/autostart/xscreensaver.desktop && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config
