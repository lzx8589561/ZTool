import QtQuick 2.11
import QtQuick.Controls 2.4

RadioButton {
    id: control
    text: "RadioButton"
    checked: true

    indicator: Rectangle {
        implicitWidth: 26
        implicitHeight: 26
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 13
        border.color: control.down ? Qt.darker(ZTheme.primaryColor,1.1) : ZTheme.primaryColor

        Rectangle {
            width: control.checked ? 14 : 0
            height: control.checked ? 14 : 0
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 7
            color: control.down ? Qt.darker(ZTheme.primaryColor,1.1) : ZTheme.primaryColor

            Behavior on width {
                NumberAnimation { duration: 100 }
            }
            Behavior on height {
                NumberAnimation { duration: 100 }
            }
        }
    }

    contentItem: ZText {
        text: control.text
        opacity: enabled ? 1.0 : 0.3
        color: control.down ? Qt.darker(ZTheme.primaryColor,1.1) : ZTheme.primaryColor
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }
}
