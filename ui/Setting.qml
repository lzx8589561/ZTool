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
            onZitemClicked: {
                setting.lang = currentIndex
                lang.setLanguage(currentIndex)
            }
        }
        UI.ZCheckBox{
            text: qsTr("窗口置顶")
            checked: setting.top
            onClicked: {
                window.ztop = checked
                setting.top = checked
            }
        }
//        UI.ZCheckBox{
//            text: qsTr("开机自启")
//            checked: setting.autostart
//            onClicked: {
//                setting.autostart = checked
//            }
//        }
        UI.ZText{
            text: qsTr("透明度")
            Layout.topMargin: 10
        }
        UI.ZSlider{
            from: 0.1
            value: setting.opacity
            to: 1.0
            width: 100

            onMoved: {
                window.opacity = value
                setting.opacity = value
            }

        }
    }
}
