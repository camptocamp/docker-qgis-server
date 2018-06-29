#!/bin/bash
set -e

cd /build

export CC=/usr/lib/ccache/gcc
export CXX=/usr/lib/ccache/g++
cmake /src \
      -GNinja \
      -DQWT_INCLUDE_DIR=/usr/include/qwt \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython2.7.so \
      -DQSCINTILLA_INCLUDE_DIR=/usr/include/qt4 \
      -DQWT_LIBRARY=/usr/lib/libqwt.so \
      -DWITH_DESKTOP=ON \
      -DWITH_SERVER=ON \
      -DBUILD_TESTING=OFF \
      -DENABLE_TESTS=OFF

ccache -M10G
ninja install
ccache -s
