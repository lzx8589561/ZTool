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
            text: qsTr("Beyond Compare4 延长至30天")
        }
        UI.ZButton{
            text: qsTr("破解")
            onClicked: {
                crack.beyondCompare4()
                mainSnackbar.open(qsTr("破解完成"))
            }
        }

        UI.ZText{
            text: qsTr("Chrome 崩溃")
        }
        UI.ZButton{
            text: qsTr("修复")
            onClicked: {
                crack.chromeRendererCodeIntegrityEnabled()
                mainSnackbar.open(qsTr("修复完成"))
            }
        }
    }
}
