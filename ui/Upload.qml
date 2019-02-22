import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.3
import "./ui" as UI

Item {
    id: upload2

    property var fileDialog: null

    function fileDialogAccepted(){
        upload.start_upload(fileDialog.fileUrls)
    }

    UI.ZButton {
        id: button
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: item1.bottom
        anchors.topMargin: 20
        font.pixelSize: 12
        text: qsTr("选择文件")
        onClicked: {
            if(fileDialog == null){
                var zFileDialog = Qt.createComponent("qrc:/ui/ZFileDialog.qml")
                if (zFileDialog.status === Component.Ready) {
                    fileDialog = zFileDialog.createObject(window);
                    fileDialog.accepted.connect(fileDialogAccepted)
                    fileDialog.open()
                  }
            }else{
                fileDialog.open()
            }
        }
    }

    Connections{
        target: upload
        onProcessSignal:{
            // 判断列表数是否相等
            if(listModel.count == process.length){
                for(var i = 0; i < process.length;i++){
                    var item = process[i]
                    if(item.process != listModel.get(i).process){
                        listModel.setProperty(i,"process",item.process)
                    }
                }
            }else{
                for(var i = listModel.count;i < process.length;i++){
                    var item = process[i]
                    listModel.append({"fileName":item.fileName,"remotePath":item.remotePath,"process":item.process})
                }
            }
        }
    }

    Item {
        id: item1
        x: 50
        width: 206
        height: 45
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter

        UI.ZText {
            id: label
            text: qsTr("远程路径")
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 15
        }

        UI.ZTextInput {
            id: pathTextField
            width: 146
            height: 26
            text: upload.path
            anchors.left: parent.left
            anchors.leftMargin: 55
            anchors.top: parent.top
            anchors.topMargin: 8

            onTextChanged: {
                upload.path = text
            }
        }
    }

    ListView {
        id: listView
        height: 271
        anchors.top: parent.top
        anchors.topMargin: 200
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.left: parent.left
        delegate: listViewDelegate
        anchors.leftMargin: 30
        model: listModel
        clip: true
    }

    Component {
        id: listViewDelegate
        Item {
            width: listView.width;
            height: 60
            UI.ZText {
                id: fileNameLabel
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                width: parent.width / 3
                text: fileName
                clip: true
                elide: Text.ElideMiddle
            }

            UI.ZText {
                id: remotePathLabel
                width: parent.width / 3
                text: remotePath
                anchors.top: fileNameLabel.top
                anchors.topMargin: 0
                anchors.left: fileNameLabel.right
                anchors.leftMargin: 0
                clip: true
                elide: Text.ElideMiddle
            }

            UI.ZProgressBar {
                id: progressBar1
                width: parent.width / 3
                anchors.left: remotePathLabel.right
                anchors.leftMargin: 0
                anchors.top: remotePathLabel.top
                anchors.topMargin: 3
                value: process / 100
                contentItem: Item {
                    implicitWidth: parent.width

                    Rectangle {
                        width: progressBar1.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: progressBar1.visualPosition == 1 ? "#17a81a" : "#388bff"
                    }
                }
            }
        }
    }

    ListModel {
        id:listModel
    }
}
