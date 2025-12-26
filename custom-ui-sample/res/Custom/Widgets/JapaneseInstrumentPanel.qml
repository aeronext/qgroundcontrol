/****************************************************************************
 *
 * (c) 2024 QGroundControl Project Custom UI Sample
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 * 日本式計器パネル
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
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    property var    vehicle:            null
    property real   instrumentSize:     200
    property bool   showAdvanced:       false
    
    // 機体情報のプロパティ
    readonly property real _roll:       vehicle ? vehicle.roll.rawValue : 0
    readonly property real _pitch:      vehicle ? vehicle.pitch.rawValue : 0
    readonly property real _heading:    vehicle ? vehicle.heading.rawValue : 0
    readonly property real _altitude:   vehicle ? vehicle.altitudeRelative.rawValue : 0
    readonly property real _groundSpeed: vehicle ? vehicle.groundSpeed.rawValue : 0
    readonly property real _airSpeed:   vehicle ? vehicle.airSpeed.rawValue : 0
    readonly property real _climbRate:  vehicle ? vehicle.climbRate.rawValue : 0
    
    width: instrumentSize * 2.5
    height: instrumentSize * 1.5
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: qgcPal.window
        border.color: qgcPal.windowShade
        border.width: 1
        radius: 8
        
        // 背景のグラデーション効果
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.lighter(qgcPal.window, 1.1) }
            GradientStop { position: 1.0; color: Qt.darker(qgcPal.window, 1.1) }
        }
    }
    
    // タイトルバー
    Rectangle {
        id: titleBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        color: qgcPal.primaryButton
        radius: 8
        
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.radius
            color: parent.color
        }
        
        QGCLabel {
            anchors.centerIn: parent
            text: "飛行計器パネル"
            color: qgcPal.primaryButtonText
            font.bold: true
            font.pointSize: ScreenTools.defaultFontPointSize * 1.2
        }
    }
    
    GridLayout {
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        columns: 3
        rowSpacing: 10
        columnSpacing: 10
        
        // 人工地平線
        Item {
            Layout.rowSpan: 2
            Layout.preferredWidth: instrumentSize
            Layout.preferredHeight: instrumentSize
            
            JapaneseArtificialHorizon {
                anchors.fill: parent
                rollAngle: _roll
                pitchAngle: _pitch
                heading: _heading
            }
            
            QGCLabel {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 5
                text: "人工地平線"
                color: qgcPal.text
                font.pointSize: ScreenTools.smallFontPointSize
            }
        }
        
        // 高度計
        JapaneseAltimeter {
            Layout.preferredWidth: instrumentSize * 0.8
            Layout.preferredHeight: instrumentSize * 0.8
            altitude: _altitude
            climbRate: _climbRate
        }
        
        // 速度計
        JapaneseSpeedIndicator {
            Layout.preferredWidth: instrumentSize * 0.8
            Layout.preferredHeight: instrumentSize * 0.8
            groundSpeed: _groundSpeed
            airSpeed: _airSpeed
        }
        
        // 方位計
        JapaneseCompass {
            Layout.preferredWidth: instrumentSize * 0.8
            Layout.preferredHeight: instrumentSize * 0.8
            heading: _heading
        }
        
        // ステータス表示
        JapaneseFlightStatus {
            Layout.columnSpan: 2
            Layout.preferredWidth: instrumentSize * 1.6
            Layout.preferredHeight: instrumentSize * 0.4
            vehicle: root.vehicle
        }
    }
}

// 日本式人工地平線コンポーネント
Item {
    id: japaneseArtificialHorizon
    
    property real rollAngle: 0
    property real pitchAngle: 0
    property real heading: 0
    
    clip: true
    
    // 地平線背景
    Item {
        id: horizon
        width: parent.width * 3
        height: parent.height * 3
        anchors.centerIn: parent
        
        Rectangle {
            id: sky
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#87CEEB" }
                GradientStop { position: 0.5; color: "#4169E1" }
            }
        }
        
        Rectangle {
            id: ground
            height: parent.height / 2
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#8B4513" }
                GradientStop { position: 1.0; color: "#228B22" }
            }
        }
        
        // 地平線
        Rectangle {
            width: parent.width
            height: 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
        }
        
        transform: [
            Translate { y: -pitchAngle * 2 },
            Rotation { 
                origin.x: horizon.width / 2
                origin.y: horizon.height / 2
                angle: -rollAngle 
            }
        ]
    }
    
    // 機体シンボル
    Canvas {
        id: aircraftSymbol
        anchors.centerIn: parent
        width: parent.width * 0.3
        height: parent.height * 0.15
        
        onPaint: {
            var ctx = getContext("2d");
            ctx.strokeStyle = "white";
            ctx.lineWidth = 3;
            ctx.beginPath();
            
            // 機体の翼を表現
            ctx.moveTo(0, height/2);
            ctx.lineTo(width/3, height/2);
            ctx.moveTo(width*2/3, height/2);
            ctx.lineTo(width, height/2);
            
            // 中央の機体シンボル
            ctx.moveTo(width/2 - 10, height/2);
            ctx.lineTo(width/2 + 10, height/2);
            ctx.moveTo(width/2, height/2 - 5);
            ctx.lineTo(width/2, height/2 + 5);
            
            ctx.stroke();
        }
    }
    
    // 方位表示
    QGCLabel {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
        text: heading.toFixed(0) + "°"
        color: "white"
        font.bold: true
        
        Rectangle {
            anchors.centerIn: parent
            anchors.margins: -5
            width: parent.contentWidth + 10
            height: parent.contentHeight + 6
            color: Qt.rgba(0, 0, 0, 0.7)
            radius: 3
            z: -1
        }
    }
}
