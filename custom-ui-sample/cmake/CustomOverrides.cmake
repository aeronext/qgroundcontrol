# カスタムUIサンプル用のCMakeオーバーライド
# QGroundControl Custom UI Sample CMake Overrides

message(STATUS "QGC: Loading custom UI sample overrides...")

# カスタムUI設定
set(CUSTOM_UI_BUILD ON)
set(CUSTOM_BUILD ON)

# 日本語UI関連の設定
set(QGC_JAPANESE_UI ON)

# カスタムプラグインの設定
set(CUSTOM_PLUGIN_NAME "CustomUIPlugin")
set(CUSTOM_PLUGIN_HEADER "CustomUIPlugin.h")

# ビルド出力の設定
message(STATUS "QGC: Custom UI sample configuration:")
message(STATUS "  - CUSTOM_BUILD: ${CUSTOM_BUILD}")
message(STATUS "  - CUSTOM_UI_BUILD: ${CUSTOM_UI_BUILD}")
message(STATUS "  - QGC_JAPANESE_UI: ${QGC_JAPANESE_UI}")
message(STATUS "  - Plugin: ${CUSTOM_PLUGIN_NAME}")

message(STATUS "QGC: Custom UI sample overrides loaded successfully")
