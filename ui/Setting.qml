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
            id: langComboBox
            model:["English","中文简体"]
            onZitemClicked: {
                setting.lang = currentIndex
                lang.setLanguage(currentIndex)
                root.langChangeSignal()
            }
        }
        UI.ZCheckBox{
            id: listenurlCheckBox
            text: qsTr("监听下载链接")
            onClicked: {
                setting.listenurl = checked
            }
        }
        UI.ZCheckBox{
            id: listenkeyboardCheckBox
            text: qsTr("监听按键")
            onClicked: {
                setting.listenkeyboard = checked
                keyboardListener.listener(checked)
            }
        }
        UI.ZCheckBox{
            id: topCheckBox
            text: qsTr("窗口置顶")
            onClicked: {
                window.ztop = checked
                setting.top = checked
            }
        }
        UI.ZCheckBox{
            id: autostartCheckBox
            text: qsTr("开机自启")
            onClicked: {
                setting.autostart = checked
            }
        }
        UI.ZText{
            text: qsTr("透明度")
            Layout.topMargin: 10
        }
        UI.ZSlider{
            id: opacitySlider
            from: 0.1
            to: 1.0
            width: 100

            onMoved: {
                window.opacity = value
                setting.opacity = value
            }

        }
    }

    Component.onCompleted: {
        langComboBox.currentIndex = setting.lang
        listenurlCheckBox.checked = setting.listenurl
        listenkeyboardCheckBox.checked = setting.listenkeyboard
        topCheckBox.checked = setting.top
        autostartCheckBox.checked = setting.autostart
        opacitySlider.value = setting.opacity
    }
}
