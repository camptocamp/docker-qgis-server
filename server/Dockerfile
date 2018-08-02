FROM ubuntu:18.04
MAINTAINER Camptocamp<info@camptocamp.com>

# A few variables needed by apache
ENV APACHE_CONFDIR=/etc/apache2 \
    APACHE_ENVVARS=/etc/apache2/envvars \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_PID_FILE=/etc/apache2/apache2.pid \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_LOG_DIR=/var/log/apache2 \
    LANG=C.UTF-8

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libproj12 libgeos-3.6.2 libgdal20 \
      libexpat1 libfcgi libgslcblas0 libpq5 libqca-qt5-2 libqca2-plugins libzip4 \
      libqt5opengl5 libqt5sql5-sqlite libqt5concurrent5 libqt5positioning5 libqt5script5 \
      libqt5webkit5 libqwt-qt5-6 libspatialindex4v5 libspatialite7 libsqlite3-0 libqt5keychain1 \
      python3 python3-pip python3-pyqt5 python3-owslib python3-jinja2 python3-pygments \
      python3-pyqt5.qtsql PyQt5.QtSvg \
      spawn-fcgi xauth xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xvfb \
      apache2 libapache2-mod-fcgid \
      python3-gdal python3-pyqt5.qsci python3-pil python3-psycopg2 python3-shapely libpython3.7-dev \
      libqt53dcore5 libqt53dextras5 libqt53dlogic5 libqt53dinput5 libqt53drender5 \
      libqt5serialport5 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 --no-cache-dir install future psycopg2 numpy nose2 pyyaml mock termcolor PythonQwt

RUN a2enmod fcgid headers && \
    a2dismod -f auth_basic authn_file authn_core authz_host authz_user autoindex dir status && \
    rm /etc/apache2/mods-enabled/alias.conf && \
    mkdir -p ${APACHE_RUN_DIR} ${APACHE_LOCK_DIR} ${APACHE_LOG_DIR} && \
    sed -ri ' \
      s!^(\s*CustomLog)\s+\S+!#\1 /proc/self/fd/1!g; \
      s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
      ' /etc/apache2/sites-enabled/000-default.conf /etc/apache2/apache2.conf && \
    mkdir -p /var/www/.qgis3 && \
    mkdir -p /var/www/plugins && \
    chown www-data:root /var/www/.qgis3 && \
    mknod /var/log/docker p && \
    chown www-data:root /var/log/docker && \
    ln --symbolic /project /etc/qgisserver


# A few tunable variables for QGIS
ENV QGIS_SERVER_LOG_LEVEL=0 \
    QGIS_SERVER_LOG_FILE=/var/log/docker \
    PGSERVICEFILE=/etc/qgisserver/pg_service.conf \
    QGIS_PROJECT_FILE=/etc/qgisserver/project.qgs \
    QGIS_CUSTOM_CONFIG_PATH=/tmp \
    MAX_CACHE_LAYERS="" \
    QGIS_PLUGINPATH=/var/www/plugins \
    QGIS_AUTH_DB_DIR_PATH=/etc/qgisserver/ \
    MAX_REQUESTS_PER_PROCESS=1000

COPY runtime /
COPY target /usr/local/

RUN adduser www-data root && \
    chmod -R g+w ${APACHE_CONFDIR} ${APACHE_RUN_DIR} ${APACHE_LOCK_DIR} ${APACHE_LOG_DIR} /var/lib/apache2/fcgid /var/log/docker /var/www/.qgis3 && \
    chgrp -R root ${APACHE_LOG_DIR} /var/lib/apache2/fcgid

RUN ldconfig

WORKDIR /etc/qgisserver
EXPOSE 80
CMD ["/usr/local/bin/start-server"]
