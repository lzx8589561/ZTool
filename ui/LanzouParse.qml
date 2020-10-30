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

    UI.ZSnackbar{
        id: snackbar
        parent: root
    }
    ColumnLayout{
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.right: parent.right
        width: parent.width
        spacing: 5

        UI.ZText{
            text: qsTr("原地址")
        }
        UI.ZTextInput{
            id: urlTextInput
            Layout.fillWidth: true
            text: ""
        }

         UI.ZText{
            text: qsTr("真实地址")
        }
        UI.ZTextInput{
            id: parseUrl
            Layout.fillWidth: true
            text: ""
        }
        RowLayout{
            spacing: 10
            UI.ZButton{
                text: qsTr("解析")
                onClicked: {
                    lanzouParse.parse(urlTextInput.text)
                    loading.zopen()
                }
            }
            UI.ZButton{
                text: qsTr("复制到剪贴板")
                onClicked: {
                    lanzouParse.paste(parseUrl.text)
                    mainSnackbar.open(qsTr("已复制到剪贴板"))
                }
            }
        }
        
        

    }
    Connections{
        target: lanzouParse
        function onParseCompleteSignal(originUrl){
            loading.zclose()
            parseUrl.text = originUrl
            if(originUrl === ''){
                mainSnackbar.open(qsTr("解析失败"))
                return
            }
            mainSnackbar.open(qsTr("解析成功"))
        }
    }
}
