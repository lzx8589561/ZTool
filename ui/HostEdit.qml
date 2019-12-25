import QtQuick 2.10
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "./ui" as UI

Item {
    UI.ZLoading{
          id: loading
          parent: root
          ztitleText: qsTr("loading...")
    }
    
    ScrollView {
        id: sview
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: bottomLay.top
  
        TextArea {
            id: textArea
            selectByMouse: true
            antialiasing: true
            font.pixelSize: 10
            text: hostEdit.read()

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                cursorShape: Qt.IBeamCursor
                onClicked: {
                    if (mouse.button === Qt.RightButton)
                        var start = textArea.selectionStart
                        var end = textArea.selectionEnd
                        contextMenu.popup()
                        textArea.select(start,end)
                }

                Menu {
                    id: contextMenu
                    MenuItem {
                        text: qsTr("剪贴")
                        onTriggered: textArea.cut()
                    }
                    MenuItem { 
                        text: qsTr("复制")
                        onTriggered: textArea.copy()
                    }
                    MenuItem { 
                        text: qsTr("粘贴")
                        onTriggered: textArea.paste()
                    }
                }
            }
        }
  }

  Rectangle {
        id: bottomLay
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        color: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.2)


        RowLayout{
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 10
            layoutDirection: Qt.RightToLeft
            UI.ZButton{
                id: cfgSaveButton
                text: qsTr("保存")
                Layout.maximumWidth:100
                Layout.rightMargin: 10

                onClicked: {
                    var status = hostEdit.write(textArea.text)
                    if(status === 'success'){
                        mainSnackbar.open(qsTr("保存成功"))
                    }else{
                        mainSnackbar.open(qsTr("保存失败"))
                    }
                }
            }
        }
    }
}
