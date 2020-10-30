import QtQuick 2.10
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "./ui" as UI
Item {
    property int currTab: 0
    property int confirmLabelWidth: 60
    property int confirmEditWidth: 250
    property bool webSocketState: false
    property bool initSchedulered: false

    property var editJob: {
        "name":"",
        "trigger":"",
        "wxid":"",
        "msg":"",
        "second":"",
        "minute":"",
        "hour":"",
        "day_of_week":"",
        "weeks":0, 
        "days":0, 
        "hours":0, 
        "minutes":0, 
        "seconds":0,
        "jitter":0,
        "msg_type":"text",
        "location":"",
    }
    UI.ZTopMenu{
        id: wechatTopMenu
        height: 30
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        zmodel: [{name:qsTr("监控")},{name:qsTr("任务")},{name:qsTr("配置")}]

        zclickedCall: function(index){
            currTab = index
        }
    }

    Item {
        anchors.left: parent.left
        anchors.top: wechatTopMenu.bottom
        anchors.right: parent.right
        anchors.bottom: bottomLay.top
        StackLayout {
            id: configStackLayout
            anchors.fill: parent
            currentIndex: currTab

            Item{
                UI.ZTextInput{
                    id: searchInput
                    Layout.fillWidth: true
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    text: ""
                    onTextChanged: {
                        searchUser(text)
                    }
                }

                ListView {
                    id: listView
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: searchInput.top
                    width: 150

                    property string currItemStatus
                    property string zviewBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.05)
                    property string zitemBgColor: "white"
                    property string zitemHoverBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.1)
                    property string zitemSelectedBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.2)
                    property string zitemPressedBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.3)
                    property var listModelArray: []

                    property ListModel listModel: ListModel {
                    }

                    Rectangle{
                        anchors.fill: parent
                        color: listView.zviewBgColor
                        z: -1
                    }
                    delegate: ItemDelegate {
                        highlighted: ListView.isCurrentItem
                        width: listView.width;
                        height: 60
                        Item {
                            anchors.fill: parent
                            anchors.margins: 10
                            UI.ZText {
                                id: nameLabel
                                font.pixelSize: 11
                                color: UI.ZTheme.primaryColor
                                anchors.top: parent.top
                                anchors.topMargin: 0
                                anchors.left: parent.left
                                anchors.leftMargin: 0
                                height: parent.height / 2
                                width: 140
                                text: name
                                clip: true
                                elide: Text.ElideMiddle
                            }

                            UI.ZText {
                                id: wxidLabel
                                font.pixelSize: nameLabel.font.pixelSize
                                color: UI.ZTheme.primaryColor
                                anchors.top: nameLabel.bottom
                                anchors.topMargin: 0
                                anchors.left: parent.left
                                anchors.leftMargin: 0
                                width: nameLabel.width
                                height: nameLabel.height
                                text: wxid
                                clip: true
                                elide: Text.ElideMiddle
                            }
                        }
                        onClicked: {
                            // listView.currentIndex = index
                            lanzouParse.paste(wxidLabel.text)
                            mainSnackbar.open(qsTr("wxid已复制到剪贴板"))
                        }
                        background: Rectangle {
                            anchors.fill: parent
                            color: highlighted ? listView.zitemSelectedBgColor :
                                                (parent.hovered ? (parent.pressed ? listView.zitemPressedBgColor : listView.zitemHoverBgColor) : listView.zitemBgColor)
                        }
                    }
                    model: listModel
                    clip: true
                    onCurrentIndexChanged: {
                        // currItemStatus = listModel.get(currentIndex).status
                        // console.log(currItemStatus)
                    }
                }

                Flickable {
                    id: sview
                    anchors.leftMargin: 5
                    anchors.topMargin: 5
                    anchors.top: parent.top
                    anchors.left: listView.right
                    anchors.right: parent.right
                    anchors.bottom: messageTextAreaScrollView.top
                    clip: true
                    contentHeight: logTextArea.height

                    ScrollBar.vertical: ScrollBar {
                        parent: sview.parent
                        anchors.top: sview.top
                        anchors.right: sview.right
                        anchors.bottom: sview.bottom
                        policy: sview.contentHeight > sview.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    }
            
                    TextEdit {
                        id: logTextArea
                        selectByMouse: true
                        antialiasing: true
                        font.pixelSize: 10
                        font.family:"arial"
                        text: ""
                        width: sview.width
                        readOnly: true
                        wrapMode: TextEdit.Wrap
                        selectionColor: "#EC7357"

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            cursorShape: Qt.IBeamCursor
                            onClicked: {
                                if (mouse.button === Qt.RightButton)
                                    var start = logTextArea.selectionStart
                                    var end = logTextArea.selectionEnd
                                    logContextMenu.popup()
                                    logTextArea.select(start,end)
                            }

                            Menu {
                                id: logContextMenu
                                MenuItem { 
                                    text: qsTr("复制")
                                    onTriggered: logTextArea.copy()
                                }
                                MenuItem { 
                                    text: qsTr("Clear")
                                    onTriggered: logTextArea.clear()
                                }
                            }
                        }
                    }
                }

                ScrollView {
                    id: messageTextAreaScrollView
                    anchors.bottom: parent.bottom
                    anchors.left: listView.right
                    anchors.right: operationRect.left
                    anchors.rightMargin: -1
                    anchors.top: operationRect.top
                    background:  Rectangle {
                        anchors.fill: parent
                        implicitWidth:  parent.width
                        implicitHeight:  parent.height
                        border.color: messageTextArea.enabled ? listView.zitemPressedBgColor : "transparent"
                    }
                    TextArea {
                        id: messageTextArea
                        selectByMouse: true
                        antialiasing: true
                        font.pixelSize: 10
                        font.family:"arial"
                        text: ""

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            cursorShape: Qt.IBeamCursor
                            onClicked: {
                                if (mouse.button === Qt.RightButton)
                                    var start = messageTextArea.selectionStart
                                    var end = messageTextArea.selectionEnd
                                    messageContextMenu.popup()
                                    messageTextArea.select(start,end)
                            }

                            Menu {
                                id: messageContextMenu
                                MenuItem {
                                    text: qsTr("剪贴")
                                    onTriggered: messageTextArea.cut()
                                }
                                MenuItem { 
                                    text: qsTr("复制")
                                    onTriggered: messageTextArea.copy()
                                }
                                MenuItem { 
                                    text: qsTr("粘贴")
                                    onTriggered: messageTextArea.paste()
                                }
                            }
                        }
                    }
                }

                Rectangle{
                    id: operationRect
                    color: "#00000000"
                    width: 100
                    height:100
                    border.color: listView.zitemPressedBgColor

                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    UI.ZTextInput{
                        id: wxidTextInput
                        text: ""
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                        placeholderText: "请输入WXID"
                    }

                    UI.ZButton{
                        id: sendButton
                        text: qsTr("发送")
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter

                        onClicked: {
                            wechatManager.sendMessage(wxidTextInput.text, messageTextArea.text)
                        }
                    }
                }
            }

            Item{
                UI.ZConfirm{
                    id: dialog
                    ztitleText: qsTr('编辑')
                    parent: root
                    zwidth: 500
                    zheight: 500
                    z: 99999
                    property string downloadUrl: ""

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 5

                        ScrollView{
                            anchors.fill: parent
                            clip: true
                            ScrollBar.horizontal.interactive: false
                            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                            ScrollBar.vertical.interactive: true
                            contentHeight: configColumnLayout.height
                            contentWidth: parent.width - 10
                            ColumnLayout{
                                id: configColumnLayout
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                spacing: 10

                                RowLayout{
                                    spacing: 20
                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("名称")
                                    }

                                    UI.ZTextInput{
                                        id: nameTextInput
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        text: editJob.name
                                    }
                                }

                                RowLayout{
                                    spacing: 20
                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("WXID")
                                    }

                                    UI.ZTextInput{
                                        id: wxidTextInput2
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        text: editJob.wxid
                                    }
                                }

                                RowLayout{
                                    spacing: 20

                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("消息类型")
                                    }

                                    UI.ZComboBox{
                                        id: msgTypeComboBox
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        model: ["固定文本", "天气消息"]
                                        Component.onCompleted: {
                                            // currentIndex = find(editNode.type)
                                        }
                                    }
                                }

                                RowLayout{
                                    visible: msgTypeComboBox.currentIndex == 1
                                    spacing: 20
                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("地区代码")
                                    }

                                    UI.ZTextInput{
                                        id: locationTextInput
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        text: editJob.location
                                    }
                                }

                                RowLayout{
                                    visible: msgTypeComboBox.currentIndex == 0
                                    spacing: 20
                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("固定文本消息")
                                    }

                                    UI.ZTextInput{
                                        id: msgTextInput
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        text: editJob.msg
                                    }
                                }

                                RowLayout{
                                    spacing: 20

                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("触发类型")
                                    }

                                    UI.ZComboBox{
                                        id: triggerComboBox
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        model: ["interval", "cron"]
                                        Component.onCompleted: {
                                            // currentIndex = find(editNode.type)
                                        }
                                    }
                                }

                                RowLayout{
                                    visible: triggerComboBox.currentIndex == 1
                                    spacing: 20
                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("周几")
                                    }

                                    UI.ZTextInput{
                                        id: dayOfWeekTextInput
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        text: editJob.day_of_week
                                    }
                                }

                                RowLayout{
                                    visible: triggerComboBox.currentIndex == 1
                                    spacing: 20
                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("时")
                                    }

                                    UI.ZTextInput{
                                        id: hourTextInput
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        text: editJob.hour
                                    }
                                }

                                RowLayout{
                                    visible: triggerComboBox.currentIndex == 1
                                    spacing: 20
                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("分")
                                    }

                                    UI.ZTextInput{
                                        id: minuteTextInput
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        text: editJob.minute
                                    }
                                }

                                RowLayout{
                                    visible: triggerComboBox.currentIndex == 1
                                    spacing: 20
                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("秒")
                                    }

                                    UI.ZTextInput{
                                        id: secondTextInput
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        text: editJob.second
                                    }
                                }

                                RowLayout{
                                    visible: triggerComboBox.currentIndex == 0
                                    spacing: 20
                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("几周")
                                    }

                                    UI.ZTextInput{
                                        id: weeksTextInput
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        text: editJob.weeks
                                    }
                                }

                                RowLayout{
                                    visible: triggerComboBox.currentIndex == 0
                                    spacing: 20
                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("几天")
                                    }

                                    UI.ZTextInput{
                                        id: daysTextInput
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        text: editJob.days
                                    }
                                }

                                RowLayout{
                                    visible: triggerComboBox.currentIndex == 0
                                    spacing: 20
                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("几小时")
                                    }

                                    UI.ZTextInput{
                                        id: hoursTextInput
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        text: editJob.hours
                                    }
                                }

                                RowLayout{
                                    visible: triggerComboBox.currentIndex == 0
                                    spacing: 20
                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("几分钟")
                                    }

                                    UI.ZTextInput{
                                        id: minutesTextInput
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        text: editJob.minutes
                                    }
                                }

                                RowLayout{
                                    visible: triggerComboBox.currentIndex == 0
                                    spacing: 20
                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("几秒")
                                    }

                                    UI.ZTextInput{
                                        id: secondsTextInput
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        text: editJob.seconds
                                    }
                                }

                                RowLayout{
                                    spacing: 20
                                    UI.ZText{
                                        Layout.preferredWidth: confirmLabelWidth
                                        text: qsTr("抖动秒数")
                                    }

                                    UI.ZTextInput{
                                        id: jitterTextInput
                                        Layout.fillWidth: true
                                        width: confirmEditWidth
                                        text: editJob.jitter
                                    }
                                }

                            }
                        }
                            
                    }

                    onZaccepted: {
                        console.log(dialog.ztitleText)
                        var savedJob = {
                            name:nameTextInput.text,
                            job_enable:false,
                            wxid:wxidTextInput2.text,
                            msg:msgTextInput.text,
                            trigger:triggerComboBox.displayText,
                            second:secondTextInput.text,
                            minute:minuteTextInput.text,
                            hour:hourTextInput.text,
                            day_of_week:dayOfWeekTextInput.text,
                            weeks:weeksTextInput.text, 
                            days:daysTextInput.text, 
                            hours:hoursTextInput.text, 
                            minutes:minutesTextInput.text, 
                            seconds:secondsTextInput.text,
                            jitter:jitterTextInput.text,
                            location:locationTextInput.text,
                            msg_type: msgTypeComboBox.currentIndex == 0 ? "text" : msgTypeComboBox.currentIndex == 1 ? "weather" : "text"
                        }
                        if(dialog.ztitleText == '添加'){
                            wechatManager.addJob(savedJob)

                        }else{
                            savedJob.job_id = editJob.job_id
                            savedJob.job_enable = editJob.job_enable
                            wechatManager.editJob(savedJob)
                        }
                        getJobList()
                    }
                }
                UI.ZButton{
                    id: addJobButton
                    text: qsTr("添加")
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    enabled: initSchedulered

                    onClicked: {
                        dialog.ztitleText = "添加"
                        editJob = {
                            "name":"",
                            "trigger":"",
                            "wxid":"",
                            "msg":"",
                            "second":"",
                            "minute":"",
                            "hour":"",
                            "day_of_week":"",
                            "weeks":0, 
                            "days":0, 
                            "hours":0, 
                            "minutes":0, 
                            "seconds":0,
                            "jitter":0,
                            "msg_type":"text",
                            "location":"",
                        }

                        dialog.zopen()
                    }
                }
                ListView {
                    id: jobListView
                    anchors.top: addJobButton.bottom
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    property string currItemStatus: ""
                    property string zviewBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.05)
                    property string zitemBgColor: "white"
                    property string zitemHoverBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.1)
                    property string zitemSelectedBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.2)
                    property string zitemPressedBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.3)
                    property var jobList: []
                    property ListModel jobListModel: ListModel {
                    }

                    Rectangle{
                        anchors.fill: parent
                        color: jobListView.zviewBgColor
                        z: -1
                    }
                    delegate: ItemDelegate {
                        // highlighted: ListView.isCurrentItem
                        width: jobListView.width;
                        height: 60
                        Item {
                            anchors.fill: parent
                            anchors.margins: 10
                            UI.ZText {
                                id: nameLabel
                                font.pixelSize: 11
                                color: UI.ZTheme.primaryColor
                                anchors.top: parent.top
                                anchors.topMargin: 0
                                anchors.left: parent.left
                                anchors.leftMargin: 0
                                height: parent.height / 2
                                width: 140
                                text: name
                                clip: true
                                elide: Text.ElideMiddle
                            }

                            UI.ZText {
                                id: triggerLabel
                                font.pixelSize: nameLabel.font.pixelSize
                                color: UI.ZTheme.primaryColor
                                anchors.top: nameLabel.bottom
                                anchors.topMargin: 0
                                anchors.left: parent.left
                                anchors.leftMargin: 0
                                width: nameLabel.width
                                height: nameLabel.height
                                text: trigger
                                clip: true
                                elide: Text.ElideMiddle
                            }

                            UI.ZText {
                                id: nextRunTimeLabel
                                visible: enableSwitch.checked
                                font.pixelSize: nameLabel.font.pixelSize
                                color: UI.ZTheme.primaryColor
                                anchors.top: nameLabel.bottom
                                anchors.topMargin: 0
                                anchors.left: triggerLabel.right
                                anchors.leftMargin: 10
                                width: nameLabel.width
                                height: nameLabel.height
                                text: next_run_time
                                clip: true
                                elide: Text.ElideMiddle
                            }

                            UI.ZSwitch {
                                id: enableSwitch
                                anchors.right: editJobButton.left
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                checked:job_enable
                                onClicked: {
                                    var currJob = jobListView.jobList[index]
                                    currJob['job_enable'] = checked
                                    wechatManager.editJob(currJob)
                                    getJobList()
                                }
                            }

                            UI.ZButton{
                                id: editJobButton
                                text: qsTr("编辑")
                                anchors.right: delJobButton.left
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                width: 55
                                height: 25
                                zfontSize: 10

                                onClicked: {
                                    dialog.ztitleText = "编辑"
                                    editJob = Object.assign({}, jobListView.jobList[index])
                                    triggerComboBox.currentIndex = triggerComboBox.find(editJob.trigger)
                                    msgTypeComboBox.currentIndex = editJob.msg_type == "text" ? 0 : editJob.msg_type == "weather" ? 1 : 0 
                                    dialog.zopen()
                                }
                            }
                            UI.ZButton{
                                id: delJobButton
                                text: qsTr("删除")
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                width: 55
                                height: 25
                                zfontSize: 10

                                onClicked: {
                                    wechatManager.delJob(jobListView.jobList[index]['job_id'])
                                    getJobList()
                                }
                            }
                        }
                        onClicked: {
                            // jobListView.currentIndex = index
                        }
                        background: Rectangle {
                            anchors.fill: parent
                            color: highlighted ? jobListView.zitemSelectedBgColor :
                                                (parent.hovered ? (parent.pressed ? jobListView.zitemPressedBgColor : jobListView.zitemHoverBgColor) : jobListView.zitemBgColor)
                        }
                    }
                    model: jobListView.jobListModel
                    clip: true
                    onCurrentIndexChanged: {
                        // currItemStatus = jobListView.listModel.get(currentIndex).status
                        // console.log(currItemStatus)
                    }
                }
            }

            Item{
                ColumnLayout{
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    width: parent.width
                    spacing: 5

                    UI.ZText{
                        text: qsTr("和风天气KEY")
                    }

                    UI.ZTextInput{
                        id: qweatherKeyTextInput
                    }
                    UI.ZButton{
                        id: saveCfgButton
                        text: qsTr("保存")
                        width: 55
                        height: 25
                        zfontSize: 10

                        onClicked: {
                            setting.qweather_key = qweatherKeyTextInput.text
                            mainSnackbar.open(qsTr("保存成功"))
                        }
                    }
                }
            }
        }
        Component.onCompleted:{
            qweatherKeyTextInput.text = setting.qweather_key
        }
    }
    Rectangle {
        id: bottomLay
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        color: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.2)
        UI.ZText{
            id: sText
            text: qsTr("连接状态：")
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 5
        }

        UI.ZText{
            id: statusText
            text: webSocketState ? qsTr("已连接") : qsTr("未连接")
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: sText.right
            anchors.leftMargin: 5
        }



        RowLayout{
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 10
            layoutDirection: Qt.RightToLeft
            UI.ZButton{
                id: cfgSaveButton
                text: webSocketState ? qsTr("重连") : qsTr("注入并连接")
                Layout.maximumWidth:100
                Layout.rightMargin: 10

                onClicked: {
                    wechatManager.hook()
                }
            }
        }
    }
    Connections{
        target: wechatManager
        function onUserListSignal(userList){
            listView.listModel.clear()
            listView.listModelArray = userList.content
            for(var i = 0; i < listView.listModelArray.length; i++){
                var item = listView.listModelArray[i]
                listView.listModel.append({
                    name:item['name'],
                    wxid:item['wxid'],
                })
            }
        }
        function onWechatLogSignal(log){
            if(logTextArea.lineCount > 500){
                //logTextArea.remove(0, logTextArea.text.indexOf("\n") + 1)
                logTextArea.clear()
            }
            if(sview.contentY >= sview.contentHeight - sview.height){
                logTextArea.append(log)
                sview.contentY = sview.contentHeight > sview.height ? sview.contentHeight - sview.height : 0
            }else{
                logTextArea.append(log)
            }
        }
        function onWebsocketStateSignal(state) {
            webSocketState = state
            if(state){
                mainSnackbar.open(qsTr("Websocket连接成功"))
                wechatManager.getUserList()
            }else{
                mainSnackbar.open(qsTr("Websocket连接错误"))
            }
        }
        function onJobExedSignal() {
            console.log(job_id+"执行完成")
            getJobList()
        }
        function onHookStateSignal(state){
            if(state == 'SUCCESS'){
                wechatManager.websocketInit()
                if(!initSchedulered){
                    wechatManager.initScheduler()
                    getJobList()
                    initSchedulered = true
                }
            }else if(state == 'ERROR'){
                mainSnackbar.open(qsTr("注入出错"))
            }else if(state == 'NOT_FOUND_WECHAT'){
                mainSnackbar.open(qsTr("请先启动微信"))
            }
        }
    }

    function getJobList(){
        var jobs = wechatManager.getJobsConf()
        jobListView.jobList = jobs
        jobListView.jobListModel.clear()
        var jobsState = wechatManager.getJobsState()
        for(var i = 0; i < jobs.length; i++){
            var item = jobs[i]
            jobListView.jobListModel.append({
                job_id:item['job_id'],
                job_enable:item['job_enable'],
                name:item['name'],
                trigger:item['trigger'],
                msg:item['msg'],
                second:item['second'],
                minute:item['minute'],
                hour:item['hour'],
                day_of_week:item['day_of_week'],
                weeks:item['weeks'], 
                days:item['days'], 
                hours:item['hours'], 
                minutes:item['minutes'], 
                seconds:item['seconds'],
                jitter:item['jitter'],
                msg_type:item['msg_type'],
                location:item['location'],
                next_run_time:jobsState[item['job_id']] ? jobsState[item['job_id']] : '',
            })
        }
    }

    function searchUser(str){
        listView.listModel.clear()
        for(var i = 0; i < listView.listModelArray.length; i++){
            var item = listView.listModelArray[i]
            if(str == "" || item['name'].search(str) != -1){
                listView.listModel.append({
                    name:item['name'],
                    wxid:item['wxid'],
                })
            }
            
        }
    }
}
