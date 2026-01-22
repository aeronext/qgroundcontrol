# MAVLinkカメラストリームURI受信時の自動表示機能修正プラン

## 問題の概要

MAVLinkのカメラストリームURIを受け取った際に、QGC 4.4.5ではストリームの表示UIに自動的に遷移していたが、現在のバージョンでは遷移しなくなっている。再起動した際には設定が残っているため表示される。

## 調査結果

### v4.4.5の動作

```cpp
// VideoManager::_setActiveVehicle() in v4.4.5
connect(_activeVehicle->cameraManager(), &QGCCameraManager::streamChanged,
        this, &VideoManager::_restartAllVideos);
// ...
emit autoStreamConfiguredChanged();
_restartAllVideos();
```

v4.4.5では、`streamChanged`シグナルが直接`_restartAllVideos()`に接続されていた。

### 現在のコードの動作

```cpp
// VideoManager::_setActiveVehicle() in current version
connect(_activeVehicle->cameraManager(), &QGCCameraManager::streamChanged,
        this, &VideoManager::_videoSourceChanged);
```

現在は`streamChanged`シグナルが`_videoSourceChanged()`に接続されている。

### 問題点

`VideoManager::_initVideoReceiver()`内の`videoStreamInfoChanged`シグナルハンドラで、`_updateAutoStream()`が呼ばれているが、**その戻り値が無視されている**：

```cpp
(void) connect(receiver, &VideoReceiver::videoStreamInfoChanged, this, [this, receiver]() {
    const QGCVideoStreamInfo *videoStreamInfo = receiver->videoStreamInfo();
    qCDebug(VideoManagerLog) << "Video" << receiver->name() << "stream info:"
                             << (videoStreamInfo ? "received" : "lost");
    (void) _updateAutoStream(receiver);  // ← 戻り値が無視されている
});
```

ストリーム情報が受信された際に`autoStreamConfiguredChanged`シグナルは発行されるが、**ビデオストリームの再起動処理が欠けている**ため、リアルタイムでのUI更新・ストリーム表示開始が行われない。

## データフロー分析

### 正常に動作すべきフロー

1. `VehicleCameraControl::handleVideoInfo()` - VIDEO_STREAM_INFORMATION メッセージを受信
2. `QGCCameraManager::_handleVideoStreamInfo()` - `emit streamChanged()` を発行
3. `VideoManager::_videoSourceChanged()` - ストリーム設定を更新
4. **欠けている処理**: ビデオストリームの再起動

### 再起動後に動作する理由

1. `VideoSettings`（`rtspUrl`など）に設定が保存されている
2. 起動時に`_updateSettings()`で読み込まれる
3. `hasVideo()`がtrueになるため、`_startReceiver()`でビデオが開始される

## 修正プラン

### 修正箇所

**ファイル**: `src/VideoManager/VideoManager.cc`

**関数**: `VideoManager::_initVideoReceiver()`

### 修正内容

`videoStreamInfoChanged`シグナルハンドラを修正し、ストリーム情報が受信された際にビデオを再起動する：

#### Before (現在のコード)

```cpp
(void) connect(receiver, &VideoReceiver::videoStreamInfoChanged, this, [this, receiver]() {
    const QGCVideoStreamInfo *videoStreamInfo = receiver->videoStreamInfo();
    qCDebug(VideoManagerLog) << "Video" << receiver->name() << "stream info:"
                             << (videoStreamInfo ? "received" : "lost");

    (void) _updateAutoStream(receiver);
});
```

#### After (修正後のコード)

```cpp
(void) connect(receiver, &VideoReceiver::videoStreamInfoChanged, this, [this, receiver]() {
    const QGCVideoStreamInfo *videoStreamInfo = receiver->videoStreamInfo();
    qCDebug(VideoManagerLog) << "Video" << receiver->name() << "stream info:"
                             << (videoStreamInfo ? "received" : "lost");

    if (_updateAutoStream(receiver)) {
        // ストリーム設定が変更された場合、ビデオを再起動
        if (hasVideo()) {
            _restartVideo(receiver);
        }
    }
});
```

## 影響範囲

- この修正は最小限の変更で、ストリーム情報受信時のビデオ再起動ロジックを追加するだけ
- 既存の動作に影響を与えない（設定が変更された場合のみ再起動）
- テストでは、MAVLink経由でのVIDEO_STREAM_INFORMATION受信時の動作を確認する必要がある

## 関連ファイル

- `src/VideoManager/VideoManager.cc` - 修正対象
- `src/VideoManager/VideoManager.h` - 参照用
- `src/Camera/QGCCameraManager.cc` - streamChangedシグナル発行元
- `src/Camera/VehicleCameraControl.cc` - handleVideoInfo()でストリーム情報を処理
- `src/FlyView/FlyViewVideo.qml` - ビデオ表示UI（isStreamSourceプロパティで表示制御）

## テスト方法

1. QGCを起動し、MAVLinkカメラストリームをサポートするドローン/シミュレーターに接続
2. ドローンからVIDEO_STREAM_INFORMATIONメッセージが送信されることを確認
3. FlyViewでビデオストリームが自動的に表示されることを確認
4. 複数回接続/切断を繰り返し、動作の安定性を確認
