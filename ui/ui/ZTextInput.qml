import QtQuick 2.11
import QtQuick.Controls 2.4

TextField {
    id: control
    placeholderText: qsTr("Enter content")
    font.family: ZTheme.fontFamily

    background: Rectangle {
        implicitWidth: 150
        implicitHeight: 30
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
