import QtQuick 2.10
import QtQuick.Controls 2.3

Rectangle {
    id: snackbar

    property string buttonText
    property color buttonColor: "#2196f3"
    property string text
    property bool opened
    property int duration: 2000
    property bool fullWidth: false
    property string type : ""

    signal clicked

    function open(text,type,timeOut){
        if(typeof(timeOut) === "undefined"){
            duration = 2000
        }else{
            duration = timeOut
        }

        snackbar.text = text
        opened = true;
        timer.restart();
    }

    anchors {
        right: parent.right
        rightMargin: fullWidth ? 0 : 16
        top:parent.top
        topMargin: opened ? (fullWidth ? 0 : 16) :  -snackbar.height

        Behavior on topMargin {
            NumberAnimation { duration: 400; easing.type: Easing.OutQuad }
        }
    }
    radius: fullWidth ? 0 : 2
    color: "#cc323232"
    height: 48
    width: fullWidth ? parent.width : 200
    opacity: opened ? 1 : 0

    Timer {
        id: timer

        interval: snackbar.duration

        onTriggered: {
            if (!running) {
                snackbar.opened = false;
            }
        }
    }
    // ZText{
    //     id: icon
    //     font.family: ZFontIcon.fontFontAwesome.name
    //     font.pixelSize: 25
    //     color: "green"
    //     text: ZFontIcon.fa_check
    //     anchors {
    //         verticalCenter: parent.verticalCenter
    //         left: parent.left
    //         leftMargin: 10
    //     }
    // }

    ZText {
        id: snackText
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 10
        }
        text: snackbar.text
        color: "white"
    }

    Behavior on opacity {
        NumberAnimation { duration: 300 }
    }
}
