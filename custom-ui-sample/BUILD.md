# QGroundControl カスタムUI ビルドガイド

## 必要条件

### システム要件
- **OS**: Linux (Ubuntu 20.04+推奨)、macOS (10.15+)、Windows 10+
- **Qt**: Qt 5.15.2+ または Qt 6.2+
- **CMake**: 3.16+
- **Compiler**: GCC 9+、Clang 10+、または MSVC 2019+

### 依存関係
```bash
# Ubuntu/Debianの場合
sudo apt-get update
sudo apt-get install \
    qt5-qmake \
    qt5-default \
    qtbase5-dev \
    qtchooser \
    qt5-qmake \
    qtbase5-dev-tools \
    qtdeclarative5-dev \
    qtpositioning5-dev \
    qtlocation5-dev \
    qtquickcontrols2-5-dev \
    qtmultimedia5-dev \
    qml-module-qtquick-controls2 \
    libqt5svg5-dev \
    libqt5serialport5-dev \
    libqt5websockets5-dev \
    libqt5charts5-dev \
    build-essential \
    cmake \
    git

# macOSの場合（Homebrewを使用）
brew install qt@5 cmake
brew link qt@5 --force
```

## ビルド手順

### 1. プロジェクトの準備

QGroundControlのメインプロジェクトから、このカスタムUIサンプルを使用してビルドします。

```bash
# QGroundControlのメインプロジェクトディレクトリに移動
cd /path/to/qgroundcontrol

# カスタムサンプルディレクトリをcustomにリネーム
mv custom-ui-sample custom

# customディレクトリに移動
cd custom
```

### 2. ビルド設定

```bash
# ビルドディレクトリを作成
mkdir build
cd build

# CMakeでプロジェクトを設定
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCUSTOM_BUILD=ON \
    -DCUSTOM_UI_BUILD=ON \
    -DQGC_STABLE_BUILD=ON
```

### 3. ビルド実行

```bash
# メイクファイルを使用してビルド
make -j$(nproc)

# または、CMakeを使用してビルド
cmake --build . --config Release
```

### 4. ビルド結果の確認

ビルドが成功すると、以下のファイルが生成されます：
```
build/
├── QGroundControl（実行ファイル）
├── libCustomUIPlugin.so（プラグインライブラリ）
└── custom_resources.qrc（リソースファイル）
```

## テスト方法

### 1. 基本動作テスト

```bash
# ビルドディレクトリから実行
cd build
./QGroundControl
```

### 2. カスタムUI機能の確認

アプリケーションが起動したら、以下の機能を確認してください：

- **日本語UI**: メニューとラベルが日本語で表示される
- **カスタムカラーテーマ**: 日本の伝統色が適用されている
- **計器パネル**: 日本式の計器パネルが表示される
- **ステータス表示**: 日本語でのステータス表示
- **ナビゲーションバー**: 日本語のナビゲーション

### 3. 機体接続テスト

```bash
# SITLシミュレーターを使用してテスト
# 別ターミナルで以下を実行
gazebo_sitl_px4.sh

# QGroundControlで機体に接続
# 接続後、以下を確認：
# - 機体情報の日本語表示
# - 計器の正常な動作
# - ステータスの更新
```

## トラブルシューティング

### よくある問題と解決方法

#### 1. Qtが見つからないエラー
```bash
# Qt環境変数を設定
export QT_DIR=/usr/lib/qt5
export PATH=$QT_DIR/bin:$PATH
```

#### 2. リソースファイルが読み込まれない
```bash
# custom.qrcファイルの存在を確認
ls -la custom.qrc

# リソースファイルの再コンパイル
rcc -binary custom.qrc -o custom_resources.rcc
```

#### 3. プラグインが読み込まれない
```bash
# プラグインファイルの確認
ldd build/libCustomUIPlugin.so

# 必要なライブラリの確認
export LD_LIBRARY_PATH=$QT_DIR/lib:$LD_LIBRARY_PATH
```

### デバッグビルド

開発時のデバッグには、以下の設定を使用してください：

```bash
cmake .. \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCUSTOM_BUILD=ON \
    -DCUSTOM_UI_BUILD=ON \
    -DQGC_DEBUG_OUTPUT=ON

make -j$(nproc)

# デバッグ実行
gdb ./QGroundControl
```

### ログ出力

カスタムUIの動作を確認するために、ログ出力を有効にします：

```bash
# 環境変数でログレベルを設定
export QT_LOGGING_RULES="CustomUI.*=true"

# QGroundControlを実行
./QGroundControl
```

## パッケージング

### Linux AppImage作成

```bash
# AppImageツールをダウンロード
wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage

# AppImageを作成
./linuxdeploy-x86_64.AppImage \
    --appdir AppDir \
    --executable build/QGroundControl \
    --desktop-file deploy/linux/org.mavlink.qgroundcontrol-custom.desktop \
    --icon-file res/icons/custom_qgroundcontrol.png \
    --output appimage
```

### Windows インストーラー

```bash
# NSISを使用してインストーラーを作成
makensis deploy/windows/QGroundControl-Custom.nsi
```

## CI/CDセットアップ

### GitHub Actionsの例

```yaml
name: Build Custom QGroundControl

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y qt5-default qtdeclarative5-dev
    
    - name: Configure CMake
      run: |
        mkdir build
        cd build
        cmake .. -DCMAKE_BUILD_TYPE=Release -DCUSTOM_BUILD=ON
    
    - name: Build
      run: |
        cd build
        make -j$(nproc)
    
    - name: Test
      run: |
        cd build
        ./QGroundControl --help
```

## 開発のヒント

### カスタマイズポイント

1. **カラーテーマ**: `src/CustomUIPlugin.cc` の `paletteOverride()` メソッド
2. **ウィジェット**: `res/Custom/Widgets/` ディレクトリの QMLファイル
3. **レイアウト**: `src/FlyViewCustomLayer.qml` ファイル
4. **設定**: `src/CustomUIPlugin.cc` の設定関連メソッド

### 新しいウィジェットの追加

1. `res/Custom/Widgets/` に新しい QMLファイルを作成
2. `custom.qrc` にリソースエントリを追加
3. 必要に応じて `CustomUIPlugin.cc` にロジックを追加

## サポート

問題や質問がある場合は、以下のリソースを参照してください：

- [QGroundControl Developer Guide](https://dev.qgroundcontrol.com)
- [Qt Documentation](https://doc.qt.io/)
- [プロジェクトのIssues](https://github.com/your-repo/issues)
