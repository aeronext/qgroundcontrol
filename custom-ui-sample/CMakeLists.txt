# QGroundControl Custom Build
#
# This file is included by the main QGroundControl build system
# when a custom directory is detected.
#

message(STATUS "QGC: Loading custom UI configuration from ${CMAKE_CURRENT_SOURCE_DIR}")

# カスタムソースファイル（QGroundControlに統合される）
list(APPEND QGC_CUSTOM_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/CustomUIPlugin.cc"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/CustomUIPlugin.h"
)

# カスタムリソースファイル（QGroundControlに統合される）
list(APPEND QGC_RESOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/custom.qrc"
)

# カスタムインクルードディレクトリ
list(APPEND QGC_CUSTOM_INCLUDE_DIRS
    "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

# カスタムビルドフラグの設定
add_compile_definitions(
    QGC_CUSTOM_BUILD=1
    QGC_CUSTOM_UI_BUILD=1
    CUSTOM_BUILD=1
)

# QGroundControlターゲットが作成された後にカスタムソースを追加
if(TARGET ${CMAKE_PROJECT_NAME})
    target_sources(${CMAKE_PROJECT_NAME} PRIVATE ${QGC_CUSTOM_SOURCES})
    if(QGC_CUSTOM_INCLUDE_DIRS)
        target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${QGC_CUSTOM_INCLUDE_DIRS})
    endif()
endif()

message(STATUS "QGC: Custom UI configuration loaded")
message(STATUS "QGC: Japanese UI components enabled")
