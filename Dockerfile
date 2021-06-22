FROM osgeo/gdal:ubuntu-small-3.3.0 as builder
LABEL maintainer="info@camptocamp.com"

RUN apt update && \
    apt install --assume-yes --no-install-recommends apt-utils software-properties-common && \
    apt autoremove --assume-yes software-properties-common && \
    LC_ALL=C DEBIAN_FRONTEND=noninteractive apt install --assume-yes --no-install-recommends cmake gcc \
    flex bison libzip-dev libexpat1-dev libfcgi-dev libgsl-dev \
    libpq-dev libqca-qt5-2-dev libqca-qt5-2-dev libqca-qt5-2-plugins qttools5-dev-tools \
    libqt5scintilla2-dev libqt5opengl5-dev libqt5sql5-sqlite libqt5webkit5-dev qtpositioning5-dev \
    qtxmlpatterns5-dev-tools libqt5xmlpatterns5-dev libqt5svg5-dev libqwt-qt5-dev libspatialindex-dev \
    libspatialite-dev libsqlite3-dev libqt5designer5 qttools5-dev qt5keychain-dev lighttpd locales \
    pkg-config poppler-utils python3 python3-dev python3-pip python3-setuptools \
    pyqt5-dev pyqt5-dev-tools pyqt5.qsci-dev python3-pyqt5.qtsql python3-pyqt5.qsci python3-pyqt5.qtpositioning \
    python3-sip python3-sip-dev python3-geolinks python3-six qtscript5-dev spawn-fcgi xauth xfonts-100dpi \
    xfonts-75dpi xfonts-base xfonts-scalable xvfb git ninja-build ccache clang libpython3-dev \
    libqt53dcore5 libqt53dextras5 libqt53dlogic5 libqt53dinput5 libqt53drender5 libqt5serialport5-dev \
    libexiv2-dev libgeos-dev protobuf-compiler libprotobuf-dev libzstd-dev qt3d5-dev qt3d-assimpsceneimport-plugin \
    qt3d-defaultgeometryloader-plugin qt3d-gltfsceneio-plugin qt3d-scene2d-plugin && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/
RUN python3 -m pip install --disable-pip-version-check --no-cache-dir --requirement=/tmp/requirements.txt && \
  rm --recursive --force /tmp/*

COPY Pipfile Pipfile.lock ./
RUN pipenv sync --system --clear && \
  rm --recursive --force /usr/local/lib/python3.*/dist-packages/tests/ /tmp/* /root/.cache/* && \
  strip /usr/local/lib/python3.*/dist-packages/*/*.so || true

RUN ln -s /usr/local/lib/libproj.so.* /usr/local/lib/libproj.so

ARG QGIS_BRANCH

RUN git clone https://github.com/qgis/QGIS --branch=${QGIS_BRANCH} --depth=100 /src

COPY checkout_release /tmp
RUN cd /src; /tmp/checkout_release ${QGIS_BRANCH}

ENV \
    CXX=/usr/lib/ccache/clang++ \
    CC=/usr/lib/ccache/clang \
    QT_SELECT=5

WORKDIR /src/build
RUN cmake .. \
    -GNinja \
    -DCMAKE_C_FLAGS="-O2 -DPROJ_RENAME_SYMBOLS" \
    -DCMAKE_CXX_FLAGS="-O2 -DPROJ_RENAME_SYMBOLS" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DWITH_DESKTOP=OFF \
    -DWITH_SERVER=ON \
    -DBUILD_TESTING=OFF \
    -DENABLE_TESTS=OFF \
    -DCMAKE_PREFIX_PATH="/src/external/qt3dextra-headers/cmake"

RUN ccache --max-size=10G
RUN ninja
RUN ccache --show-stats

FROM builder as builder-server

RUN ninja install

FROM builder as builder-desktop

RUN cmake .. \
    -GNinja \
    -DCMAKE_C_FLAGS="-O2 -DPROJ_RENAME_SYMBOLS" \
    -DCMAKE_CXX_FLAGS="-O2 -DPROJ_RENAME_SYMBOLS" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DWITH_DESKTOP=ON \
    -DWITH_SERVER=OFF \
    -DBUILD_TESTING=OFF \
    -DENABLE_TESTS=OFF \
    -DWITH_GEOREFERENCER=ON \
    -DCMAKE_PREFIX_PATH=/src/external/qt3dextra-headers/cmake \
    -DQT5_3DEXTRA_INCLUDE_DIR=/src/external/qt3dextra-headers \
    -DQT5_3DEXTRA_LIBRARY=/usr/lib/x86_64-linux-gnu/libQt53DExtras.so.5 \
    -DQt53DExtras_DIR=/src/external/qt3dextra-headers/cmake/Qt53DExtras \
    -DWITH_3D=ON

RUN ninja install
RUN ccache --show-stats

FROM osgeo/gdal:ubuntu-small-3.3.0 as runner
LABEL maintainer="info@camptocamp.com"

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install --assume-yes --no-install-recommends \
    libfcgi libgslcblas0 libqca-qt5-2 libqca-qt5-2-plugins libzip5 \
    libqt5opengl5 libqt5sql5-sqlite libqt5concurrent5 libqt5positioning5 libqt5script5 \
    libqt5webkit5 libqwt-qt5-6 libspatialindex6 libspatialite7 libsqlite3-0 libqt5keychain1 \
    python3 python3-pip python3-setuptools python3-pyqt5 python3-owslib python3-jinja2 python3-pygments \
    python3-pyqt5.qtsql \
    spawn-fcgi xauth xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xvfb \
    apache2 libapache2-mod-fcgid \
    python3-pyqt5.qsci python3-pil python3-psycopg2 python3-shapely libpython3-dev \
    libqt5serialport5 libqt5quickwidgets5 libexiv2-27 libprotobuf17 libprotobuf-lite17 \
    libgsl23 libzstd1 binutils && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5

RUN python3 -m pip --no-cache-dir install future psycopg2 numpy nose2 pyyaml mock termcolor PythonQwt

FROM runner as runner-server

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install --assume-yes --no-install-recommends libfcgi && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Be able to install font as nonroot
RUN chmod u+s /usr/bin/fc-cache && \
    chmod o+w /usr/local/share/fonts

# A few variables needed by Apache
ENV APACHE_CONFDIR=/etc/apache2 \
    APACHE_ENVVARS=/etc/apache2/envvars \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_PID_FILE=/etc/apache2/apache2.pid \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_LOG_DIR=/var/log/apache2 \
    LANG=C.UTF-8

RUN a2enmod fcgid headers status && \
    a2dismod -f auth_basic authn_file authn_core authz_user autoindex dir && \
    rm /etc/apache2/mods-enabled/alias.conf && \
    mkdir -p ${APACHE_RUN_DIR} ${APACHE_LOCK_DIR} ${APACHE_LOG_DIR} && \
    sed -ri ' \
    s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
    s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
    ' /etc/apache2/sites-enabled/000-default.conf /etc/apache2/apache2.conf && \
    sed -ri 's!LogFormat "(.*)" combined!LogFormat "%{us}T %{X-Request-Id}i \1" combined!g' /etc/apache2/apache2.conf && \
    echo 'ErrorLogFormat "%{X-Request-Id}i [%l] [pid %P] %M"' >> /etc/apache2/apache2.conf && \
    mkdir -p /var/www/.qgis3 && \
    mkdir -p /var/www/plugins && \
    chown www-data:root /var/www/.qgis3 && \
    ln --symbolic /etc/qgisserver /project

# A few tunable variables for QGIS
ENV QGIS_SERVER_LOG_LEVEL=0 \
    QGIS_SERVER_LOG_STDERR=1 \
    PGSERVICEFILE=/etc/qgisserver/pg_service.conf \
    QGIS_PROJECT_FILE=/etc/qgisserver/project.qgs \
    QGIS_CUSTOM_CONFIG_PATH=/tmp \
    MAX_CACHE_LAYERS="" \
    QGIS_PLUGINPATH=/var/www/plugins \
    QGIS_AUTH_DB_DIR_PATH=/etc/qgisserver/ \
    FCGID_MAX_REQUESTS_PER_PROCESS=1000 \
    FCGID_MIN_PROCESSES=1 \
    FCGID_MAX_PROCESSES=5 \
    FCGID_BUSY_TIMEOUT=300 \
    FCGID_IDLE_TIMEOUT=300 \
    FCGID_IO_TIMEOUT=40

COPY --from=builder-server /usr/local/bin /usr/local/bin/
COPY --from=builder-server /usr/local/lib /usr/local/lib/
COPY --from=builder-server /usr/local/share/qgis/python /usr/local/share/qgis/python/
COPY runtime /

RUN adduser www-data root && \
    chmod -R g+rw ${APACHE_CONFDIR} ${APACHE_RUN_DIR} ${APACHE_LOCK_DIR} ${APACHE_LOG_DIR} /var/lib/apache2/fcgid /var/log /var/www/.qgis3 && \
    chgrp -R root ${APACHE_LOG_DIR} /var/lib/apache2/fcgid

RUN ldconfig

WORKDIR /etc/qgisserver
EXPOSE 8080
CMD ["/usr/local/bin/start-server"]

FROM runner as runner-desktop

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install --assume-yes --no-install-recommends \
    qt3d-assimpsceneimport-plugin qt3d-defaultgeometryloader-plugin qt3d-gltfsceneio-plugin \
    qt3d-scene2d-plugin && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder-desktop /usr/local/bin /usr/local/bin/
COPY --from=builder-desktop /usr/local/lib /usr/local/lib/
COPY --from=builder-desktop /usr/local/share /usr/local/share/
COPY runtime-desktop /

RUN ldconfig

WORKDIR /etc/qgisserver
CMD ["/usr/local/bin/start-client"]
