FROM ubuntu:16.04
MAINTAINER Camptocamp<info@camptocamp.com>

# A few variables needed by apache
ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_PID_FILE $APACHE_RUN_DIR/apache2.pid
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV LANG C

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libproj9 libgeos-3.5.0 libgdal1i \
      libexpat1 libfcgi libgsl2 libpq5 libqca-qt5-2 libqca2-plugin-ossl \
      libqt5scintilla2-12v5 libqt5opengl5 libqt5sql5-sqlite libqt5concurrent5 libqt5positioning5 libqt5script5 \
      libqt5webkit5 libqwt-qt5-6 libspatialindex4v5 libspatialite7 libsqlite3-0 \
      python3 python3-pip python3-pyqt5 python3-pyqt5.qtsql \
      spawn-fcgi xauth xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xvfb \
      apache2 libapache2-mod-fcgid \
      python3-gdal python3-pyqt5.qsci python3-pil python3-psycopg2 python3-shapely && \
    apt-get clean && \
    pip3 install future numpy pyyaml && \
    rm -rf /var/lib/apt/lists/* ~/.cache/pip

RUN a2enmod fcgid && \
    a2dismod -f auth_basic authn_file authn_core authz_host authz_user autoindex dir status && \
    rm /etc/apache2/mods-enabled/alias.conf && \
    mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR && \
    sed -ri ' \
      s!^(\s*CustomLog)\s+\S+!#\1 /proc/self/fd/1!g; \
      s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
      ' /etc/apache2/sites-enabled/000-default.conf /etc/apache2/apache2.conf && \
    mkdir -p /var/www/.qgis3 && \
    mkdir -p /var/www/plugins && \
    chown www-data: /var/www/.qgis3 && \
    mknod /var/log/docker p && \
    chown www-data: /var/log/docker

# A few tunable variables for QGIS
ENV QGIS_SERVER_LOG_LEVEL 0
ENV QGIS_SERVER_LOG_FILE /var/log/docker
ENV PGSERVICEFILE /project/pg_service.conf
ENV QGIS_PROJECT_FILE /project/project.qgs
ENV MAX_CACHE_LAYERS ""
ENV QGIS_PLUGINPATH /var/www/plugins

COPY runtime /
COPY target /usr/local/
COPY start-client.sh /usr/local/bin

RUN ldconfig

EXPOSE 80
CMD while true; do echo "Listening"; cat /var/log/docker; done & apache2 -DFOREGROUND
