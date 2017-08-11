FROM ubuntu:17.04
MAINTAINER Camptocamp<info@camptocamp.com>

RUN apt-get -y update && \
    LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y cmake flex bison libproj-dev \
        libgeos-dev libgdal-dev python-qscintilla2 libzip-dev \
        libexpat1-dev libfcgi-dev libgsl-dev libpq-dev libqca-qt5-2-dev libqca-qt5-2-dev libqca-qt5-2-plugins qttools5-dev-tools \
        libqt5scintilla2-dev libqt5opengl5-dev libqt5sql5-sqlite libqt5webkit5-dev qtpositioning5-dev qtxmlpatterns5-dev-tools libqt5xmlpatterns5-dev libqt5svg5-dev \
        libqwt-qt5-dev libspatialindex-dev libspatialite-dev libsqlite3-dev libqt5designer5 qttools5-dev qt5keychain-dev \
        lighttpd locales pkg-config poppler-utils python3 python3-dev python3-pip pyqt5-dev pyqt5-dev-tools \
        python3-pyqt5.qtsql pyqt5.qsci-dev python3-sip python3-sip-dev python3-gdal python3-geolinks python3-six qtscript5-dev python3-pyqt5.qsci python3-qwt \
        spawn-fcgi xauth xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xvfb \
        git ninja-build curl ccache clang \
        python-pyspatialite

RUN pip3 install future psycopg2 numpy nose2 pyyaml mock termcolor && \
    rm -r ~/.cache/pip && \
    curl -L "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" > /usr/bin/gosu && \
    chmod a+x /usr/bin/gosu

COPY . /

ENTRYPOINT ["/entry.sh"]
CMD ["/build.sh"]
