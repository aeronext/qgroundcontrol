/****************************************************************************
 *
 * (c) 2024 QGroundControl Project Custom UI Sample
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 * カスタムUIプラグイン - 日本語対応版 実装
 * 
 * @file
 *   @author Custom UI Team
 */

#include "CustomUIPlugin.h"
#include "QGCLoggingCategory.h"
#include "QGCPalette.h"
#include "AppSettings.h"
#include "BrandImageSettings.h"

#include <QtCore/QApplicationStatic>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlFile>
#include <QtCore/QDebug>

QGC_LOGGING_CATEGORY(CustomUILog, "CustomUI.Plugin")

Q_APPLICATION_STATIC(CustomUIPlugin, _customUIPluginInstance);

// JapaneseFlyViewOptions 実装
JapaneseFlyViewOptions::JapaneseFlyViewOptions(QGCOptions* options, QObject* parent)
    : QGCFlyViewOptions(options, parent)
{
    qCDebug(CustomUILog) << "日本語フライビューオプション初期化";
}

// JapaneseCustomOptions 実装
JapaneseCustomOptions::JapaneseCustomOptions(QObject* parent)
    : QGCOptions(parent)
    , _flyViewOptions(new JapaneseFlyViewOptions(this, this))
{
    qCDebug(CustomUILog) << "日本語カスタムオプション初期化";
}

// CustomUIInterceptor 実装
CustomUIInterceptor::CustomUIInterceptor()
    : QQmlAbstractUrlInterceptor()
{
    qCDebug(CustomUILog) << "カスタムUIインターセプター初期化";
}

QUrl CustomUIInterceptor::intercept(const QUrl &url, DataType type)
{
    if (type == DataType::QmlFile || type == DataType::UrlString) {
        if (url.scheme() == QStringLiteral("qrc")) {
            const QString origPath = url.path();
            const QString overridePath = QStringLiteral(":/Custom%1").arg(origPath);
            
            if (QFile::exists(overridePath)) {
                QUrl result;
                result.setScheme(QStringLiteral("qrc"));
                result.setPath(overridePath.mid(1));
                qCDebug(CustomUILog) << "カスタムファイル使用:" << origPath << "=>" << overridePath;
                return result;
            }
        }
    }
    return url;
}

// CustomUIPlugin 実装
CustomUIPlugin::CustomUIPlugin(QObject* parent)
    : QGCCorePlugin(parent)
    , _options(new JapaneseCustomOptions(this))
{
    qCDebug(CustomUILog) << "カスタムUIプラグイン初期化開始";
    
    _showAdvancedUI = false;
    connect(this, &QGCCorePlugin::showAdvancedUIChanged, this, &CustomUIPlugin::_advancedModeChanged);
    
    _setupJapaneseColors();
    _addJapaneseSettings();
    
    qCDebug(CustomUILog) << "カスタムUIプラグイン初期化完了";
}

QGCCorePlugin* CustomUIPlugin::instance()
{
    return _customUIPluginInstance();
}

void CustomUIPlugin::cleanup()
{
    if (_qmlEngine) {
        _qmlEngine->removeUrlInterceptor(_interceptor);
    }
    
    delete _interceptor;
    _interceptor = nullptr;
    
    qCDebug(CustomUILog) << "カスタムUIプラグインクリーンアップ完了";
}

QQmlApplicationEngine* CustomUIPlugin::createQmlApplicationEngine(QObject* parent)
{
    _qmlEngine = QGCCorePlugin::createQmlApplicationEngine(parent);
    
    // カスタムウィジェットパスを追加
    _qmlEngine->addImportPath("qrc:/qml/Custom/Widgets");
    
    // URLインターセプターを設定
    _interceptor = new CustomUIInterceptor();
    _qmlEngine->addUrlInterceptor(_interceptor);
    
    qCDebug(CustomUILog) << "QMLエンジン初期化完了";
    return _qmlEngine;
}

void CustomUIPlugin::paletteOverride(const QString& colorName, QGCPalette::PaletteColorInfo_t& colorInfo)
{
    // 日本の伝統色を基調としたカラーパレット
    if (colorName == QStringLiteral("window")) {
        // 墨色（すみいろ）ベース
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupEnabled]   = QColor("#1a1a1a");
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupDisabled]  = QColor("#1a1a1a");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupEnabled]  = QColor("#f5f5f5");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupDisabled] = QColor("#f0f0f0");
    } else if (colorName == QStringLiteral("primaryButton")) {
        // 藍色（あいいろ）
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupEnabled]   = QColor("#165e83");
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupDisabled]  = QColor("#2d3142");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupEnabled]  = QColor("#4f9ada");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupDisabled] = QColor("#9ca3af");
    } else if (colorName == QStringLiteral("buttonHighlight")) {
        // 桜色（さくらいろ）
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupEnabled]   = QColor("#d4728b");
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupDisabled]  = QColor("#4a4a4a");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupEnabled]  = QColor("#ffb3ba");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupDisabled] = QColor("#e4e4e4");
    } else if (colorName == QStringLiteral("colorGreen")) {
        // 若葉色（わかばいろ）
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupEnabled]   = QColor("#7cb342");
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupDisabled]  = QColor("#5a7c35");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupEnabled]  = QColor("#8bc34a");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupDisabled] = QColor("#a5d469");
    } else if (colorName == QStringLiteral("colorOrange")) {
        // 朱色（しゅいろ）
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupEnabled]   = QColor("#e65100");
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupDisabled]  = QColor("#bf360c");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupEnabled]  = QColor("#ff9800");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupDisabled] = QColor("#ffcc80");
    }
}

bool CustomUIPlugin::overrideSettingsGroupVisibility(const QString& name)
{
    // ブランドイメージ設定を非表示（独自ブランディング）
    if (name == BrandImageSettings::name) {
        return false;
    }
    
    // 高度な設定は上級モードでのみ表示
    if (name == QStringLiteral("Advanced") && !_showAdvancedUI) {
        return false;
    }
    
    return true;
}

void CustomUIPlugin::adjustSettingMetaData(const QString& settingsGroup, FactMetaData& metaData, bool& visible)
{
    QGCCorePlugin::adjustSettingMetaData(settingsGroup, metaData, visible);
    
    if (settingsGroup == AppSettings::settingsGroup) {
        // 日本向けデフォルト設定
        if (metaData.name() == AppSettings::offlineEditingFirmwareClassName) {
            metaData.setRawDefaultValue(QGCMAVLink::FirmwareClassPX4);
            visible = _showAdvancedUI; // 上級モードでのみ表示
        } else if (metaData.name() == AppSettings::offlineEditingVehicleClassName) {
            metaData.setRawDefaultValue(QGCMAVLink::VehicleClassMultiRotor);
            visible = _showAdvancedUI; // 上級モードでのみ表示
        }
    }
}

void CustomUIPlugin::_advancedModeChanged(bool advanced)
{
    qCDebug(CustomUILog) << "上級モード変更:" << advanced;
    _options->_showAdvancedUI = advanced;
}

void CustomUIPlugin::_setupJapaneseColors()
{
    // 日本の伝統色の定義
    qCDebug(CustomUILog) << "日本の伝統色パレット設定";
}

void CustomUIPlugin::_addJapaneseSettings()
{
    // 日本語設定項目の追加
    qCDebug(CustomUILog) << "日本語設定項目追加";
}

// MOCファイル用
#include "CustomUIPlugin.moc"
