import QtQuick 2.11
import QtQuick.Controls 2.4

ListView {
    id: listView
    orientation: ListView.Horizontal
    height: 35
    spacing: 0
    clip: true
    currentIndex: 0
    property string zhighlightedColor: ZTheme.primaryColor
    property var zclickedCall: null
    property var zmodel: []
    model: ListModel{}

    onZmodelChanged: {
        drawModel()
    }

//    Component.onCompleted: {
//        drawModel()
//    }

    function drawModel(){
        listView.model.clear()
        if(zmodel.length > 0){
            for(var i = 0; i < zmodel.length; i++){
                listView.model.append(zmodel[i])
            }
        }
        currentIndex = currentIndex
    }


    delegate: ItemDelegate {
        id: itemDelegate
        width: 70
        height: parent.height
        highlighted: ListView.isCurrentItem
        Item {
            anchors.fill: parent
            ZText {
                id: element
                text: name
                font.bold: itemDelegate.highlighted ? true : false
                color: itemDelegate.highlighted ? zhighlightedColor : "#24292e"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation {duration: 100} }
            }
        }
        onClicked: {
            listView.currentIndex = index
            if(zclickedCall != null){
                zclickedCall(index)
            }
            if(typeof(exp) !== "undefined"){
                callback()
            }

        }
        background: Rectangle {
            color: "transparent"
            Rectangle {
                width: parent.width
                height: 2
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                color:  itemDelegate.highlighted ? zhighlightedColor : "transparent"
            }
        }
    }


}
