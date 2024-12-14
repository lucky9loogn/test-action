cmake_minimum_required(VERSION 3.20)

project(BleHelper VERSION 1.0)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/.cmake/)
include(GetVersionFromGit)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core)

add_subdirectory(FluentUI)
add_subdirectory(BleHelper)
