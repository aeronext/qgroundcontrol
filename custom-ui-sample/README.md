# QGroundControl カスタムUIサンプル

## 概要

このサンプルはQGroundControlの日本語対応カスタムUIの実装例です。

## 主な特徴

- **日本語UI**: 日本語のラベルとメッセージ
- **モダンなデザイン**: フラットデザインとマテリアルカラー
- **カスタムウィジェット**: 
  - 日本式飛行計器パネル
  - カスタムナビゲーションバー
  - 改良されたステータス表示
- **テーマ**: ダーク/ライトモードに対応したカラーパレット

## ビルド方法

1. このディレクトリを `custom` にリネーム:
   ```bash
   mv custom-ui-sample custom
   ```

2. customディレクトリに移動:
   ```bash
   cd custom
   ```

3. QGroundControlをビルド:
   ```bash
   cmake --build build --config Release
   ```

## カスタマイズ内容

### 1. UIウィジェット
- `JapaneseInstrumentPanel.qml` - 日本式計器パネル
- `CustomFlightStatus.qml` - 飛行ステータス表示
- `JapaneseNavigationBar.qml` - ナビゲーションバー

### 2. カラーテーマ
- 日本の伝統色を基調としたカラーパレット
- 視認性を重視したコントラスト設定

### 3. レイアウト
- 日本のパイロットに親しみやすいレイアウト
- 重要情報の優先表示

## フォルダ構成

```
custom-ui-sample/
├── CMakeLists.txt
├── custom.qrc
├── res/
│   ├── Custom/
│   │   └── Widgets/
│   │       ├── JapaneseInstrumentPanel.qml
│   │       ├── CustomFlightStatus.qml
│   │       └── JapaneseNavigationBar.qml
│   ├── Images/
│   │   └── [カスタムアイコン]
│   └── icons/
└── src/
    ├── CustomUIPlugin.cc
    ├── CustomUIPlugin.h
    └── FlyViewCustomLayer.qml
```

## ライセンス

QGroundControl Project ライセンスに準拠
