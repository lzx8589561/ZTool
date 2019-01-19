import QtQuick 2.10
import QtQuick.Controls 2.3

Rectangle {
    id: layer
    anchors.fill: parent

    color: Qt.rgba(0,0,0,0.3)
    visible: false

    signal zclickLayer()

    MouseArea{
        hoverEnabled: true
        anchors.fill: parent
        onClicked: {
            zclickLayer()
        }
        onReleased: {}
        onPressed: {}

    }

//    Component.onCompleted: {
//        forceActiveFocus()
//        console.log("设置焦点")
//    }

//    Behavior on opacity {
//        PropertyAnimation {
//            duration: 200
//        }
//    }

    function zclose(){
        layer.visible = false
        layer.opacity = 0
    }

    function zopen(){
        layer.visible = true
        layer.opacity = 1
    }
}
