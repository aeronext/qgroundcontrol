#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 [--fuse] <image-name> [build-type]"
    echo "  --fuse    Enable FUSE support (required for AppImage builds)"
    echo ""
    echo "このスクリプトはカスタムQGroundControlをDockerコンテナ内でビルドします。"
    echo "カスタムUIサンプルが有効になり、日本語UIでビルドされます。"
    exit 1
}

FUSE_FLAGS=()
while [[ $# -gt 0 && "$1" == --* ]]; do
    case "$1" in
        --fuse)
            FUSE_FLAGS=(--cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined)
            shift
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

IMAGE_NAME="${1:-}"
BUILD_TYPE="${2:-Release}"
SOURCE_DIR="${SOURCE_DIR:-$(pwd)}"
BUILD_DIR="${BUILD_DIR:-${SOURCE_DIR}/build}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CUSTOM_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CUSTOM_DIR_NAME="${CUSTOM_DIR_NAME:-$(basename "${CUSTOM_DIR}")}"

[[ -z "${IMAGE_NAME}" ]] && usage

mkdir -p "${BUILD_DIR}"

echo "カスタムQGroundControlのDockerビルドを開始..."
echo "イメージ: ${IMAGE_NAME}"
echo "ビルドタイプ: ${BUILD_TYPE}"
echo "ソースディレクトリ: ${SOURCE_DIR}"
echo "ビルドディレクトリ: ${BUILD_DIR}"
echo "カスタムディレクトリ: ${CUSTOM_DIR}"
echo "カスタムディレクトリ名: ${CUSTOM_DIR_NAME}"

# カスタムディレクトリが存在するかチェック
if [[ ! -d "${CUSTOM_DIR}" ]]; then
    echo "エラー: カスタムディレクトリが見つかりません: ${CUSTOM_DIR}"
    echo "このスクリプトはカスタムディレクトリ内から実行してください。"
    exit 1
fi

docker run \
    --rm \
    ${FUSE_FLAGS[@]+"${FUSE_FLAGS[@]}"} \
    -v "${SOURCE_DIR}:/project/source" \
    -v "${BUILD_DIR}:/project/build" \
    -e "CUSTOM_BUILD=ON" \
    -e "CUSTOM_UI_BUILD=ON" \
    -e "QGC_STABLE_BUILD=ON" \
    -e "CUSTOM_DIR_NAME=${CUSTOM_DIR_NAME}" \
    "${IMAGE_NAME}" \
    "${BUILD_TYPE}"

echo "カスタムビルドが完了しました！"
