#!/bin/bash
set -euo pipefail

BUILD_TYPE="${1:-${BUILD_TYPE:-Release}}"
ANDROID_ABIS="${ANDROID_ABIS:-arm64-v8a}"  # Options: arm64-v8a, armeabi-v7a, or both with semicolon
CUSTOM_DIR_NAME="${CUSTOM_DIR_NAME:-custom-ui-sample}"

case "${BUILD_TYPE}" in
    Release|Debug|RelWithDebInfo|MinSizeRel) ;;
    *)
        echo "Error: Invalid BUILD_TYPE: ${BUILD_TYPE}"
        echo "Usage: $0 [Release|Debug|RelWithDebInfo|MinSizeRel]"
        exit 1
        ;;
esac

echo "========================================="
echo "カスタムQGroundControlビルドを開始します"
echo "========================================="
echo "ビルドタイプ: ${BUILD_TYPE}"
echo "カスタムビルド: ${CUSTOM_BUILD:-OFF}"
echo "カスタムUI: ${CUSTOM_UI_BUILD:-OFF}"
echo "カスタムディレクトリ名: ${CUSTOM_DIR_NAME}"
echo "ソース: /project/source"
echo "ビルド: /project/build"
echo "========================================="

# カスタムディレクトリの準備
echo "カスタムビルド環境を準備中..."

# カスタムディレクトリの存在確認と準備
POTENTIAL_CUSTOM_DIRS=(
    "/project/source/${CUSTOM_DIR_NAME}"
    "/project/source/custom-ui-sample"
    "/project/source/custom"
)

CUSTOM_SOURCE_DIR=""
for dir in "${POTENTIAL_CUSTOM_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        CUSTOM_SOURCE_DIR="$dir"
        echo "カスタムソースディレクトリを検出: $CUSTOM_SOURCE_DIR"
        break
    fi
done

if [[ -z "$CUSTOM_SOURCE_DIR" ]]; then
    echo "警告: カスタムディレクトリが見つかりません"
    echo "以下の場所を確認しました:"
    for dir in "${POTENTIAL_CUSTOM_DIRS[@]}"; do
        echo "  - $dir"
    done
    echo "カスタムビルドは無効になります"
    export CUSTOM_BUILD=OFF
    export CUSTOM_UI_BUILD=OFF
else
    # customディレクトリが存在しない場合、カスタムディレクトリをcustomにリネーム
    if [[ ! -d "/project/source/custom" ]]; then
        echo "カスタムディレクトリを custom にリネーム中..."
        cp "$CUSTOM_SOURCE_DIR" "/project/source/custom"
        echo "✅ リネーム完了: $(basename "$CUSTOM_SOURCE_DIR") → custom"
    fi

    # カスタムディレクトリの内容を確認
    echo "カスタムディレクトリの内容:"
    ls -la /project/source/custom/ || echo "ディレクトリの内容を表示できません"
fi

if [[ -n "${ANDROID_SDK_ROOT:-}" ]]; then
    # Validate required Android environment variables
    for var in QT_HOST_PATH QT_ROOT_DIR_ARM64 ANDROID_SDK_ROOT; do
        if [[ -z "${!var:-}" ]]; then
            echo "Error: Required environment variable $var is not set" >&2
            exit 1
        fi
    done
    echo "Building Custom QGroundControl for Android (${BUILD_TYPE})..."
    "${QT_ROOT_DIR_ARM64}/bin/qt-cmake" -S /project/source -B /project/build -G Ninja \
        -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
        -DQT_HOST_PATH="${QT_HOST_PATH}" \
        -DQT_ANDROID_ABIS="${ANDROID_ABIS}" \
        -DANDROID_SDK_ROOT="${ANDROID_SDK_ROOT}" \
        -DQT_ANDROID_SIGN_APK=OFF \
        -DCUSTOM_BUILD="${CUSTOM_BUILD:-ON}" \
        -DCUSTOM_UI_BUILD="${CUSTOM_UI_BUILD:-ON}" \
        -DQGC_STABLE_BUILD="${QGC_STABLE_BUILD:-ON}"
    cmake --build /project/build --target all --config "${BUILD_TYPE}" --parallel
else
    echo "Building Custom QGroundControl (${BUILD_TYPE})..."

    # CMake設定
    echo "CMakeを設定中..."
    qt-cmake -S /project/source -B /project/build -G Ninja \
        -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
        -DCUSTOM_BUILD="${CUSTOM_BUILD:-ON}" \
        -DCUSTOM_UI_BUILD="${CUSTOM_UI_BUILD:-ON}" \
        -DQGC_STABLE_BUILD="${QGC_STABLE_BUILD:-ON}"

    # ビルド実行
    echo "ビルドを実行中..."
    cmake --build /project/build --target all --parallel

    # インストール
    echo "インストールを実行中..."
    cmake --install /project/build --config "${BUILD_TYPE}"
fi

echo "========================================="
echo "カスタムQGroundControlビルド完了！"
echo "========================================="
echo "ビルドディレクトリ: /project/build"
echo "実行ファイル: /project/build/QGroundControl"

# ビルド結果の確認
if [[ -f "/project/build/QGroundControl" ]]; then
    echo "✅ QGroundControl実行ファイルが正常にビルドされました"
    ls -la /project/build/QGroundControl
else
    echo "❌ QGroundControl実行ファイルが見つかりません"
    echo "ビルドディレクトリの内容:"
    ls -la /project/build/ || echo "ビルドディレクトリを表示できません"
fi

# カスタムプラグインの確認
if [[ -f "/project/build/libCustomUIPlugin.so" ]]; then
    echo "✅ カスタムUIプラグインが正常にビルドされました"
    ls -la /project/build/libCustomUIPlugin.so
elif [[ -f "/project/build/plugins/libCustomUIPlugin.so" ]]; then
    echo "✅ カスタムUIプラグインが正常にビルドされました (pluginsディレクトリ内)"
    ls -la /project/build/plugins/libCustomUIPlugin.so
else
    echo "ℹ️  カスタムUIプラグインファイルは検出されませんでした"
fi

echo "========================================="
