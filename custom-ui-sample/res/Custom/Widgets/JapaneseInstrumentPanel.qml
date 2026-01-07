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
        columns: 2
        rowSpacing: 10
        columnSpacing: 10

        // 高度情報
        Rectangle {
            Layout.preferredWidth: instrumentSize
            Layout.preferredHeight: instrumentSize * 0.6
            color: qgcPal.windowShade
            border.color: qgcPal.text
            border.width: 1
            radius: 5

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                QGCLabel {
                    Layout.fillWidth: true
                    text: "高度 (m)"
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }

                QGCLabel {
                    Layout.fillWidth: true
                    text: _altitude.toFixed(1)
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.largeFontPointSize
                    color: qgcPal.colorGreen
                }

                QGCLabel {
                    Layout.fillWidth: true
                    text: "上昇率: " + _climbRate.toFixed(1) + " m/s"
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.smallFontPointSize
                }
            }
        }

        // 速度情報
        Rectangle {
            Layout.preferredWidth: instrumentSize
            Layout.preferredHeight: instrumentSize * 0.6
            color: qgcPal.windowShade
            border.color: qgcPal.text
            border.width: 1
            radius: 5

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                QGCLabel {
                    Layout.fillWidth: true
                    text: "速度 (m/s)"
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }

                QGCLabel {
                    Layout.fillWidth: true
                    text: _groundSpeed.toFixed(1)
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.largeFontPointSize
                    color: qgcPal.colorBlue
                }

                QGCLabel {
                    Layout.fillWidth: true
                    text: "対気速度: " + _airSpeed.toFixed(1) + " m/s"
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.smallFontPointSize
                }
            }
        }

        // 姿勢情報
        Rectangle {
            Layout.preferredWidth: instrumentSize
            Layout.preferredHeight: instrumentSize * 0.6
            color: qgcPal.windowShade
            border.color: qgcPal.text
            border.width: 1
            radius: 5

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                QGCLabel {
                    Layout.fillWidth: true
                    text: "姿勢"
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }

                QGCLabel {
                    Layout.fillWidth: true
                    text: "ロール: " + _roll.toFixed(1) + "°"
                    horizontalAlignment: Text.AlignHCenter
                }

                QGCLabel {
                    Layout.fillWidth: true
                    text: "ピッチ: " + _pitch.toFixed(1) + "°"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // 方位情報
        Rectangle {
            Layout.preferredWidth: instrumentSize
            Layout.preferredHeight: instrumentSize * 0.6
            color: qgcPal.windowShade
            border.color: qgcPal.text
            border.width: 1
            radius: 5

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                QGCLabel {
                    Layout.fillWidth: true
                    text: "方位 (°)"
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }

                QGCLabel {
                    Layout.fillWidth: true
                    text: _heading.toFixed(0)
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.largeFontPointSize
                    color: qgcPal.colorOrange
                }

                QGCLabel {
                    Layout.fillWidth: true
                    text: "北から時計回り"
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.smallFontPointSize
                }
            }
        }
    }
}
