import QtQuick 2.11
import QtQuick.Window 2.2
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

Window {
    id: window
    flags:  ztop ? (Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint) : (Qt.Window | Qt.FramelessWindowHint)
    property bool ztop: false
    property string zicon: "qrc:/img/db.svg"
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
                right: closeRect.left
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
            property point startPos: Qt.point(0,0);
            property point offsetPos: Qt.point(0,0);

            onPressed: startPos = Qt.point(mouseX , mouseY);

            onPositionChanged: {
                offsetPos = Qt.point(mouseX - startPos.x, mouseY - startPos.y);
                window.x += offsetPos.x;
                window.y += offsetPos.y;
            }
        }
    }
}
