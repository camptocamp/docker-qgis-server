#!/bin/bash
set -e

cd /build

export CXX="/usr/lib/ccache/clang++"
export CC="/usr/lib/ccache/clang"

cmake /src \
      -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DWITH_DESKTOP=ON \
      -DWITH_SERVER=ON \
      -DWITH_3D=ON \
      -DBUILD_TESTING=OFF \
      -DENABLE_TESTS=OFF

ccache -M10G
ninja install
ccache -s
