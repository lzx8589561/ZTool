import QtQuick 2.11
import QtQuick.Controls 2.4

Switch {
    id: control
//    text: qsTr("Switch")

    indicator: Rectangle {
        implicitWidth: 48
        implicitHeight: 26
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: height / 2
        color: control.checked ? ZTheme.primaryColor : "#ffffff"
        border.color: control.checked ? ZTheme.primaryColor : "#cccccc"

        Rectangle {
            x: control.checked ? parent.width - width : 0
            width: 26
            height: 26
            radius: 13
            color: control.down ? "#cccccc" : "#ffffff"
            border.color: control.checked ? (control.down ? Qt.darker(ZTheme.primaryColor, 1.1) : ZTheme.primaryColor) : "#999999"
            Behavior on x {
                NumberAnimation { duration: 100 }
            }
        }
    }

    contentItem: ZText {
        text: control.text
        opacity: enabled ? 1.0 : 0.3
        color: control.down ? "#17a81a" : ZTheme.primaryColor
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }
}
