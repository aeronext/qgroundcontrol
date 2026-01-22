#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CUSTOM_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SOURCE_DIR="$(cd "${CUSTOM_DIR}/.." && pwd)"
IMAGE_NAME="qgc-ubuntu-docker-custom"
BUILD_TYPE="${1:-Release}"

echo "カスタムQGroundControlのDockerビルドを開始します..."
echo "カスタムディレクトリ: ${CUSTOM_DIR}"
echo "ソースディレクトリ: ${SOURCE_DIR}"
echo "ビルドタイプ: ${BUILD_TYPE}"

# カスタムビルド用のDockerイメージを作成
docker build \
  --file "${SCRIPT_DIR}/Dockerfile-build-ubuntu-custom" \
  -t "${IMAGE_NAME}" \
  "${SOURCE_DIR}"

echo "Dockerコンテナでカスタムビルドを実行します..."

# カスタムビルド用の環境変数を設定
export CUSTOM_BUILD=ON
export CUSTOM_UI_BUILD=ON
export CUSTOM_DIR_NAME="$(basename "${CUSTOM_DIR}")"

SOURCE_DIR="${SOURCE_DIR}" "${SCRIPT_DIR}/docker-run-custom.sh" --fuse "${IMAGE_NAME}" "${BUILD_TYPE}"

echo "カスタムQGroundControlのビルドが完了しました！"
echo "ビルド結果: ${SOURCE_DIR}/build"
echo "実行ファイル: ${SOURCE_DIR}/build/QGroundControl"
