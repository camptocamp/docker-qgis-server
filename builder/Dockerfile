FROM ubuntu:18.04
MAINTAINER Camptocamp<info@camptocamp.com>

RUN apt-get -y update && \
    LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y cmake flex bison libproj-dev \
        libgeos-dev libgdal-dev libzip-dev \
        libexpat1-dev libfcgi-dev libgsl-dev libpq-dev libqca-qt5-2-dev libqca-qt5-2-dev libqca-qt5-2-plugins qttools5-dev-tools \
        libqt5scintilla2-dev libqt5opengl5-dev libqt5sql5-sqlite libqt5webkit5-dev qtpositioning5-dev qtxmlpatterns5-dev-tools libqt5xmlpatterns5-dev libqt5svg5-dev \
        libqwt-qt5-dev libspatialindex-dev libspatialite-dev libsqlite3-dev libqt5designer5 qttools5-dev qt5keychain-dev \
        lighttpd locales pkg-config poppler-utils python3 python3-dev python3-pip pyqt5-dev pyqt5-dev-tools \
        python3-pyqt5.qtsql pyqt5.qsci-dev python3-sip python3-sip-dev python3-gdal python3-geolinks python3-six qtscript5-dev python3-pyqt5.qsci \
        spawn-fcgi xauth xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xvfb \
        git ninja-build curl ccache clang \
        libpython3.7-dev libqt53dcore5 libqt53dextras5 libqt53dlogic5 libqt53dinput5 libqt53drender5 \
        qt3d5-dev qt3d-assimpsceneimport-plugin qt3d-defaultgeometryloader-plugin qt3d-gltfsceneio-plugin qt3d-scene2d-plugin \
        libqt5serialport5-dev

RUN pip3 --no-cache-dir install future psycopg2 numpy nose2 pyyaml mock termcolor PythonQwt && \
    curl -L "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" > /usr/bin/gosu && \
    chmod a+x /usr/bin/gosu

COPY . /

ENTRYPOINT ["/entry.sh"]
CMD ["/build.sh"]
