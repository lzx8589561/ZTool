import QtQuick 2.10
import QtQuick.Controls 2.3

ProgressBar {
    id: control
    value: 0.5
    padding: 1

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: ZTheme.progressBarHeight
        color: "#e6e6e6"
        radius: ZTheme.progressBarHeight / 2
    }

    contentItem: Item {
        implicitWidth: 200
        implicitHeight: ZTheme.progressBarHeight

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: ZTheme.progressBarHeight / 2
            color: ZTheme.primaryColor
        }
    }
}
