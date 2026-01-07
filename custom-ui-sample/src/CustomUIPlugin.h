/****************************************************************************
 *
 * (c) 2024 QGroundControl Project Custom UI Sample
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 * カスタムUIプラグイン - 日本語対応版
 *
 * @file
 *   @author Custom UI Team
 */

#pragma once

#include "QGCCorePlugin.h"
#include "QmlComponentInfo.h"
#include "QGCOptions.h"
#include "QGCFlyViewOptions.h"
#include "QQmlAbstractUrlInterceptor"

class QQmlApplicationEngine;

// 日本語対応のカスタムフライビューオプション
class JapaneseFlyViewOptions : public QGCFlyViewOptions
{
    Q_OBJECT

public:
    explicit JapaneseFlyViewOptions(QGCOptions* options, QObject* parent = nullptr);

    // 日本語UIに特化したオプション
    bool showInstrumentPanel() const override { return true; }
    bool showMultiVehicleList() const override { return false; }
    bool showMissionAbortedCloseDialog() const override { return true; }
};

// 日本語対応のカスタムオプション
class JapaneseCustomOptions : public QGCOptions
{
    Q_OBJECT

public:
    explicit JapaneseCustomOptions(QObject* parent = nullptr);

    // アプリケーション設定
    QString appDisplayName() const override { return QStringLiteral("QGC Japanese Edition"); }
    QString organizationName() const override { return QStringLiteral("QGC Japanese Team"); }
    QString organizationDomain() const override { return QStringLiteral("qgc-jp.org"); }

    // UIオプション
    QGCFlyViewOptions* flyViewOptions() override { return _flyViewOptions; }
    bool showFirmwareUpgrade() const override { return _showAdvancedUI; }
    bool showSensorCalibrationCompass() const override { return _showAdvancedUI; }
    bool showSensorCalibrationGyro() const override { return _showAdvancedUI; }

    // 上級UIモードの設定
    void setShowAdvancedUI(bool show) { _showAdvancedUI = show; }

private:
    bool _showAdvancedUI = false;
    JapaneseFlyViewOptions* _flyViewOptions = nullptr;
};

// URLインターセプター - カスタムリソースの読み込み
class CustomUIInterceptor : public QQmlAbstractUrlInterceptor
{
public:
    explicit CustomUIInterceptor();
    QUrl intercept(const QUrl &url, DataType type) override;
};

// メインのカスタムUIプラグインクラス
class CustomUIPlugin : public QGCCorePlugin
{
    Q_OBJECT

public:
    explicit CustomUIPlugin(QObject* parent = nullptr);

    // 静的インスタンス取得
    static QGCCorePlugin* instance();

    // プラグイン初期化
    void cleanup() override;

    // QMLエンジン作成
    QQmlApplicationEngine* createQmlApplicationEngine(QObject* parent) override;

    // オプション取得
    QGCOptions* options() override { return _options; }

    // カラーパレットのオーバーライド
    void paletteOverride(const QString& colorName, QGCPalette::PaletteColorInfo_t& colorInfo) override;

    // 設定の可視性制御
    bool overrideSettingsGroupVisibility(const QString& name) override;
    void adjustSettingMetaData(const QString& settingsGroup, FactMetaData& metaData, bool& visible) override;

private slots:
    void _advancedModeChanged(bool advanced);

private:
    void _setupJapaneseColors();
    void _addJapaneseSettings();

    JapaneseCustomOptions* _options = nullptr;
    CustomUIInterceptor* _interceptor = nullptr;
    QQmlApplicationEngine* _qmlEngine = nullptr;
    QVariantList _customSettingsList;
    bool _showAdvancedUI = false;
};
