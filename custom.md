# QGroundControl カスタムビルドガイド

## 概要

このガイドでは、QGroundControlのカスタムビルドをDockerを使用して行う方法を説明します。カスタムビルドでは、日本語UIと専用のカスタムウィジェットを含む独自版のQGroundControlを作成できます。

## 前提条件

### システム要件
- **Docker**: Docker Engine 20.10+
- **OS**: Linux (Ubuntu 20.04+推奨)、macOS、Windows 10+
- **メモリ**: 最低8GB、推奨16GB
- **ディスク**: 最低10GB、推奨20GB

### Dockerのインストール
```bash
# Ubuntu/Debianの場合
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo usermod -aG docker $USER

# ログアウトして再ログインするか、以下を実行
newgrp docker

# インストール確認
docker --version
```

## カスタムビルドの準備

### 1. カスタムディレクトリの準備

カスタムビルドを行う前に、`custom-ui-sample`を`custom`にリネームしてください：

```bash
# QGroundControlのメインディレクトリにて
mv custom-ui-sample custom
```

### 2. カスタムディレクトリの構成確認

```bash
# カスタムディレクトリの構成を確認
ls -la custom/
```

以下のようなファイル構成になっているはずです：
```
custom/
├── CMakeLists.txt
├── custom.qrc
├── README.md
├── BUILD.md
├── cmake/
│   └── CustomOverrides.cmake
├── res/
│   └── Custom/
│       └── Widgets/
│           ├── JapaneseInstrumentPanel.qml
│           └── JapaneseNavigationBar.qml
└── src/
    ├── CustomUIPlugin.h
    ├── CustomUIPlugin.cc
    └── FlyViewCustomLayer.qml
```

## Dockerを使用したカスタムビルド

### 1. 基本的なカスタムビルド実行

```bash
# カスタムビルドスクリプトを実行
bash deploy/docker/run-docker-ubuntu-custom.sh

# 特定のビルドタイプを指定する場合
bash deploy/docker/run-docker-ubuntu-custom.sh Debug      # デバッグビルド
bash deploy/docker/run-docker-ubuntu-custom.sh Release    # リリースビルド（デフォルト）
```

### 2. ビルドプロセスの詳細

ビルドプロセスは以下の手順で実行されます：

1. **Dockerイメージの作成**
   - Ubuntu 24.04ベースイメージ
   - Qt開発環境のセットアップ
   - カスタムビルド用の環境変数設定

2. **ソースコードの準備**
   - `custom-ui-sample` → `custom` の自動リネーム
   - カスタムビルドフラグの設定

3. **CMake設定とビルド**
   - カスタムビルドオプション有効化
   - 日本語UIサポート有効化
   - 並列ビルド実行

4. **ビルド結果の確認**
   - 実行ファイルの生成確認
   - カスタムプラグインの生成確認

### 3. ビルドオプション

以下の環境変数でビルド動作をカスタマイズできます：

| 環境変数 | デフォルト値 | 説明 |
|----------|-------------|------|
| `CUSTOM_BUILD` | ON | カスタムビルドを有効化 |
| `CUSTOM_UI_BUILD` | ON | カスタムUIビルドを有効化 |
| `QGC_STABLE_BUILD` | ON | 安定版ビルドフラグ |

```bash
# 環境変数を変更してビルド
CUSTOM_BUILD=OFF bash deploy/docker/run-docker-ubuntu-custom.sh
```

## ビルド結果の確認

### 1. ビルドファイルの場所

ビルド完了後、以下の場所にファイルが生成されます：

```bash
build/
├── QGroundControl              # メイン実行ファイル
├── libCustomUIPlugin.so        # カスタムUIプラグイン（Linuxの場合）
├── plugins/                    # プラグインディレクトリ
└── [その他ビルド成果物]
```

### 2. ビルド成果物の確認

```bash
# 実行ファイルの確認
ls -la build/QGroundControl

# プラグインの確認
find build/ -name "*CustomUI*" -type f

# ビルドディレクトリ全体の確認
du -sh build/
```

### 3. 実行テスト

```bash
# ビルドされたQGroundControlを実行
cd build
./QGroundControl

# またはフルパス指定
/path/to/qgroundcontrol/build/QGroundControl
```

## カスタムビルドの特徴

### 1. 日本語UI対応
- メニューとラベルの日本語化
- 日本語フォントサポート
- 日本の航空慣例に配慮したUI配置

### 2. カスタムウィジェット
- **日本式計器パネル**: 日本のパイロットに馴染みやすい計器レイアウト
- **カスタムナビゲーションバー**: 日本語ラベル付きナビゲーション
- **改良されたステータス表示**: 重要情報の日本語表示

### 3. カスタムテーマ
- 日本の伝統色を基調としたカラーパレット
- 視認性を重視したコントラスト設定
- ダーク/ライトモード対応

## トラブルシューティング

### よくある問題と解決方法

#### 1. Dockerビルドが失敗する

**問題**: Dockerイメージのビルドでエラーが発生
```bash
# 解決方法1: Dockerキャッシュをクリア
docker system prune -a

# 解決方法2: ビルドを再実行
bash deploy/docker/run-docker-ubuntu-custom.sh
```

#### 2. カスタムディレクトリが見つからない

**問題**: `custom ディレクトリが見つかりません` エラー
```bash
# 解決方法: カスタムディレクトリの確認と作成
ls -la custom-ui-sample/
mv custom-ui-sample custom
```

#### 3. ビルド中にメモリ不足

**問題**: ビルドプロセスでメモリエラー
```bash
# 解決方法1: 並列度を下げる
# entrypoint-custom.shを編集して --parallel の代わりに -j2 を指定

# 解決方法2: Dockerのメモリ制限を増やす
docker run --memory=8g ...
```

#### 4. 実行ファイルが作成されない

**問題**: ビルド完了後に QGroundControl実行ファイルがない
```bash
# 診断コマンド
find build/ -name "QGroundControl" -type f
find build/ -name "*.so" | grep -i custom

# ログの確認
docker logs <container-id>
```

### デバッグビルド

問題の詳細調査には、デバッグビルドを使用してください：

```bash
# デバッグビルドの実行
bash deploy/docker/run-docker-ubuntu-custom.sh Debug

# ビルドログの詳細表示
VERBOSE=1 bash deploy/docker/run-docker-ubuntu-custom.sh Debug
```

### ログ出力の有効化

```bash
# ビルドプロセスの詳細ログ
export CMAKE_VERBOSE_MAKEFILE=1
bash deploy/docker/run-docker-ubuntu-custom.sh

# Qt関連のログ
export QT_LOGGING_RULES="*.debug=true"
./build/QGroundControl
```

## 高度な設定

### 1. カスタムビルドオプション

`custom/cmake/CustomOverrides.cmake` ファイルを編集して、追加のビルドオプションを設定できます：

```cmake
# カスタムビルドオプションの例
set(CUSTOM_FEATURE_A ON)
set(CUSTOM_FEATURE_B OFF)
set(CUSTOM_THEME_COLOR "#FF5722")
```

### 2. 追加のカスタマイズ

新しいカスタムウィジェットを追加する場合：

1. `custom/res/Custom/Widgets/` に新しいQMLファイルを作成
2. `custom/custom.qrc` にリソースエントリを追加
3. `custom/src/CustomUIPlugin.cc` に必要なロジックを実装

### 3. CI/CD統合

GitHub Actionsでの自動ビルド例：

```yaml
name: Custom QGroundControl Build

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Prepare custom build
      run: mv custom-ui-sample custom

    - name: Build custom QGroundControl
      run: bash deploy/docker/run-docker-ubuntu-custom.sh

    - name: Test build result
      run: |
        test -f build/QGroundControl
        ./build/QGroundControl --version
```

## パフォーマンス最適化

### 1. 並列ビルドの最適化

```bash
# CPUコア数に応じた並列度調整
nproc  # 利用可能コア数を確認

# entrypoint-custom.sh内で並列度を調整
cmake --build /project/build --target all --parallel $(nproc)
```

### 2. キャッシュの利用

```bash
# ccacheを有効化（高速再ビルド）
export CMAKE_CXX_COMPILER_LAUNCHER=ccache
bash deploy/docker/run-docker-ubuntu-custom.sh
```

### 3. リソース監視

```bash
# ビルド中のリソース使用状況監視
docker stats
htop  # または top
```

## 次のステップ

### 1. カスタムウィジェットの開発

- [Qt QML ドキュメント](https://doc.qt.io/qt-6/qtqml-index.html)
- [QGroundControl開発者ガイド](https://dev.qgroundcontrol.com)

### 2. パッケージング

```bash
# AppImage作成（Linux）
bash deploy/linux/create_appimage.sh build/QGroundControl

# Windows インストーラー作成
# Windows環境でNSIS使用
```

### 3. 配布とデプロイ

- バイナリの配布準備
- 更新メカニズムの設定
- ユーザー向けドキュメント作成

## サポートとコミュニティ

- **公式ドキュメント**: [QGroundControl Documentation](https://docs.qgroundcontrol.com)
- **開発者リソース**: [QGroundControl Developer Guide](https://dev.qgroundcontrol.com)
- **コミュニティフォーラム**: [QGroundControl Gitter](https://gitter.im/mavlink/qgroundcontrol)

## ライセンス

このカスタムビルドは、QGroundControl Projectのライセンス条項に従います。詳細については、プロジェクトルートの`LICENSE`ファイルを参照してください。
