import QtQuick 2.10
import QtQuick.Controls 2.3

Button {
    id: control
    text: "Button"

    property string style: "default"

    property string zbgColor: styles[style].bgColor
    property string zborderColor: styles[style].borderColor
    property string zfontColor: styles[style].fontColor
    property alias zcontentItem: control.contentItem
    property alias zbackgroundItem: control.background

    property var styles: {
        "default":{
            "bgColor":"#fff",
            "borderColor":ZTheme.primaryColor,
            "fontColor":ZTheme.primaryColor
        },
        "success":{
            "bgColor":"#fff",
            "borderColor":"#5cb85c",
            "fontColor":"#5cb85c"
        },
        "warning":{
            "bgColor":"#fff",
            "borderColor":"#f0ad4e",
            "fontColor":"#f0ad4e"
        },
        "error":{
            "bgColor":"#fff",
            "borderColor":"#d9534f",
            "fontColor":"#d9534f"
        }
    }



    contentItem: ZText {
        id:contentItem
        style: "body"
        text: control.text
        opacity: enabled ? 1.0 : 0.3
        color: parent.hovered ? zbgColor : zfontColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        font.bold: false
        Behavior on color { ColorAnimation {duration: 100} }
    }

    background: Rectangle {
        id: backgroundItem
        implicitWidth: ZTheme.buttonWidth
        implicitHeight: ZTheme.buttonHeight
        opacity: enabled ? 1 : 0.3
        color: parent.hovered ? (parent.pressed ? Qt.darker(zfontColor, 1.1) : zfontColor) : zbgColor
        border.color: zborderColor
        border.width: 1
        radius: ZTheme.radius
        Behavior on color { ColorAnimation {duration: 100} }
    }
  }
