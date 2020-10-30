import QtQuick 2.10
import QtQuick.Controls 2.3

ListView {
    id: listView
    spacing: 0
    clip: true

    property string zviewBgColor: Qt.rgba(ZTheme.primaryColor.r, ZTheme.primaryColor.g, ZTheme.primaryColor.b, 0.08)
    property string zitemBgColor: Qt.rgba(ZTheme.primaryColor.r, ZTheme.primaryColor.g, ZTheme.primaryColor.b, 0.2)
    property string zitemHoverBgColor: Qt.rgba(ZTheme.primaryColor.r, ZTheme.primaryColor.g, ZTheme.primaryColor.b, 0.3)
    property string zitemSelectedBgColor: Qt.rgba(ZTheme.primaryColor.r, ZTheme.primaryColor.g, ZTheme.primaryColor.b, 0.4)
    property string zitemPressedBgColor: Qt.rgba(ZTheme.primaryColor.r, ZTheme.primaryColor.g, ZTheme.primaryColor.b, 0.5)

    property var zmodel: []

    property var zclickedCall: null

    currentIndex: 0

    onZmodelChanged: {
        drawModel()
    }

    Rectangle{
        anchors.fill: parent
        color: parent.zviewBgColor
        z: -1
    }

//    Component.onCompleted: {
//        drawModel()
//    }

    function drawModel(){
        listModel.clear()
        if(zmodel.length > 0){
            for(var i = 0; i < zmodel.length; i++){
                listModel.append(zmodel[i])
            }
        }
        currentIndex = currentIndex
    }

    property ListModel listModel: ListModel {}


    delegate: ItemDelegate {
        id: itemDelegate
        width: listView.width
        height: 40
        highlighted: ListView.isCurrentItem
        Item {
            anchors.fill: parent
            property bool imgExist: typeof(img) !== "undefined"
            property bool fontIconExist: typeof(fontIcon) !== "undefined"

            Rectangle {
                id:placeholder
                anchors{
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: 10
                color: "transparent"
            }

            ZText{
                id: fontIconText
                font.pixelSize: 20
                text: parent.fontIconExist ? fontIcon : ""
                font.family: ZFontIcon.fontFontAwesome.name
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: placeholder.right
                width: parent.fontIconExist ? 20 : 0
                color: ZTheme.primaryColor
            }

            Image {
                id: image
                width: parent.imgExist ? 20 : 0
                height: 20
                source: parent.imgExist ? img : ""
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: fontIconText.right
                visible: parent.imgExist
            }

            ZText {
                text: name
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: image.right
                anchors.leftMargin: 10
                font.family: ZTheme.fontFamily
            }
        }

        onClicked: {
            listView.currentIndex = index
            if(zclickedCall != null){
                zclickedCall(index,zmodel[index])
            }
        }

        background: Rectangle {
            color: highlighted ? listView.zitemSelectedBgColor :
                                 (parent.hovered ? (parent.pressed ? listView.zitemPressedBgColor : listView.zitemHoverBgColor) : listView.zitemBgColor)
            Rectangle {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                height: parent.height
                width: 4
                color: highlighted ? ZTheme.primaryColor : "transparent"
            }
        }
    }
    model: listView.listModel
}
