import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
//import QtWebEngine 1.0
import Qt.labs.platform 1.0

import "./ui" as UI

UI.ZLessWindow {
    id: window
    visible: true
    width: 850
    height: 600
    minimumHeight: 850
    minimumWidth: 600
    ztop: setting.top
    title: "ZTool"
    opacity: 0

    property alias showWindow: openAnimation

    Timer{
        id: timer
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            window.ztop = setting.top
            console.log("top timer execute!")
        }
    }

    PropertyAnimation{
        id: closeAnimation
        target: window
        property: "opacity"
        to: 0
        duration: 200

        onStopped: {
            window.hide()
        }
    }
    PropertyAnimation{
        id: openAnimation
        target: window
        property: "opacity"
        to: setting.opacity
        duration: 200

        onStarted: {
            window.show()
        }
    }

    Component.onCompleted: {
        console.log("background:"+setting.background_run)
        if(setting.background_run){
            closeAnimation.start()
            console.log("hide window")
        }else{
            window.raise()
            window.requestActivate()
            window.ztop = true
            openAnimation.start()
            console.log("qml load complete:" + new Date().getTime())
            timer.start()
        }

    }

    SystemTrayIcon {
        id: systemIcon
        tooltip: window.title
        visible: true
        iconSource: "qrc:/img/icon.ico"


        menu: Menu {
            MenuItem {
                text: qsTr("退出")
                onTriggered: {
                    systemIcon.hide()
                    aria2.stopAria2()
                    Qt.quit()
                }
            }
        }
        Component.onCompleted: {
            if(setting.init){
                showMessage("欢迎你", "欢迎使用ZTool，期待你提出宝贵的意见！")
                setting.init = false
            }

        }
        onActivated: {
            if(reason == SystemTrayIcon.Trigger){
                if(!window.visible){
                    window.requestActivate()
                    window.raise()
                    openAnimation.start()
                }else{
                    closeAnimation.start()
                }

            }

        }
    }

    UI.ZConfirm{
        id:confirm

    }

    onClosing:{
        close.accepted = false
//        window.hide()
        closeAnimation.start()
    }

    Item {
        id: root
        anchors.fill: parent
        anchors.topMargin: 35
        property string serviceStatus: null
        property string lastServiceStatus: null

        UI.ZSideMenu{
            id: sideMenu
            zitemBgColor:"transparent"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: 150
            zmodel:[
                {
                    name:qsTr("主页"),
                    fontIcon:UI.ZFontIcon.fa_home
                },
                {
                    name:qsTr("数据库"),
                    fontIcon:UI.ZFontIcon.fa_sliders
                },
//                {
//                    name:qsTr("Web"),
//                    fontIcon:UI.ZFontIcon.fa_chrome
//                },
                {
                    name:qsTr("下载"),
                    fontIcon:UI.ZFontIcon.fa_cloud_download
                },
//                {
//                    name:qsTr("上传"),
//                    fontIcon:UI.ZFontIcon.fa_cloud_upload
//                },
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
                case 4:
                    UI.ZTheme.primaryColor = "#673ab7"
                    break
                case 5:
                    UI.ZTheme.primaryColor = "#228fbd"
                    break
                case 6:
                    UI.ZTheme.primaryColor = "#0e0e0e"
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
            anchors.bottom: parent.bottom
            //            anchors.topMargin: 5
            StackLayout {
                id: stackLayout
                anchors.fill: parent
                currentIndex: root.currTab
                Home{

                }

                Database {

                }

//                Item{
//                    WebEngineView {
//                        anchors.fill: parent
//                        url: "http://www.ilt.me/"
//                    }
//                }

                Download{

                }

//                Upload{
//
//                }

                Setting{

                }
            }

        }
    }
}
