import QtQuick 2.11
import QtQuick.Window 2.2
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import "./ui" as UI

Item {
    ColumnLayout{
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        width: parent.width
        spacing: 20
        UI.ZText{
            text: "Hello "+system.username
            style: "h1"
            color: UI.ZTheme.primaryColor
        }

        ColumnLayout{
            spacing: 5
            UI.ZText{
                text: qsTr("链接")
                style: "h2"
            }
            RowLayout{
                spacing: 20
                UI.ZHref{
                    text: qsTr("官方网站")
                    style: "h3"
                    zhref: "http://www.ilt.me"
                }
                UI.ZHref{
                    text: qsTr("开源地址")
                    style: "h3"
                    zhref: "https://github.com/lzx8589561/"
                }
                UI.ZHref{
                    text: qsTr("个人博客")
                    style: "h3"
                    zhref: "http://www.ilt.me"
                }
            }
        }

        ColumnLayout{
            spacing: 5
            UI.ZText{
                text: qsTr("联系方式")
                style: "h2"
            }
            RowLayout{
                spacing: 20
                UI.ZHref{
                    text: qsTr("QQ:8589561")
                    style: "h3"
                }
                UI.ZHref{
                    text: "Email:8589561@qq.com"
                    style: "h3"
                }
            }
        }

        ColumnLayout{
            spacing: 5
            UI.ZText{
                text: qsTr("公告")
                style: "h2"
            }
            UI.ZHref{
                text: "新版本1.01发布！"
                style: "h3"
            }
            UI.ZHref{
                text: "大家有什么问题请随时找我反馈"
                style: "h3"
            }

        }
    }
}
