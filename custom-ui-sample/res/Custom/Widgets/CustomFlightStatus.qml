/****************************************************************************
 *
 * (c) 2024 QGroundControl Project Custom UI Sample
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 * 日本式飛行ステータス表示
 * 
 * @file
 *   @author Custom UI Team
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools

Rectangle {
    id: root
    
    property var vehicle: null
    
    // 機体状態のプロパティ
    readonly property string _flightMode:   vehicle ? vehicle.flightMode : "未接続"
    readonly property bool   _armed:        vehicle ? vehicle.armed : false
    readonly property real   _batteryVolt:  vehicle && vehicle.battery.voltage.valid ? vehicle.battery.voltage.value : 0
    readonly property int    _batteryPercent: vehicle && vehicle.battery.percentRemaining.valid ? vehicle.battery.percentRemaining.value : -1
    readonly property bool   _gpsLock:      vehicle && vehicle.gps.count.valid ? vehicle.gps.count.value >= 6 : false
    readonly property int    _satCount:     vehicle && vehicle.gps.count.valid ? vehicle.gps.count.value : 0
    readonly property string _connectionStatus: vehicle ? "接続済み" : "切断"
    
    width: 320
    height: 120
    color: qgcPal.window
    border.color: _armed ? qgcPal.colorOrange : qgcPal.windowShade
    border.width: _armed ? 2 : 1
    radius: 8
    
    // 点滅アニメーション（アーム時）
    SequentialAnimation on opacity {
        running: _armed
        loops: Animation.Infinite
        NumberAnimation { to: 0.7; duration: 1000; easing.type: Easing.InOutQuad }
        NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
    }
    
    GridLayout {
        anchors.fill: parent
        anchors.margins: 10
        columns: 4
        rowSpacing: 5
        columnSpacing: 10
        
        // 接続状態
        Rectangle {
            Layout.preferredWidth: 70
            Layout.preferredHeight: 25
            color: vehicle ? qgcPal.colorGreen : qgcPal.colorRed
            radius: 12
            
            QGCLabel {
                anchors.centerIn: parent
                text: _connectionStatus
                color: "white"
                font.bold: true
                font.pointSize: ScreenTools.smallFontPointSize
            }
        }
        
        // フライトモード
        Rectangle {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 25
            color: _armed ? qgcPal.colorOrange : qgcPal.colorBlue
            radius: 4
            
            QGCLabel {
                anchors.centerIn: parent
                text: _flightMode
                color: "white"
                font.bold: true
                font.pointSize: ScreenTools.smallFontPointSize
            }
        }
        
        // アーム状態
        Rectangle {
            Layout.preferredWidth: 70
            Layout.preferredHeight: 25
            color: _armed ? qgcPal.colorRed : qgcPal.colorGrey
            radius: 4
            
            QGCLabel {
                anchors.centerIn: parent
                text: _armed ? "武装" : "安全"
                color: "white"
                font.bold: true
                font.pointSize: ScreenTools.smallFontPointSize
            }
        }
        
        // GPS状態
        Row {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 25
            spacing: 5
            
            Image {
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/qmlimages/Gps.svg"
                fillMode: Image.PreserveAspectFit
                opacity: _gpsLock ? 1.0 : 0.5
            }
            
            QGCLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: _satCount + "基"
                color: _gpsLock ? qgcPal.colorGreen : qgcPal.colorRed
                font.bold: true
                font.pointSize: ScreenTools.smallFontPointSize
            }
        }
        
        // バッテリー電圧
        Row {
            Layout.columnSpan: 2
            Layout.preferredHeight: 25
            spacing: 5
            
            QGCLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: "電圧:"
                color: qgcPal.text
                font.pointSize: ScreenTools.smallFontPointSize
            }
            
            QGCLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: _batteryVolt > 0 ? _batteryVolt.toFixed(2) + "V" : "---"
                color: _getBatteryColor()
                font.bold: true
                font.pointSize: ScreenTools.smallFontPointSize
            }
        }
        
        // バッテリー残量
        Row {
            Layout.columnSpan: 2
            Layout.preferredHeight: 25
            spacing: 5
            
            QGCLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: "残量:"
                color: qgcPal.text
                font.pointSize: ScreenTools.smallFontPointSize
            }
            
            Rectangle {
                width: 60
                height: 15
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                border.color: qgcPal.text
                border.width: 1
                radius: 2
                
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 1
                    width: _batteryPercent >= 0 ? (parent.width - 2) * (_batteryPercent / 100) : 0
                    color: _getBatteryColor()
                    radius: 1
                }
                
                QGCLabel {
                    anchors.centerIn: parent
                    text: _batteryPercent >= 0 ? _batteryPercent + "%" : "---"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.tinyFontPointSize
                }
            }
        }
        
        // 警告メッセージエリア
        Rectangle {
            Layout.columnSpan: 4
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: _getWarningColor()
            radius: 4
            visible: _hasWarnings()
            
            QGCLabel {
                anchors.centerIn: parent
                text: _getWarningText()
                color: "white"
                font.bold: true
                font.pointSize: ScreenTools.smallFontPointSize
            }
        }
    }
    
    // バッテリー状態に応じた色を取得
    function _getBatteryColor() {
        if (_batteryPercent < 0) return qgcPal.colorGrey
        if (_batteryPercent < 20) return qgcPal.colorRed
        if (_batteryPercent < 40) return qgcPal.colorOrange
        return qgcPal.colorGreen
    }
    
    // 警告状態を確認
    function _hasWarnings() {
        if (!vehicle) return false
        if (_batteryPercent >= 0 && _batteryPercent < 20) return true
        if (!_gpsLock) return true
        if (_batteryVolt > 0 && _batteryVolt < 11.0) return true
        return false
    }
    
    // 警告メッセージを取得
    function _getWarningText() {
        if (!vehicle) return ""
        
        var warnings = []
        if (_batteryPercent >= 0 && _batteryPercent < 20) {
            warnings.push("バッテリー残量低下")
        }
        if (!_gpsLock) {
            warnings.push("GPS信号不良")
        }
        if (_batteryVolt > 0 && _batteryVolt < 11.0) {
            warnings.push("電圧低下")
        }
        
        return warnings.join(" / ")
    }
    
    // 警告色を取得
    function _getWarningColor() {
        if (!_hasWarnings()) return "transparent"
        if (_batteryPercent >= 0 && _batteryPercent < 10) return qgcPal.colorRed
        return qgcPal.colorOrange
    }
}
