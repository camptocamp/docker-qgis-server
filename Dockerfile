FROM ghcr.io/osgeo/gdal:ubuntu-small-3.7.3 as base-all
LABEL maintainer Camptocamp "info@camptocamp.com"
SHELL ["/bin/bash", "-o", "pipefail", "-cux"]

RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache,sharing=locked \
    apt-get update \
    && apt-get upgrade --assume-yes \
    && DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends python3-pip

# Used to convert the locked packages by poetry to pip requirements format
# We don't directly use `poetry install` because it force to use a virtual environment.
FROM base-all as poetry

# Install Poetry
WORKDIR /tmp
COPY requirements.txt ./
RUN --mount=type=cache,target=/root/.cache \
    python3 -m pip install --disable-pip-version-check --requirement=requirements.txt

# Do the conversion
COPY poetry.lock pyproject.toml ./
RUN poetry export --output=requirements.txt \
    && poetry export --extras=desktop --output=requirements-desktop.txt

# Base, the biggest thing is to install the Python packages
FROM base-all as builder
LABEL maintainer="info@camptocamp.com"

SHELL ["/bin/bash", "-o", "pipefail", "-cux"]

RUN --mount=type=cache,target=/var/lib/apt/lists,id=apt-list \
    --mount=type=cache,target=/var/cache,id=var-cache,sharing=locked \
    apt-get update \
    && apt-get install --assume-yes --no-install-recommends apt-utils gnupg2 \
    && . /etc/os-release \
    && echo "deb https://deb.nodesource.com/node_14.x ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/nodesource.list \
    && curl --silent https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
    && apt-get update \
    && echo 'Install packages from https://github.com/qgis/QGIS/blob/<branch>/INSTALL.md \
        Remove already in GDAL image: proj, GDAL and openjpeg ->: \
            gdal-bin python3-gdal python3-pyproj libgdal-dev libproj-dev \
        Remove error with SIP v6: sip-tools python3-pyqtbuild' \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends \
        bison ca-certificates ccache cmake cmake-curses-gui dh-python doxygen expect flex flip git \
        graphviz grass-dev libexiv2-dev libexpat1-dev libfcgi-dev libgeos-dev libgsl-dev libpdal-dev \
        libpq-dev libprotobuf-dev libqca-qt5-2-dev libqca-qt5-2-plugins libqscintilla2-qt5-dev \
        libqt5opengl5-dev libqt5serialport5-dev libqt5sql5-sqlite libqt5svg5-dev libqt5webkit5-dev \
        libqt5xmlpatterns5-dev libqwt-qt5-dev libspatialindex-dev libspatialite-dev libsqlite3-dev \
        libsqlite3-mod-spatialite libyaml-tiny-perl libzip-dev libzstd-dev lighttpd locales ninja-build \
        ocl-icd-opencl-dev opencl-headers pandoc pdal pkg-config poppler-utils protobuf-compiler \
        pyqt5-dev pyqt5-dev-tools pyqt5.qsci-dev python3-all-dev python3-autopep8 python3-dateutil \
        python3-dev python3-future python3-httplib2 python3-jinja2 python3-lxml \
        python3-markupsafe python3-mock python3-nose2 python3-owslib python3-plotly python3-psycopg2 \
        python3-pygments python3-pyqt5 python3-pyqt5.qsci python3-pyqt5.qtpositioning \
        python3-pyqt5.qtsql python3-pyqt5.qtsvg python3-pyqt5.qtwebkit python3-requests \
        python3-sip python3-sip-dev python3-termcolor python3-tz python3-yaml qt3d-assimpsceneimport-plugin \
        qt3d-defaultgeometryloader-plugin qt3d-gltfsceneio-plugin qt3d-scene2d-plugin qt3d5-dev \
        qtbase5-dev qtbase5-private-dev qtkeychain-qt5-dev qtpositioning5-dev qttools5-dev \
        qttools5-dev-tools spawn-fcgi xauth xfonts-100dpi xfonts-75dpi xfonts-base \
        xfonts-scalable xvfb \
    && echo 'Install some more packages' \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends \
        gnupg gcc clang nodejs

WORKDIR /usr/lib/
COPY package.json package-lock.json ./
RUN npm install

WORKDIR /tmp/

RUN --mount=type=cache,target=/root/.cache \
    --mount=type=bind,from=poetry,source=/tmp,target=/poetry \
    python3 -m pip install --disable-pip-version-check --no-deps --requirement=/poetry/requirements.txt \
    && (strip /usr/local/lib/python3.*/dist-packages/*/*.so || true)

RUN ln -s /usr/local/lib/libproj.so.* /usr/local/lib/libproj.so

ARG QGIS_BRANCH

RUN git clone https://github.com/qgis/QGIS --branch=${QGIS_BRANCH} --depth=100 /src

COPY checkout_release /tmp
WORKDIR /src/
RUN /tmp/checkout_release ${QGIS_BRANCH}

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
    -DWITH_SERVER_LANDINGPAGE_WEBAPP=ON \
    -DBUILD_TESTING=OFF \
    -DENABLE_TESTS=OFF \
    -DCMAKE_PREFIX_PATH=/src/external/qt3dextra-headers/cmake

RUN --mount=type=cache,target=/root/.ccache,id=ccache \
    ccache --show-stats \
    && ccache --max-size=2G \
    && ninja \
    && ccache --show-stats

FROM builder as builder-server

RUN ninja install
RUN rm -rf /usr/local/share/qgis/i18n/

FROM builder as builder-desktop

# -DWITH_3D=ON generate error: undefined reference to `Qt3DExtras::Qt3DWindow::Qt3DWindow(QScreen*)'
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
    -DQT5_3DEXTRA_LIBRARY=/usr/lib/x86_64-linux-gnu/libQt53DExtras.so \
    -DQt53DExtras_DIR=/src/external/qt3dextra-headers/cmake/Qt53DExtras

RUN --mount=type=cache,target=/root/.ccache,id=ccache \
    ninja \
    && ccache --show-stats

RUN ninja install

FROM base-all as runner
LABEL maintainer="info@camptocamp.com"

RUN --mount=type=cache,target=/var/lib/apt/lists,id=apt-list \
    --mount=type=cache,target=/var/cache,id=var-cache,sharing=locked \
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends \
        libfcgi libgslcblas0 libqca-qt5-2 libqca-qt5-2-plugins libzip4 \
        libqt5opengl5 libqt5sql5-sqlite libqt5concurrent5 libqt5positioning5 libqt5script5 \
        libqt5webkit5 libqwt-qt5-6 libspatialindex6 libspatialite7 libsqlite3-0 libqt5keychain1 \
        python3 python3-pip ocl-icd-libopencl1 \
        python3-pyqt5 python3-pyqt5.qtsql python3-pyqt5.qsci python3-pyqt5.qtpositioning \
        spawn-fcgi xauth xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xvfb \
        apache2 libapache2-mod-fcgid python3 \
        libqt5serialport5 libqt5quickwidgets5 libexiv2-27 libprotobuf23 libprotobuf-lite23 \
        libgsl27 libzstd1 binutils glibc-tools \
    && strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5

WORKDIR /tmp

RUN --mount=type=cache,target=/root/.cache \
    --mount=type=bind,from=poetry,source=/tmp,target=/poetry \
    python3 -m pip install --disable-pip-version-check --no-deps --requirement=/poetry/requirements.txt \
    && python3 -m pip freeze > /requirements.txt

FROM runner as runner-server

RUN --mount=type=cache,target=/var/lib/apt/lists,id=apt-list \
    --mount=type=cache,target=/var/cache,id=var-cache,sharing=locked \
    DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends libfcgi

# Be able to install font as nonroot
RUN chmod u+s /usr/bin/fc-cache \
    && chmod o+w /usr/local/share/fonts

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

RUN a2enmod fcgid headers status \
    && a2dismod -f auth_basic authn_file authn_core authz_user autoindex dir \
    && rm /etc/apache2/mods-enabled/alias.conf \
    && mkdir -p ${APACHE_RUN_DIR} ${APACHE_LOCK_DIR} ${APACHE_LOG_DIR} \
    && sed -ri ' \
    s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
    s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
    ' /etc/apache2/sites-enabled/000-default.conf /etc/apache2/apache2.conf \
    && sed -ri 's!LogFormat "(.*)" combined!LogFormat "%{us}T %{X-Request-Id}i \1" combined!g' /etc/apache2/apache2.conf \
    && echo 'ErrorLogFormat "%{X-Request-Id}i [%l] [pid %P] %M"' >> /etc/apache2/apache2.conf \
    && mkdir -p /var/www/.qgis3 \
    && mkdir -p /var/www/plugins \
    && chown www-data:root /var/www/.qgis3 \
    && ln --symbolic /etc/qgisserver /project

# A few tunable variables for QGIS
ENV QGIS_SERVER_LOG_STDERR=1 \
    QGIS_CUSTOM_CONFIG_PATH=/tmp \
    QGIS_PLUGINPATH=/var/www/plugins \
    FCGID_MAX_REQUESTS_PER_PROCESS=1000 \
    FCGID_MIN_PROCESSES=1 \
    FCGID_MAX_PROCESSES=5 \
    FCGID_BUSY_TIMEOUT=300 \
    FCGID_IDLE_TIMEOUT=300 \
    FCGID_IO_TIMEOUT=40 \
    FILTER_ENV='' \
    GET_ENV=env \
    PYTHONPATH=/usr/local/share/qgis/python/:/var/www/plugins/

COPY --from=builder-server /usr/local/bin /usr/local/bin/
COPY --from=builder-server /usr/local/lib /usr/local/lib/
COPY --from=builder-server /usr/local/share/qgis /usr/local/share/qgis
COPY --from=builder-server /src/build/output/data/resources/server/api/ogc/static/landingpage \
    /usr/local/share/qgis/resources/server/api/ogc/static/landingpage

COPY runtime /

RUN adduser www-data root \
    && chmod -R g+rw ${APACHE_CONFDIR} ${APACHE_RUN_DIR} ${APACHE_LOCK_DIR} ${APACHE_LOG_DIR} /var/lib/apache2/fcgid /var/log /var/www/.qgis3 \
    && chgrp -R root ${APACHE_LOG_DIR} /var/lib/apache2/fcgid

RUN ldconfig

WORKDIR /etc/qgisserver
EXPOSE 8080
CMD ["/usr/local/bin/start-server"]

FROM runner as runner-desktop

RUN --mount=type=cache,target=/var/lib/apt/lists,id=apt-list \
    --mount=type=cache,target=/var/cache,id=var-cache,sharing=locked \
    DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends \
    qt3d-assimpsceneimport-plugin qt3d-defaultgeometryloader-plugin qt3d-gltfsceneio-plugin \
    qt3d-scene2d-plugin

COPY requirements-desktop.txt ./
RUN --mount=type=cache,target=/root/.cache,id=root-cache \
    python3 -m pip install --disable-pip-version-check --requirement=requirements-desktop.txt \
    && rm --recursive --force /tmp/*

RUN --mount=type=cache,target=/root/.cache \
    --mount=type=bind,from=poetry,source=/tmp,target=/poetry \
    python3 -m pip install --disable-pip-version-check --no-deps --requirement=/poetry/requirements-desktop.txt \
    && python3 -m pip freeze > /requirements.txt

COPY --from=builder-desktop /usr/local/bin /usr/local/bin/
COPY --from=builder-desktop /usr/local/lib /usr/local/lib/
COPY --from=builder-desktop /usr/local/share /usr/local/share/
COPY runtime-desktop /

RUN ldconfig

WORKDIR /etc/qgisserver
CMD ["/usr/local/bin/start-client"]

FROM builder as cache

RUN --mount=type=cache,target=/root/.ccache,id=ccache \
    ccache --show-stats \
    && cp -ar /root/.ccache /.ccache

CMD ["tail", "-f", "/dev/null"]
