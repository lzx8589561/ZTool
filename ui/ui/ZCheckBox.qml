import QtQuick 2.10
import QtQuick.Controls 2.3

CheckBox {
    id: control
    text: "CheckBox"
    checked: true

    property color zcolor: ZTheme.primaryColor

    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: ZTheme.radius
        border.color: control.pressed ? Qt.darker(control.zcolor, 1.2) : control.zcolor

        ZText{
            font.family: ZFontIcon.fontFontAwesome.name
            font.pixelSize: control.checked ? 18 : 1
            text: ZFontIcon.fa_check
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: control.pressed ? Qt.darker(control.zcolor, 1.2) : control.zcolor
            opacity: control.checked ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
            Behavior on font.pixelSize {
                NumberAnimation { duration: 100 }
            }
        }
    }

    contentItem: ZText {
        text: control.text
        opacity: enabled ? 1.0 : 0.3
        color: control.pressed ? Qt.darker(control.zcolor, 1.2) : control.zcolor
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }
}
