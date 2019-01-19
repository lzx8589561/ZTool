import QtQuick 2.10
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Window {
    id: window
    flags:  ztop ? (Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint) : (Qt.Window | Qt.FramelessWindowHint)
    property bool ztop: false
    property string zicon: "qrc:/img/db.svg"
    property int currVisi: Window.Windowed
    property bool fristWindowLoad: true
    visibility: Window.Maximized

    onActiveChanged: {
        if(active){visibility = currVisi}
    }
    onCurrVisiChanged: {
        visibility = currVisi
    }

    function initLoad(){
        if(fristWindowLoad){dragArea.windowLastPos.x = window.x;dragArea.windowLastPos.y = window.y;fristWindowLoad = false}
    }
    Rectangle{
        id: titleRect
        anchors{
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: 35

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
                        initLoad()
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

            onPressed: {
                initLoad()
                if(currVisi === Window.Maximized){return}
                startPos = Qt.point(mouseX , mouseY)
                windowLastPos.x = window.x
                windowLastPos.y = window.y
            }
            onReleased: {
                if(window.y < 0){window.y = 0}
                if(preMax){currVisi = Window.Maximized;preMax = false}
            }

            onPositionChanged: {
                if(currVisi === Window.Maximized){return}
                preMax = window.y + mouse.y == 0
                offsetPos = Qt.point(mouseX - startPos.x, mouseY - startPos.y)
                window.x += offsetPos.x
                window.y += offsetPos.y
            }

            onDoubleClicked: {
                if(currVisi === Window.Windowed){
                    currVisi = Window.Maximized
                }else{
                    currVisi = Window.Windowed
                    window.x = windowLastPos.x
                    window.y = windowLastPos.y
                }

            }
        }
    }
}
