#!/usr/bin/env bash
set -ex

qt_cmake_args=()
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
    # Use native tools from the build environment with Qt libraries from PREFIX.
    qt_cmake_args+=(-DQT_HOST_PATH="$BUILD_PREFIX")
fi

mkdir -p build
cd build

cmake .. -GNinja \
    ${CMAKE_ARGS} \
    "${qt_cmake_args[@]}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DENABLE_QT4=OFF \
    -DENABLE_QT5=OFF \
    -DENABLE_QT6=ON \
    -DBUILD_ONLY_PLUGIN=ON \
    -DENABLE_QT6_WAYLAND_WORKAROUND=OFF

ninja install

# 兼容 conda-forge 下不同工具对 Qt6 插件路径的扫描习惯
PLUGIN_SO="$PREFIX/lib/qt6/plugins/platforminputcontexts/libfcitx5platforminputcontextplugin.so"
if [ -f "$PLUGIN_SO" ]; then
    mkdir -p "$PREFIX/plugins/platforminputcontexts"
    ln -sf "$PLUGIN_SO" "$PREFIX/plugins/platforminputcontexts/libfcitx5platforminputcontextplugin.so"
fi
