import QtQuick 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0

ZLayer {
    signal zaccepted()
    signal zrejected()

    property alias zcancelText: cancelButton.text
    property alias zokText: okButton.text
    property alias ztitleText: titleText.text
    property alias ztext: contentText.text
    property color zbgTitleBottomColor: Qt.rgba(ZTheme.primaryColor.r, ZTheme.primaryColor.g, ZTheme.primaryColor.b, 0.08)
    property bool zshadeClose: true

    Rectangle{
        id: confirmBox
        visible: parent.visible
        width: 250
        height: 150
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        scale: visible ? 1 : 0.7
        color: "white"
        radius: ZTheme.radius

        MouseArea{
            anchors.fill: parent
            onClicked: {}
        }

        Rectangle{
            id: titleRect
            anchors{
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: 40

            color: zbgTitleBottomColor

            ZText{
                id: titleText
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                text: qsTr("提示")
                font.pixelSize: 14
            }
            ZButton{
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                zbackgroundItem: Rectangle{color: "#00000000"}
                zcontentItem: ZText{
                    font.family: ZFontIcon.fontFontAwesome.name
                    text: ZFontIcon.fa_close
                    font.pixelSize: 20
                    color: parent.hovered ? ZTheme.primaryColor : "#000000"
                }
                onClicked: {
                    zclose()
                }
            }


        }
        Rectangle{
            id: contentRect
            anchors{
                top: titleRect.bottom
                left: parent.left
                right: parent.right
                bottom: bottomRect.top
            }

            ZText{
                id: contentText
                anchors.fill: parent
                padding: 10
                wrapMode: Text.WordWrap
                text: "确定要点确定吗？"
            }
        }
        Rectangle{
            id: bottomRect
            anchors{
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            height: 40

            color: zbgTitleBottomColor

            ZButton{
                id: okButton
                text: qsTr("确定")
                width: 80
                height: 30
                anchors{
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 10
                }
                onClicked: {
                    zaccepted()
                    zclose()
                }
            }
            ZButton{
                id: cancelButton
                text: qsTr("取消")
                width: 80
                height: 30
                anchors{
                    verticalCenter: parent.verticalCenter
                    right: okButton.left
                    rightMargin: 10
                }
                onClicked: {
                    zrejected()
                    zclose()
                }
            }

        }
        Behavior on scale {
            NumberAnimation { duration: 200;easing.type: Easing.OutBack }
        }



    }
    DropShadow {
        scale: confirmBox.scale
        anchors.fill: confirmBox
//        horizontalOffset: 3
//        verticalOffset: 3
        radius: 20
        samples: 41
        color: "#80000000"
        source: confirmBox
    }

    onZclickLayer: {
        if(zshadeClose){
            zrejected()
            zclose()
        }
    }

}
