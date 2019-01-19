import QtQuick 2.10
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "./ui" as UI

Item {
    property int currIndex: 0

    UI.ZSnackbar{
        id: snackbar
        parent: root
    }
    ColumnLayout{
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        width: parent.width
        spacing: 5

        UI.ZText{
            text: qsTr("语言")
        }

        UI.ZComboBox{
            model:["English","中文简体"]
            currentIndex: setting.lang
            onCurrentIndexChanged: {
                setting.lang = currentIndex
                
            }
            onZitemClicked: {
                lang.setLanguage(currentIndex)
            }
        }
        UI.ZCheckBox{
            text: qsTr("窗口置顶")
            checked: setting.top
            onCheckStateChanged: {
                window.ztop = checked
                setting.top = checked
            }
        }
        UI.ZText{
            text: qsTr("透明度")
            Layout.topMargin: 10
        }
        UI.ZSlider{
            from: 0.1
            value: setting.opacity
            to: 1.0
            width: 100

            onValueChanged: {
                window.opacity = value
                setting.opacity = value
            }
        }
        UI.ZCheckBox{
            text: qsTr("开机自启")
            enabled: root.serviceStatus === "notfound" ? true : false
            checked: setting.autostarts === 1 ? true : false
            onCheckStateChanged: {
                setting.autostarts = checked ? 1 : 0
            }
        }
        UI.ZText{
            text: qsTr("服务名称")
            Layout.topMargin: 10
        }
        UI.ZTextInput{
            enabled: root.serviceStatus === "notfound" ? true : false
            text: setting.service
            onTextChanged: {
                setting.service = text
            }        
        }
    }
}
