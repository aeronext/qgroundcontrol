/****************************************************************************
 *
 * (c) 2024 QGroundControl Project Custom UI Sample
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 * 日本語ナビゲーションバー
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
    property int currentPage: 0
    
    readonly property var _pageNames: [
        "飛行画面",
        "ミッション",
        "機体設定",
        "アプリ設定",
        "ファイル管理"
    ]
    
    readonly property var _pageIcons: [
        "qrc:/qmlimages/PaperPlane.svg",
        "qrc:/qmlimages/Plan.svg",
        "qrc:/qmlimages/Gears.svg",
        "qrc:/qmlimages/Sliders.svg",
        "qrc:/qmlimages/File.svg"
    ]
    
    signal pageChanged(int page)
    
    height: 60
    color: qgcPal.window
    border.color: qgcPal.windowShade
    border.width: 1
    
    // 背景グラデーション
    gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.lighter(qgcPal.window, 1.05) }
        GradientStop { position: 1.0; color: Qt.darker(qgcPal.window, 1.05) }
    }
    
    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 20
        spacing: 30
        
        // QGCロゴとタイトル
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
            
            Image {
                width: 40
                height: 40
                source: "qrc:/qmlimages/QGCLogoFull.svg"
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                
                QGCLabel {
                    text: "QGroundControl"
                    color: qgcPal.text
                    font.bold: true
                    font.pointSize: ScreenTools.defaultFontPointSize * 1.2
                }
                
                QGCLabel {
                    text: "日本語版"
                    color: qgcPal.primaryButton
                    font.pointSize: ScreenTools.smallFontPointSize
                }
            }
        }
        
        // ページナビゲーション
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5
            
            Repeater {
                model: _pageNames.length
                
                Rectangle {
                    width: 120
                    height: 40
                    color: index === currentPage ? qgcPal.primaryButton : "transparent"
                    border.color: index === currentPage ? qgcPal.primaryButton : qgcPal.windowShade
                    border.width: 1
                    radius: 6
                    
                    // ホバー効果
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.currentPage = index
                            root.pageChanged(index)
                        }
                        
                        onEntered: {
                            if (index !== currentPage) {
                                parent.color = qgcPal.hoverColor
                            }
                        }
                        
                        onExited: {
                            if (index !== currentPage) {
                                parent.color = "transparent"
                            }
                        }
                    }
                    
                    Row {
                        anchors.centerIn: parent
                        spacing: 5
                        
                        Image {
                            width: 16
                            height: 16
                            source: _pageIcons[index]
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        QGCLabel {
                            text: _pageNames[index]
                            color: index === currentPage ? qgcPal.primaryButtonText : qgcPal.text
                            font.pointSize: ScreenTools.smallFontPointSize
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    
                    // アクティブページインジケーター
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 0.8
                        height: 3
                        color: qgcPal.primaryButton
                        radius: 1
                        visible: index === currentPage
                    }
                }
            }
        }
    }
    
    // 右側の状態表示とコントロール
    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 20
        spacing: 15
        
        // 接続状態インジケーター
        Rectangle {
            width: 100
            height: 30
            anchors.verticalCenter: parent.verticalCenter
            color: vehicle ? qgcPal.colorGreen : qgcPal.colorRed
            radius: 15
            
            Row {
                anchors.centerIn: parent
                spacing: 5
                
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                    
                    // 接続時の点滅アニメーション
                    SequentialAnimation on opacity {
                        running: vehicle !== null
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 800 }
                        NumberAnimation { to: 1.0; duration: 800 }
                    }
                }
                
                QGCLabel {
                    text: vehicle ? "接続中" : "未接続"
                    color: "white"
                    font.bold: true
                    font.pointSize: ScreenTools.smallFontPointSize
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
        
        // 機体名表示
        Rectangle {
            width: 120
            height: 30
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.rgba(qgcPal.window.r, qgcPal.window.g, qgcPal.window.b, 0.7)
            border.color: qgcPal.windowShade
            border.width: 1
            radius: 4
            visible: vehicle
            
            QGCLabel {
                anchors.centerIn: parent
                text: vehicle ? "機体: " + vehicle.id : ""
                color: qgcPal.text
                font.pointSize: ScreenTools.smallFontPointSize
                elide: Text.ElideRight
            }
        }
        
        // 時刻表示
        Rectangle {
            width: 80
            height: 30
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.rgba(qgcPal.window.r, qgcPal.window.g, qgcPal.window.b, 0.7)
            border.color: qgcPal.windowShade
            border.width: 1
            radius: 4
            
            QGCLabel {
                id: timeLabel
                anchors.centerIn: parent
                color: qgcPal.text
                font.pointSize: ScreenTools.smallFontPointSize
                
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        var now = new Date()
                        timeLabel.text = Qt.formatTime(now, "hh:mm")
                    }
                    Component.onCompleted: triggered()
                }
            }
        }
        
        // メニューボタン
        QGCButton {
            width: 40
            height: 30
            anchors.verticalCenter: parent.verticalCenter
            text: "≡"
            font.pointSize: ScreenTools.defaultFontPointSize
            
            onClicked: {
                // メニューの表示/非表示切り替え
                contextMenu.popup()
            }
            
            QGCMenu {
                id: contextMenu
                
                QGCMenuItem {
                    text: "高度なUI"
                    checkable: true
                    checked: QGroundControl.settingsManager.appSettings.showAdvancedUI.rawValue
                    onTriggered: {
                        QGroundControl.settingsManager.appSettings.showAdvancedUI.rawValue = !checked
                    }
                }
                
                QGCMenuSeparator { }
                
                QGCMenuItem {
                    text: "ヘルプ"
                    onTriggered: {
                        // ヘルプダイアログを表示
                    }
                }
                
                QGCMenuItem {
                    text: "この製品について"
                    onTriggered: {
                        // Aboutダイアログを表示
                    }
                }
                
                QGCMenuSeparator { }
                
                QGCMenuItem {
                    text: "終了"
                    onTriggered: {
                        QGroundControl.qgcApplication.quit()
                    }
                }
            }
        }
    }
    
    // 下部の進行状況バー（オプション）
    Rectangle {
        id: progressBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 2
        color: qgcPal.primaryButton
        opacity: 0.7
        visible: _isLoading()
        
        Rectangle {
            id: progressIndicator
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 0
            color: Qt.lighter(qgcPal.primaryButton, 1.3)
            
            SequentialAnimation on width {
                running: progressBar.visible
                loops: Animation.Infinite
                NumberAnimation {
                    to: root.width
                    duration: 2000
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    to: 0
                    duration: 0
                }
            }
        }
    }
    
    function _isLoading() {
        // 読み込み中の状態を判定（例：ミッションアップロード中など）
        return vehicle && vehicle.missionManager && vehicle.missionManager.inProgress
    }
}
