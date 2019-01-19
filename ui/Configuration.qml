import QtQuick 2.10
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "./ui" as UI
Item {
    property int currTab: 0
    UI.ZTopMenu{
        id: configTopMenu
        height: 30
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        zmodel: [{name:qsTr("基础")},{name:qsTr("高级")},{name:qsTr("密码")}]

        zclickedCall: function(index){
            currTab = index
        }
    }

    Item {
        id: configContent
        anchors.left: parent.left
        anchors.top: configTopMenu.bottom
        anchors.right: parent.right
        anchors.bottom: bottomLay.top
        anchors.topMargin: 10
        anchors.leftMargin: 10
        StackLayout {
            id: configStackLayout
            anchors.fill: parent
            currentIndex: currTab

            Item{
                ColumnLayout{
                    spacing: 5
                    // UI.ZText{
                    //     text: "版本"
                    //     style: "h2"
                    // }
                    // UI.ZComboBox{}
                    // UI.ZText{
                    //     text: "性能模式"
                    //     style: "h2"
                    //     Layout.topMargin: 15
                    // }
                    // UI.ZComboBox{
                    //     model: ["轻量", "普通", "服务器"]
                    //     onCurrentTextChanged: {
                    //         console.log(currentText )
                    //     }
                    // }
                    UI.ZText{
                        text: qsTr("基础配置")
                        style: "h2"
                        Layout.topMargin: 5
                    }
                    UI.ZText{
                        text: qsTr("默认引擎")
                        style: "h3"
                    }
                    UI.ZComboBox{
                        id: default_storage_engine
                        model: ["INNODB", "MyISAM"]
                        Component.onCompleted: {
                            currentIndex = find(mysqlConfiguration.default_storage_engine)
                        }
                    }
                    UI.ZText{
                        text: qsTr("端口")
                        style: "h3"
                    }
                    UI.ZTextInput{
                        id: port
                        text: mysqlConfiguration.port

                    }
                    UI.ZText{
                        text: qsTr("并发数")
                        style: "h3"
                    }
                    UI.ZTextInput{
                        id: max_connections
                        text: mysqlConfiguration.max_connections
                    }

                }
            }
            Item{
                ScrollView{
                    anchors.fill: parent
                    clip: true
                    ScrollBar.horizontal.interactive: false
                    //ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                    ScrollBar.vertical.interactive: true
                    contentHeight: advancedColumnLayout.height
                    ColumnLayout{
                        id: advancedColumnLayout
                        spacing: 5
                        UI.ZText{
                            text: "back_log"
                            style: "h3"
                        }
                        UI.ZTextInput{
                            id: back_log
                            text: mysqlConfiguration.back_log
                        }
                        UI.ZText{
                            text: "thread_concurrency"
                            style: "h3"
                            Layout.topMargin: 15
                        }
                        UI.ZTextInput{

                        }

                        UI.ZText{
                            text: "key_buffer_size"
                            style: "h3"
                            Layout.topMargin: 15
                        }
                        UI.ZTextInput{
                            id: key_buffer_size
                            text: mysqlConfiguration.key_buffer_size
                        }
                        UI.ZText{
                            text: "innodb_buffer_pool_size"
                            style: "h3"
                            Layout.topMargin: 15
                        }
                        UI.ZTextInput{
                            id: innodb_buffer_pool_size
                            text: mysqlConfiguration.innodb_buffer_pool_size
                        }
                        UI.ZText{
                            text: "innodb_additional_mem_pool_size"
                            style: "h3"
                            Layout.topMargin: 15
                        }
                        UI.ZTextInput{
                            id: innodb_additional_mem_pool_size
                            text: mysqlConfiguration.innodb_additional_mem_pool_size
                        }
                        UI.ZText{
                            text: "innodb_log_buffer_size"
                            style: "h3"
                            Layout.topMargin: 15
                        }
                        UI.ZTextInput{
                            id: innodb_log_buffer_size
                            text: mysqlConfiguration.innodb_log_buffer_size
                        }
                        UI.ZText{
                            text: "query_cache_size"
                            style: "h3"
                            Layout.topMargin: 15
                        }
                        UI.ZTextInput{
                            id: query_cache_size
                            text: mysqlConfiguration.query_cache_size
                        }
                        UI.ZText{
                            text: "read_buffer_size"
                            style: "h3"
                            Layout.topMargin: 15
                        }
                        UI.ZTextInput{
                            id: read_buffer_size
                            text: mysqlConfiguration.read_buffer_size
                        }
                        UI.ZText{
                            text: "read_rnd_buffer_size"
                            style: "h3"
                            Layout.topMargin: 15
                        }
                        UI.ZTextInput{
                            id: read_rnd_buffer_size
                            text: mysqlConfiguration.read_rnd_buffer_size
                        }
                        UI.ZText{
                            text: "sort_buffer_size"
                            style: "h3"
                            Layout.topMargin: 15
                        }
                        UI.ZTextInput{
                            id: sort_buffer_size
                            text: mysqlConfiguration.sort_buffer_size
                        }
                        UI.ZText{
                            text: "tmp_table_size"
                            style: "h3"
                            Layout.topMargin: 15
                        }
                        UI.ZTextInput{
                            id: tmp_table_size
                            text: mysqlConfiguration.tmp_table_size
                        }

                    }
                }
            }
            Item{
                ColumnLayout{
                    spacing: 5

                    UI.ZText{
                        text: qsTr("重置密码")
                        style: "h2"
                        Layout.topMargin: 5
                    }
                    UI.ZText{
                        text: qsTr("当你忘记密码时可使用本功能进行密码重置")
                        color:"#7b7b7b"
                    }
                    UI.ZTextInput{
                        id: newp
                    }
                    UI.ZButton{
                        text: qsTr("修改")
                        onClicked: {
                            loading.zopen()
                            mysqlServiceManager.modifiedPassword(newp.text,root.serviceStatus=="running"?'1':'0')
                        }
                    }
                }
            }
        }
    }
    Item {
        id: bottomLay
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
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
                    mysqlConfiguration.default_storage_engine = default_storage_engine.currentText
                    mysqlConfiguration.port = port.text
                    mysqlConfiguration.max_connections = max_connections.text
                    mysqlConfiguration.back_log = back_log.text
                    mysqlConfiguration.key_buffer_size = key_buffer_size.text
                    mysqlConfiguration.innodb_buffer_pool_size = innodb_buffer_pool_size.text
                    mysqlConfiguration.innodb_additional_mem_pool_size = innodb_additional_mem_pool_size.text
                    mysqlConfiguration.innodb_log_buffer_size = innodb_log_buffer_size.text
                    mysqlConfiguration.query_cache_size = query_cache_size.text
                    mysqlConfiguration.read_buffer_size = read_buffer_size.text
                    mysqlConfiguration.read_rnd_buffer_size = read_rnd_buffer_size.text
                    mysqlConfiguration.sort_buffer_size = sort_buffer_size.text
                    mysqlConfiguration.tmp_table_size = tmp_table_size.text
                    mysqlConfiguration.writeCf()
                    cfgSaveSnackbar.open(qsTr("保存成功！"))
                }
            }
            UI.ZButton{
                id: cfgResetButton
                text: qsTr("恢复默认")
                Layout.maximumWidth:100
                onClicked: {
                    cfgResetConfirm.zopen()
                }
            }
            UI.ZSnackbar{
                id: cfgSaveSnackbar
                parent: root
            }
            UI.ZConfirm{
                id: cfgResetConfirm
                parent: root
                ztext: qsTr("确定要恢复到默认设置吗？")
                onZaccepted: {
                    console.log("cfgResetConfirm.onZaccepted")
                }
            }
        }
    }
    UI.ZLoading{
        id: loading
        parent: root
        ztitleText: qsTr("loading...")
    }
    UI.ZSnackbar{
        id: snackbar
        parent: root
    }

    property var modifiedSuccessStr: qsTr("修改成功！")
    property var modifiedSuccessFail: qsTr("修改失败！")
    // 连接信号
    Connections{
        target: mysqlServiceManager
        onPwdSignal:{
            console.log(status)
            loading.zclose()
            snackbar.open(status == "ok" ? modifiedSuccessStr : modifiedSuccessFail)
        }
    }
}
