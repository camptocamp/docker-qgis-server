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
      libexpat1 libfcgi libgsl2 libpq5 libqca2 libqca2-plugin-ossl \
      libqscintilla2-12v5 libqt4-opengl libqt4-sql-sqlite \
      libqtwebkit4 libqwt6abi1 libspatialindex4v5 libspatialite7 libsqlite3-0 \
      python python-qt4 python-qt4-sql \
      spawn-fcgi xauth xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xvfb \
      apache2 libapache2-mod-fcgid \
      python-gdal python-psycopg2 python-qscintilla2 python-pil python-shapely && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN a2enmod fcgid && \
    a2dismod -f auth_basic authn_file authn_core authz_host authz_user autoindex dir status && \
    rm /etc/apache2/mods-enabled/alias.conf && \
    mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR && \
    sed -ri ' \
      s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
      s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
      ' /etc/apache2/sites-enabled/000-default.conf /etc/apache2/apache2.conf && \
    mkdir -p /var/www/.qgis2 && \
    mkdir -p /var/www/plugins && \
    chown www-data: /var/www/.qgis2 && \
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
