/****************************************************************************
 *
 * (c) 2024 QGroundControl Project Custom UI Sample
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 * フライビューカスタムレイヤー - 日本語対応版
 * 
 * @file
 *   @author Custom UI Team
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlightMap
import QGroundControl.ScreenTools
import QGroundControl.Palette
import QGroundControl.Vehicle

// フライビューに追加される日本語カスタムレイヤー
Item {
    id: root
    
    property var parentToolstrip
    property var vehicle: QGroundControl.multiVehicleManager.activeVehicle
    property bool showAdvancedUI: QGroundControl.settingsManager.appSettings.showAdvancedUI.rawValue
    
    anchors.fill: parent
    
    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    
    // カスタム計器パネル（左上）
    JapaneseInstrumentPanel {
        id: instrumentPanel
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: ScreenTools.defaultFontPixelWidth
        vehicle: root.vehicle
        instrumentSize: 150
        showAdvanced: showAdvancedUI
        
        // パネルの表示/非表示切り替えボタン
        QGCButton {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 5
            width: 30
            height: 30
            text: instrumentPanel.visible ? "−" : "＋"
            onClicked: instrumentPanel.visible = !instrumentPanel.visible
        }
    }
    
    // カスタム飛行ステータス（右上）
    CustomFlightStatus {
        id: flightStatus
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: ScreenTools.defaultFontPixelWidth
        vehicle: root.vehicle
    }
    
    // 緊急時メッセージ表示（中央上部）
    Rectangle {
        id: emergencyMessage
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: ScreenTools.defaultFontPixelWidth
        width: 400
        height: 60
        color: qgcPal.colorRed
        radius: 8
        visible: _hasEmergencyCondition()
        
        // 点滅アニメーション
        SequentialAnimation on opacity {
            running: emergencyMessage.visible
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: 500 }
            NumberAnimation { to: 1.0; duration: 500 }
        }
        
        Column {
            anchors.centerIn: parent
            spacing: 5
            
            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "緊急事態"
                color: "white"
                font.bold: true
                font.pointSize: ScreenTools.largeFontPointSize
            }
            
            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text: _getEmergencyText()
                color: "white"
                font.pointSize: ScreenTools.defaultFontPointSize
            }
        }
    }
    
    // 日本語ミッション進行状況（下部中央）
    Rectangle {
        id: missionProgress
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: ScreenTools.defaultFontPixelWidth * 2
        width: 300
        height: 50
        color: Qt.rgba(qgcPal.window.r, qgcPal.window.g, qgcPal.window.b, 0.8)
        border.color: qgcPal.primaryButton
        border.width: 1
        radius: 8
        visible: vehicle && vehicle.flightMode === "Mission"
        
        Row {
            anchors.centerIn: parent
            spacing: 10
            
            QGCLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: "ミッション進行:"
                color: qgcPal.text
            }
            
            Rectangle {
                width: 150
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                border.color: qgcPal.primaryButton
                border.width: 1
                radius: 10
                
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 1
                    width: _getMissionProgress() * (parent.width - 2)
                    color: qgcPal.primaryButton
                    radius: 8
                }
                
                QGCLabel {
                    anchors.centerIn: parent
                    text: (_getMissionProgress() * 100).toFixed(0) + "%"
                    color: qgcPal.text
                    font.pointSize: ScreenTools.smallFontPointSize
                }
            }
            
            QGCLabel {
                anchors.verticalCenter: parent.verticalCenter
                text: _getCurrentWaypoint() + "/" + _getTotalWaypoints()
                color: qgcPal.text
            }
        }
    }
    
    // 日本語音声アナウンス制御（右下）
    Rectangle {
        id: voiceControl
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: ScreenTools.defaultFontPixelWidth
        width: 120
        height: 80
        color: Qt.rgba(qgcPal.window.r, qgcPal.window.g, qgcPal.window.b, 0.9)
        border.color: qgcPal.windowShade
        border.width: 1
        radius: 8
        
        Column {
            anchors.centerIn: parent
            spacing: 5
            
            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "音声案内"
                color: qgcPal.text
                font.pointSize: ScreenTools.smallFontPointSize
            }
            
            QGCButton {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 80
                height: 25
                text: _voiceEnabled ? "ON" : "OFF"
                property bool _voiceEnabled: true
                onClicked: {
                    _voiceEnabled = !_voiceEnabled
                    // 音声機能の切り替えロジック
                }
            }
            
            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "音量: 80%"
                color: qgcPal.text
                font.pointSize: ScreenTools.tinyFontPointSize
            }
        }
    }
    
    // 風向・風速表示（左下）
    Rectangle {
        id: windInfo
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: ScreenTools.defaultFontPixelWidth
        width: 100
        height: 80
        color: Qt.rgba(qgcPal.window.r, qgcPal.window.g, qgcPal.window.b, 0.9)
        border.color: qgcPal.windowShade
        border.width: 1
        radius: 8
        visible: vehicle && vehicle.wind && vehicle.wind.direction.valid
        
        Column {
            anchors.centerIn: parent
            spacing: 3
            
            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "風向・風速"
                color: qgcPal.text
                font.pointSize: ScreenTools.tinyFontPointSize
            }
            
            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text: _getWindDirection() + "°"
                color: qgcPal.text
                font.bold: true
            }
            
            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text: _getWindSpeed() + " m/s"
                color: _getWindColor()
                font.bold: true
            }
        }
    }
    
    // ヘルパー関数
    function _hasEmergencyCondition() {
        if (!vehicle) return false
        
        // バッテリー残量が極端に少ない
        if (vehicle.battery.percentRemaining.valid && vehicle.battery.percentRemaining.value < 10) return true
        
        // GPSが完全に失われた
        if (vehicle.gps.count.valid && vehicle.gps.count.value < 4) return true
        
        // 電圧が危険レベル
        if (vehicle.battery.voltage.valid && vehicle.battery.voltage.value < 10.5) return true
        
        return false
    }
    
    function _getEmergencyText() {
        if (!vehicle) return ""
        
        var messages = []
        if (vehicle.battery.percentRemaining.valid && vehicle.battery.percentRemaining.value < 10) {
            messages.push("バッテリー切れ間近")
        }
        if (vehicle.gps.count.valid && vehicle.gps.count.value < 4) {
            messages.push("GPS信号消失")
        }
        if (vehicle.battery.voltage.valid && vehicle.battery.voltage.value < 10.5) {
            messages.push("電圧異常低下")
        }
        
        return messages.join(" / ")
    }
    
    function _getMissionProgress() {
        if (!vehicle || !vehicle.missionManager || !vehicle.missionManager.missionItems) return 0
        
        var totalItems = vehicle.missionManager.missionItems.count
        var currentIndex = vehicle.missionManager.currentIndex
        
        if (totalItems === 0) return 0
        return Math.max(0, Math.min(1, currentIndex / totalItems))
    }
    
    function _getCurrentWaypoint() {
        if (!vehicle || !vehicle.missionManager) return "0"
        return vehicle.missionManager.currentIndex.toString()
    }
    
    function _getTotalWaypoints() {
        if (!vehicle || !vehicle.missionManager || !vehicle.missionManager.missionItems) return "0"
        return vehicle.missionManager.missionItems.count.toString()
    }
    
    function _getWindDirection() {
        if (!vehicle || !vehicle.wind || !vehicle.wind.direction.valid) return "---"
        return vehicle.wind.direction.value.toFixed(0)
    }
    
    function _getWindSpeed() {
        if (!vehicle || !vehicle.wind || !vehicle.wind.speed.valid) return "---"
        return vehicle.wind.speed.value.toFixed(1)
    }
    
    function _getWindColor() {
        if (!vehicle || !vehicle.wind || !vehicle.wind.speed.valid) return qgcPal.text
        
        var speed = vehicle.wind.speed.value
        if (speed > 15) return qgcPal.colorRed      // 強風
        if (speed > 10) return qgcPal.colorOrange   // 注意
        if (speed > 5) return qgcPal.colorBlue      // 通常
        return qgcPal.colorGreen                    // 微風
    }
}
