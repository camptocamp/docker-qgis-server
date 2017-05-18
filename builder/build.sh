#!/bin/bash
set -e

cd /build

export CXX="clang++"
export CC="clang"

cmake /src \
      -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DWITH_DESKTOP=ON \
      -DWITH_SERVER=ON \
      -DBUILD_TESTING=OFF

ccache -M10G
ninja install
ccache -s
