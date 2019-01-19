import QtQuick 2.10
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "./ui" as UI

Item {
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
            text: qsTr("操作系统")
            style: "h2"
            color: UI.ZTheme.primaryColor
        }
        UI.ZText{
            text: system.platform
            style: "h3"
        }
        UI.ZText{
            text: qsTr("快速安装")
            style: "h2"
            color: UI.ZTheme.primaryColor
        }
//         UI.ZText{
//             text: qsTr("版本")
//             style: "h2"
//         }
//         UI.ZComboBox{
//             model:["5.5","5.6","5.7"]
//         }
//        UI.ZText{
//            text: qsTr("性能模式")
//            style: "h3"
//            Layout.topMargin: 10
//        }
//        UI.ZComboBox{
//            model: [qsTr("轻量"), qsTr("普通"), qsTr("服务器")]
//        }
        UI.ZText{
            text: qsTr("快速安装")
            style: "h3"
            Layout.topMargin: 10
        }
        RowLayout{
            spacing: 10
            UI.ZButton{
                enabled: root.serviceStatus === "notfound" ? true : false
                text: qsTr("快速安装")
                onClicked: {
                    console.log(mysqlServiceManager.installService())
                }
            }
            UI.ZButton{
                enabled: root.serviceStatus === "stopped" ? true : false
                text: qsTr("快速卸载")
                onClicked: {
                    console.log(mysqlServiceManager.uninstallService())
                }
            }
        }

        UI.ZText{
            text: qsTr("启动停止")
            style: "h3"
            Layout.topMargin: 10
        }
        RowLayout{
            spacing: 10
            UI.ZButton{
                enabled: root.serviceStatus === "stopped" ? true : false
                text: qsTr("启动服务")
                property var startingStr: qsTr("正在启动中...")
                property var startFailureStr: qsTr("启动失败！")
                property var cannotStartStr: qsTr("当前状态无法启动！")

                onClicked: {
                    if(root.serviceStatus == "stopped"){
                        var result = mysqlServiceManager.startService()
                        console.log(result)
                        if(result === "ok"){
                            snackbar.open(startingStr)
                        }else{
                            snackbar.open(startFailureStr)
                        }
                    }else{
                        snackbar.open(cannotStartStr)
                    }

                }
            }
            UI.ZButton{
                enabled: root.serviceStatus === "running" ? true : false
                text: qsTr("停止服务")
                onClicked: {
                    console.log(mysqlServiceManager.stopService())
                }
            }
            UI.ZButton{
                enabled: (root.serviceStatus === "running" || root.serviceStatus === "stopPending" || root.serviceStatus === "startPending") ? true : false
                text: qsTr("杀死进程")
                onClicked: {
                    console.log(mysqlServiceManager.killProgress())
                }
            }
        }

    }

}
