import QtQuick 2.11
import QtQuick.Controls 2.4

Slider {
    id: control
    value: 0.5

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 6
        width: control.availableWidth
        height: implicitHeight
        radius: height / 2
        color: "#bdbebf"

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: ZTheme.primaryColor
            radius: 2
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: ZTheme.sliderHandleWidth
        implicitHeight: ZTheme.sliderHandleWidth
        radius: width / 2
        color: control.pressed ? "#f0f0f0" : "#f6f6f6"
        border.color: ZTheme.primaryColor
    }
}
