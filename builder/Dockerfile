FROM ubuntu:16.04
MAINTAINER Camptocamp<info@camptocamp.com>

RUN apt-get -y update

RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y cmake flex bison libproj-dev \
    libgeos-dev libgdal1-dev \
    libexpat1-dev libfcgi-dev libgsl0-dev libpq-dev libqca2-dev libqca2-plugin-ossl \
    libqscintilla2-dev libqt4-dev libqt4-opengl-dev libqt4-sql-sqlite \
    libqtwebkit-dev libqwt-dev libspatialindex-dev libspatialite-dev libsqlite3-dev \
    lighttpd locales pkg-config poppler-utils pyqt4-dev-tools python python-dev \
    python-qt4 python-qt4-dev python-qt4-sql python-sip python-sip-dev \
    spawn-fcgi xauth xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xvfb \
    git ninja-build curl && \
    curl -L "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" > /usr/bin/gosu && \
    chmod a+x /usr/bin/gosu


COPY . /

ENTRYPOINT ["/entry.sh"]
CMD ["/build.sh"]
