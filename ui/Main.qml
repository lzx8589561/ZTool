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
    width: setting.window_width
    height: setting.window_height
    minimumWidth: 640
    minimumHeight: 480
    ztop: setting.top
    title: "ZTool"
    opacity: 0
    color: "transparent"

    UI.ZSnackbar{
        id: mainSnackbar
        parent: root
    }

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

    onZdragWindowSizeChanged: {
        setting.window_width = window.width
        setting.window_height = window.height
    }

    property var proxyMode: setting.proxy_mode

    SystemTrayIcon {
        id: systemIcon
        tooltip: window.title
        visible: true
        iconSource: "qrc:/img/icon.ico"
        // parent: Qt::Desktop

        menu: Menu {
            
            MenuItem {
                text: qsTr("全局代理")
                checkable: true
                checked: proxyMode == 'ProxyOnly'
                onTriggered: {
                    if(!checked){
                        setting.proxy_mode = 'ProxyOnly'
                        V2rayManager.start()
                    }else{
                        setting.proxy_mode = 'Off'
                        V2rayManager.stop()
                    }
                }
            }
            MenuItem {
                text: qsTr("PAC")
                checkable: true
                checked: proxyMode == 'PacOnly'
                onTriggered: {
                    if(!checked){
                        setting.proxy_mode = 'PacOnly'
                        V2rayManager.start()
                    }else{
                        setting.proxy_mode = 'Off'
                        V2rayManager.stop()
                    }
                }
            }
            MenuItem {
                text: qsTr("取消")
                onTriggered: {
                    
                }
            }
            MenuItem {
                text: qsTr("退出")
                onTriggered: {
                    systemIcon.hide()
                    closeAnimation.start()
                    aria2.stopAria2()
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
                window.requestActivate()
                window.raise()
                openAnimation.start()
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

    Rectangle {
        id: root
        anchors.fill: parent
        property string serviceStatus: null
        property string lastServiceStatus: null
        color: "white"
        signal langChangeSignal()

        UI.ZSideMenu{
            id: sideMenu
            zitemBgColor:"transparent"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: 150
            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }
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
                {
                    name:qsTr("蓝奏云解析"),
                    fontIcon:UI.ZFontIcon.fa_cloud
                },
                {
                    name:qsTr("短链生成"),
                    fontIcon:UI.ZFontIcon.fa_sort_amount_desc
                },
                {
                    name:qsTr("破解"),
                    fontIcon:UI.ZFontIcon.fa_plug
                },
                {
                    name:qsTr("Host编辑"),
                    fontIcon:UI.ZFontIcon.fa_code
                },
                {
                    name:qsTr("V2ray"),
                    fontIcon:UI.ZFontIcon.fa_paper_plane
                },
                {
                    name:qsTr("微信机器人"),
                    fontIcon:UI.ZFontIcon.fa_wechat
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
                    UI.ZTheme.primaryColor = "#EC7357"
                    break
                case 7:
                    UI.ZTheme.primaryColor = "#ff6a00"
                    break
                }
            }
        }

        Rectangle{
            id: closeRect
            color: UI.ZTheme.primaryColor
            width: 15
            height:40
            anchors.top: sideMenu.top
            anchors.topMargin: (sideMenu.height - height) / 2
            anchors.right: sideMenu.right
            anchors.rightMargin: 0
            opacity: 0.7
            z: 9999
            Behavior on anchors.rightMargin {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    if(sideMenu.width === 0){
                        sideMenu.width = 150
                        closeRect.anchors.rightMargin = 0
                    }else{
                        sideMenu.width = 0
                        closeRect.anchors.rightMargin = -15
                    }
                }
            }
            UI.ZText{
                id: fontIconText
                font.pixelSize: 10
                text: UI.ZFontIcon.fa_outdent
                font.family: UI.ZFontIcon.fontFontAwesome.name
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: 'white'
                rotation: sideMenu.width === 0 ? 180 : 0
                Behavior on rotation {
                    NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
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
                Home{}

                Database {}

//                Item{
//                    WebEngineView {
//                        anchors.fill: parent
//                        url: "http://www.ilt.me/"
//                    }
//                }

                Download{}

                LanzouParse{}
                SinaT{}
                Crack{}
                HostEdit{}
//                Upload{
//
//                }
                V2ray{}
                Wechat{}
                Setting{}
            }

        }
    }
    Connections{
        target: V2rayManager
        onStartedSignal:{
            proxyMode = setting.proxy_mode
        }
        onStopedSignal:{
            proxyMode = setting.proxy_mode
        }
        onQuitedSignal:{
            Qt.quit()
        }
    }

    Connections{
        target: aria2
        onAria2StopedSignal:{
            // 退出aria2后退出v2ray
            V2rayManager.quit()
        }
    }
}
