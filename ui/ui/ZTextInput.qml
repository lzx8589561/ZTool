import QtQuick 2.10
import QtQuick.Controls 2.3

TextField {
    id: control
    placeholderText: qsTr("Enter content")
    font.family: ZTheme.fontFamily
    width: 150
    height: 30
    selectByMouse: true

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        cursorShape: Qt.IBeamCursor
        onClicked: {
            if (mouse.button === Qt.RightButton)
                var start = control.selectionStart
                var end = control.selectionEnd
                contextMenu.popup()
                control.select(start,end)
        }

        Menu {
            id: contextMenu
            MenuItem {
                text: qsTr("剪贴")
                onTriggered: control.cut()
            }
            MenuItem { 
                text: qsTr("复制")
                onTriggered: control.copy()
            }
            MenuItem { 
                text: qsTr("粘贴")
                onTriggered: control.paste()
            }
        }
    }

    background: Rectangle {
        implicitWidth: parent.width
        implicitHeight: parent.height
//        border.color: "#1a73e8"
        Rectangle{
            color: control.activeFocus ? ZTheme.primaryColor : "#b7b7b7"
            width: parent.width
            height: 2
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            Behavior on color { ColorAnimation {duration: 100} }
        }
    }
}
