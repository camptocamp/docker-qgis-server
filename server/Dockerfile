FROM ubuntu:17.04
MAINTAINER Camptocamp<info@camptocamp.com>

# A few variables needed by apache
ENV APACHE_CONFDIR=/etc/apache2 \
    APACHE_ENVVARS=$APACHE_CONFDIR/envvars \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_PID_FILE=$APACHE_RUN_DIR/apache2.pid \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_LOG_DIR=/var/log/apache2 \
    LANG=C

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libproj12 libgeos-3.5.1 libgdal20 \
      libexpat1 libfcgi libgsl2 libpq5 libqca2 libqca2-plugin-ossl \
      libqscintilla2-12v5 libqt4-opengl libqt4-sql-sqlite \
      libqtwebkit4 libqwt6abi1 libspatialindex4v5 libspatialite7 libsqlite3-0 \
      python python-qt4 python-qt4-sql \
      spawn-fcgi xauth xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xvfb \
      apache2 libapache2-mod-fcgid \
      python-gdal python-psycopg2 python-qscintilla2 python-pil python-shapely \
      python-qscintilla2 libqjson0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN a2enmod fcgid headers && \
    a2dismod -f auth_basic authn_file authn_core authz_host authz_user autoindex dir status && \
    rm /etc/apache2/mods-enabled/alias.conf && \
    mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR && \
    sed -ri ' \
      s!^(\s*CustomLog)\s+\S+!#\1 /proc/self/fd/1!g; \
      s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
      ' /etc/apache2/sites-enabled/000-default.conf /etc/apache2/apache2.conf && \
    mkdir -p /var/www/.qgis2 && \
    mkdir -p /var/www/plugins && \
    chown www-data: /var/www/.qgis2 && \
    mknod /var/log/docker p && \
    chown www-data: /var/log/docker

# A few tunable variables for QGIS
ENV QGIS_SERVER_LOG_LEVEL=0 \
    QGIS_SERVER_LOG_FILE=/var/log/docker \
    PGSERVICEFILE=/project/pg_service.conf \
    QGIS_PROJECT_FILE=/project/project.qgs \
    MAX_CACHE_LAYERS="" \
    QGIS_PLUGINPATH=/var/www/plugins \
    MAX_REQUESTS_PER_PROCESS=1000

COPY runtime /
COPY target /usr/local/
COPY start-client.sh /usr/local/bin

RUN ldconfig

EXPOSE 80
CMD while true; do echo "Listening"; cat /var/log/docker; done & (rm -f $APACHE_RUN_DIR/apache2.pid; apache2 -DFOREGROUND)
