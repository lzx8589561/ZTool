import QtQuick 2.11
import QtQuick.Window 2.2
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

import "./ui" as UI

UI.ZLessWindow {
    id: window
    visible: true
    width: 640
    height: 480
    minimumHeight: 480
    minimumWidth: 640
    ztop: setting.top
    title: "MySql Tool"

    Item {
        id: root
        anchors.fill: parent
        anchors.topMargin: 35
        property string serviceStatus: null

        UI.ZSideMenu{
            id: sideMenu
            zitemBgColor:"transparent"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: bottomTip.top
            width: 150
            zmodel:[
                {
                    name:qsTr("主页"),
                    fontIcon:UI.ZFontIcon.fa_home
                },
                {
                    name:qsTr("管理"),
                    fontIcon:UI.ZFontIcon.fa_cube
                },
                {
                    name:qsTr("配置"),
                    fontIcon:UI.ZFontIcon.fa_sliders
                },
                {
                    name:qsTr("设置"),
                    fontIcon:UI.ZFontIcon.fa_cog
                },

            ]
            //            ["#EB3C00","#2B579A","#217346","#0078D7","#672B7A","#008272"]
            zclickedCall: function(index,item){
                root.currTab = index
                switch(index){
                case 0:
                    UI.ZTheme.primaryColor = "#2B579A"
                    break
                case 1:
                    UI.ZTheme.primaryColor = "#217346"
                    break
                case 2:
                    UI.ZTheme.primaryColor = "#672B7A"
                    break
                case 3:
                    UI.ZTheme.primaryColor = "#008272"
                    break
                }
            }
        }

        property int currTab: 0




        Item {
            id: content
            anchors.left: sideMenu.right
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: bottomTip.top
            //            anchors.topMargin: 5
            StackLayout {
                id: stackLayout
                anchors.fill: parent
                currentIndex: root.currTab
                Home{
                    id:home
                }
                ServiceManager{
                    id:serviceManager
                }
                Configuration {

                }
                Setting{

                }
            }

        }

        Rectangle{

            id: bottomTip
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            height: 25

            color: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.8)
            Behavior on color { ColorAnimation {duration: 200} }

            UI.ZText{
                id: sText
                color: "white"
                text: qsTr("MYSQL状态：")
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 5
            }

            UI.ZText{
                id: statusText
                color: "white"
                text: qsTr("正在检测")
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: sText.right
                anchors.leftMargin: 5
            }

            UI.ZText{
                id: versionValue
                text: "F0.0.1"
                color: "white"
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 5
                anchors.right: parent.right
            }
            UI.ZText{
                id: versionLabel
                text: qsTr("版本：")
                color: "white"
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 5
                anchors.right: versionValue.left
            }

        }
        property var notfoundStr: qsTr("未安装")
        property var runningStr: qsTr("运行中")
        property var stoppedStr: qsTr("已停止")
        property var stopPendingStr: qsTr("停止中")
        property var startPendingStr: qsTr("开启中")

        // 连接信号
        Connections{
            target: mysqlServiceManager
            onStatusSignal:{
                root.serviceStatus = status
                root.setStatus()
            }
        }

        Connections{
            target: lang
            onLangSignal:{
                root.setStatus()
            }
        }

        function setStatus(){
            if(root.serviceStatus == null){return}
            switch(root.serviceStatus){
            case "notfound":
                statusText.text = root.notfoundStr
                break
            case "running":
                statusText.text = root.runningStr
                break
            case "stopped":
                statusText.text = root.stoppedStr
                break
            case "stopPending":
                statusText.text = root.stopPendingStr
                break
            case "startPending":
                statusText.text = root.startPendingStr
                break
            }
        }
    }
}
