FROM tianon/true

COPY project /etc/qgisserver
COPY db /docker-entrypoint-initdb.d

VOLUME /etc/qgisserver
VOLUME /docker-entrypoint-initdb.d
