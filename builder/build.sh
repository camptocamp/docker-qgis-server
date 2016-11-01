#!/bin/bash
set -e

cd /build

cmake /src \
      -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DWITH_DESKTOP=ON \
      -DWITH_SERVER=ON \
      -DBUILD_TESTING=OFF  \

ninja install
ccache -s
