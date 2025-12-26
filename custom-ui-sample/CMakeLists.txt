cmake_minimum_required(VERSION 3.16)

project(QGroundControlCustomUI LANGUAGES CXX)

# QGroundControl Custom UI Sample
# Japanese localized UI with modern design

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# カスタムUIプラグインソース
set(CUSTOM_UI_SOURCES
    src/CustomUIPlugin.cc
    src/CustomUIPlugin.h
)

# リソースファイル
set(CUSTOM_UI_RESOURCES
    custom.qrc
)

# QMLファイル
set(CUSTOM_UI_QML
    res/Custom/Widgets/JapaneseInstrumentPanel.qml
    res/Custom/Widgets/CustomFlightStatus.qml
    res/Custom/Widgets/JapaneseNavigationBar.qml
    src/FlyViewCustomLayer.qml
)

# カスタマイズ設定
add_compile_definitions(
    CUSTOM_BUILD
    CUSTOM_UI_BUILD
    QGC_CUSTOM_BUILD
)

# インクルードディレクトリ
include_directories(
    src
    ${CMAKE_CURRENT_SOURCE_DIR}
)

message(STATUS "Custom UI Sample build configured")
message(STATUS "Building Japanese localized QGroundControl UI")
