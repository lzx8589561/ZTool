import QtQuick 2.10
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Window {
    id: window
    flags:  ztop ? (Qt.Window |
                    Qt.FramelessWindowHint |
                    Qt.WindowStaysOnTopHint |
                    Qt.WindowSystemMenuHint |
                    Qt.WindowMinimizeButtonHint |
                    Qt.WindowMaximizeButtonHint)
                 : (Qt.Window |
                    Qt.FramelessWindowHint |
                    Qt.WindowSystemMenuHint |
                    Qt.WindowMinimizeButtonHint |
                    Qt.WindowMaximizeButtonHint)
    property bool ztop: false
    property string zicon: "qrc:/img/db.svg"
    property int currVisi: Window.Windowed
    property bool fristWindowLoad: true
    property int shadowWidthOrgin: null
    property color shadowColorOrgin: null
    default property alias zbody: zbodyComponent.data

    visibility: Window.Windowed

    Component.onCompleted: {
        shadowWidthOrgin = ZTheme.shadowWidth
        shadowColorOrgin = ZTheme.shadowColor
    }

    onActiveChanged: {
        if(active){visibility = currVisi;ZTheme.shadowColor=shadowColorOrgin;}else{ZTheme.shadowColor="transparent"}
    }
    onCurrVisiChanged: {
        if(currVisi == Window.Maximized){
            ZTheme.shadowWidth = 0
        }else{
            ZTheme.shadowWidth = shadowWidthOrgin
        }
        visibility = currVisi
    }

    Rectangle{
        id:shadowRect
        anchors.fill: parent
        anchors.margins: ZTheme.shadowWidth - 1
        border.color: ZTheme.primaryColor
        border.width: 1
        Behavior on border.color { ColorAnimation {duration: 200} }
    }

    DropShadow {
        anchors.fill: shadowRect
        radius: ZTheme.shadowWidth * 2 - 2
        samples: 41
        color: ZTheme.shadowColor
        source: shadowRect
    }

    function savePos(){
        dragArea.windowLastPos.x = window.x;dragArea.windowLastPos.y = window.y;
    }
    Rectangle{
        id: titleRect
        anchors{
            top: parent.top
            topMargin: ZTheme.shadowWidth
            left: parent.left
            leftMargin: ZTheme.shadowWidth
            right: parent.right
            rightMargin: ZTheme.shadowWidth
        }

        height: 35
        z:999
        color: ZTheme.primaryColor

        Behavior on color { ColorAnimation {duration: 200} }

        Image {
            id: iconImg
            width: 20
            height: 20
            source: zicon
            anchors{
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
        }

        ZText{
            text: window.title
            color: "white"
            anchors.left: iconImg.right
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle{
            z: 999
            width: 35
            color: hovered ? Qt.darker(ZTheme.primaryColor, 1.3) : "transparent"
            property alias hovered: minimizeMouseArea.containsMouse
            anchors{
                right: maximizeRect.left
                top: parent.top
                bottom: parent.bottom
            }
            MouseArea{
                id: minimizeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    window.showMinimized()
                }
            }

            Image {
                id: minimizeImg
                width: 15
                height: 15
                source: "qrc:/img/line.svg"
                anchors{
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
            }
        }

        Rectangle{
            id: maximizeRect
            z: 999
            width: 35
            color: hovered ? Qt.darker(ZTheme.primaryColor, 1.3) : "transparent"
            property alias hovered: maximizeMouseArea.containsMouse
            anchors{
                right: closeRect.left
                top: parent.top
                bottom: parent.bottom
            }
            MouseArea{
                id: maximizeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if(currVisi === Window.Windowed){
                        savePos()
                        currVisi = Window.Maximized
                    }else{
                        currVisi = Window.Windowed
                        window.x = dragArea.windowLastPos.x
                        window.y = dragArea.windowLastPos.y
                    }
                }
            }

            Image {
                id: maximizeImg
                width: 15
                height: 15
                source: currVisi === Window.Maximized ? "qrc:/img/min.svg" : "qrc:/img/max.svg"
                anchors{
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
            }
        }

        Rectangle{
            id: closeRect
            z: 999
            width: 35
            color: hovered ? Qt.darker(ZTheme.primaryColor, 1.3) : "transparent"
            property alias hovered: closeMouseArea.containsMouse
            anchors{
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            MouseArea{
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    window.close()
                }
            }
            Image {
                id: closeImg
                width: 15
                height: 15
                source: "qrc:/img/window_close.svg"
                anchors{
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
            }
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            property point startPos: Qt.point(0,0)
            property point offsetPos: Qt.point(0,0)
            property point windowLastPos: Qt.point(0,0)
            property bool preMax: false

            // 全屏状态下拖动
            property point maxStartPos: Qt.point(0,0)
            // 全屏到窗口位置是否需要重设
            property bool maxToWinRedirect: false

            onPressed: {
                if(currVisi === Window.Maximized){console.log("x:"+mouseX);maxStartPos = Qt.point(mouseX,mouseY);maxToWinRedirect = true;return}
                savePos()
                startPos = Qt.point(mouseX , mouseY)
            }
            onReleased: {
                if(window.y < -1 * ZTheme.shadowWidth){window.y = -1 * ZTheme.shadowWidth}
                if(preMax){ZTheme.shadowWidth = 0;currVisi = Window.Maximized;  preMax = false}
            }

            onPositionChanged: {
                if(currVisi === Window.Maximized){currVisi = Window.Windowed}
                preMax = window.y + mouse.y == -1 * ZTheme.shadowWidth

                if(maxToWinRedirect){
                    var stll = (Screen.desktopAvailableWidth - window.width) / 2
                    if (mouse.x < stll){
                        // 靠左上角
                        window.x = 0
                        window.y = 0
                        startPos = Qt.point(maxStartPos.x,maxStartPos.y)
                    }else if(mouse.x > Screen.desktopAvailableWidth - stll){
                        // 靠右上角
                        window.x = Screen.desktopAvailableWidth - window.width
                        window.y = 0
                        startPos = Qt.point(window.width - (Screen.desktopAvailableWidth - maxStartPos.x),maxStartPos.y)
                    }else{
                        // 中心靠鼠标
                        window.x = maxStartPos.x - (window.width / 2) + -ZTheme.shadowWidth
                        window.y = -1 * ZTheme.shadowWidth
                        startPos = Qt.point(window.width / 2,maxStartPos.y)
                    }
                    maxToWinRedirect = false
                    return
                }
                offsetPos = Qt.point(mouseX - startPos.x, mouseY - startPos.y)
                window.x += offsetPos.x
                window.y += offsetPos.y
            }

            onDoubleClicked: {
                if(currVisi === Window.Windowed){
                    currVisi = Window.Maximized
                }else{
                    // 取消掉全屏的拖动处理
                    maxToWinRedirect = false
                    currVisi = Window.Windowed
                    window.x = windowLastPos.x
                    window.y = windowLastPos.y
                }
            }
        }
    }
    Item {
        id: zbodyComponent
        anchors.fill: parent
        anchors.topMargin: 35 + ZTheme.shadowWidth
        anchors.leftMargin: ZTheme.shadowWidth
        anchors.rightMargin: ZTheme.shadowWidth
        anchors.bottomMargin: ZTheme.shadowWidth
    }
}
