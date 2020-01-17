import QtQuick 2.10
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.3
import "./ui" as UI

Item {
    property string zitemBgColor: "white"
    property string zitemHoverBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.3)
    property string zitemSelectedBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.4)
    property string zitemPressedBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.5)


    property var items2: null
    property ListModel listModel: ListModel {}

    property var fileDialog: null

    function fileDialogAccepted(){
        pathTextInput.text = fileDialog.folder.toString().replace("file:///","")
    }

    property var statusName: {
        "complete":qsTr("完成"),
        "paused":qsTr("暂停"),
        "error":qsTr("错误"),
        "waiting":qsTr("等待"),
        "removed":qsTr("已删除"),
    }
    property var qsTrStrings: {
        "addSuccess":qsTr("已添加"),
        "addFail":qsTr("添加失败"),
        "pauseSuccess":qsTr("已暂停"),
        "pauseFail":qsTr("暂停失败"),
        "startSuccess":qsTr("已启动"),
        "startFail":qsTr("启动失败"),
        "removeSuccess":qsTr("已删除"),
        "removeFail":qsTr("删除失败"),
    }

    Timer{
        id:timer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            aria2.selTask()
        }
    }
    Connections{
        target: window
        onVisibleChanged:{
            if(window.visible){
                aria2.selTask()
                timer.start()
            }else{
                timer.stop()
            }
        }
    }

    Component.onCompleted: {
        items2 = {}
    }
    function renderSize(value){
        if(null==value||value==''){
            return "0 Bytes";
        }
        var unitArr = new Array("Bytes","KB","MB","GB","TB","PB","EB","ZB","YB");
        var index=0;
        var srcsize = parseFloat(value);
        index=Math.floor(Math.log(srcsize)/Math.log(1024));
        var size =srcsize/Math.pow(1024,index);
        size=size.toFixed(2);//保留的小数位数
        return size+unitArr[index];
    }

    UI.ZConfirm{
        id: dialog
        parent: root
        zwidth: 500
        zheight: 300
        z: 99999
        property string downloadUrl: ""

        Rectangle {
            anchors.fill: parent
            anchors.margins: 5
            ColumnLayout{
                anchors.fill: parent
                spacing: 5
                UI.ZText{
                    text: qsTr("下载地址")
                }

                UI.ZTextInput{
                    id: zingGG
                    Layout.fillWidth: true
                    text: dialog.downloadUrl
                    onTextChanged: dialog.downloadUrl = text
                }
                UI.ZText{
                    text: qsTr("启用线程")
                }
                UI.ZTextInput{
                    id: maxConnectionPerServerTextInput
                    Layout.fillWidth: true
                    text: "16"
                }
                UI.ZText{
                    text: qsTr("保存路径")
                }
                UI.ZButton{
                    text: qsTr("选择文件夹")
                    onClicked: {
                        if(fileDialog == null){
                            var zFileDialog = Qt.createComponent("qrc:/ui/ZFileDialog.qml")
                            if (zFileDialog.status === Component.Ready) {
                                fileDialog = zFileDialog.createObject(window,{"selectExisting":true,"selectFolder":true,"selectMultiple":false});
                                fileDialog.accepted.connect(fileDialogAccepted)
                                fileDialog.open()
                            }
                        }else{
                            fileDialog.open()
                        }
                    }
                }
                UI.ZTextInput{
                    id: pathTextInput
                    text: "aria2/Download"
                    Layout.fillWidth: true
                }

                Item { Layout.fillHeight: true }
            }
        }

        onZaccepted: {
            aria2.addTask(downloadUrl,{
                              "max-connection-per-server":maxConnectionPerServerTextInput.text,
                              "dir":pathTextInput.text,
                          })
        }
    }
    RowLayout{
        id: toolBar
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 5
        spacing: 20
        height: 30
        UI.ZHref{
            font.pixelSize: 20
            text: UI.ZFontIcon.fa_plus
            font.family: UI.ZFontIcon.fontFontAwesome.name
            toolTip: qsTr("添加任务")
            onZclicked: {
                dialog.zopen()
            }
        }
        UI.ZHref{
            font.pixelSize: 20
            text: UI.ZFontIcon.fa_play
            toolTip: qsTr("开始任务")
            font.family: UI.ZFontIcon.fontFontAwesome.name
            onZclicked: {
                aria2.unpauseTask(listView.currentItem.fileId)
            }
        }
        UI.ZHref{
            font.pixelSize: 20
            text: UI.ZFontIcon.fa_pause
            toolTip: qsTr("暂停任务")
            font.family: UI.ZFontIcon.fontFontAwesome.name
            onZclicked: {
                aria2.pauseTask(listView.currentItem.fileId)
            }
        }
        UI.ZHref{
            font.pixelSize: 20
            text: UI.ZFontIcon.fa_close
            toolTip: qsTr("删除任务")
            font.family: UI.ZFontIcon.fontFontAwesome.name
            onZclicked: {
                aria2.removeTask(listView.currentItem.fileId)
            }
        }
        UI.ZHref{
            font.pixelSize: 20
            text: UI.ZFontIcon.fa_folder_open
            toolTip: qsTr("打开文件夹")
            font.family: UI.ZFontIcon.fontFontAwesome.name
            onZclicked: {
                if(listView.currentItem.filePath === ""){
                    snackbar.open(qsTr("无法获取路径"))
                    return
                }

                aria2.openDir(listView.currentItem.filePath)
            }
        }
    }
    ListView {
        id: listView
        anchors.top: toolBar.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        property string currItemStatus: null
        delegate: ItemDelegate {
            highlighted: ListView.isCurrentItem
            width: listView.width;
            height: 80
            property var fileId: gid
            property string filePath: path2
            Item {
                anchors.fill: parent
                anchors.margins: 10
                UI.ZText {
                    id: fileNameLabel
                    color: UI.ZTheme.primaryColor
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    width: parent.width
                    height: 20
                    text: fileName
                    clip: true
                    elide: Text.ElideMiddle
                }
                UI.ZText {
                    id: addressLabel
                    anchors.top: fileNameLabel.bottom
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    width: parent.width
                    height: 20
                    text: url
                    clip: true
                    elide: Text.ElideMiddle
                }
                UI.ZProgressBar{
                    id: progressBar
                    width: parent.width
                    value: completedLength / totalLength
                    anchors.top: addressLabel.bottom
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }
                UI.ZText{
                    id: downloadedFileSizeLabel
                    anchors{
                        top: progressBar.bottom
                        left: parent.left
                    }
                    text: renderSize(completedLength)
                }
                UI.ZText{
                    id: separator
                    text: " / "
                    anchors{
                        top: progressBar.bottom
                        left: downloadedFileSizeLabel.right
                    }
                }
                UI.ZText{
                    id: fileSizeLable
                    anchors{
                        top: progressBar.bottom
                        left: separator.right
                    }
                    text: renderSize(totalLength)
                }
                UI.ZText{
                    id: threadNumLabel
                    visible: status === "active"
                    anchors{
                        top: progressBar.bottom
                        left: fileSizeLable.right
                        leftMargin: 10
                    }
                    text: "Thread:"+connections
                }
                UI.ZText{
                    id: percentLabel
                    anchors{
                        top: progressBar.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    text: (completedLength / totalLength * 100).toFixed(2) + "%"
                }
                UI.ZText{
                    id: speedLabel
                    anchors{
                        top: progressBar.bottom
                        right: parent.right
                    }
                    text: status != "active" ? statusName[status] : renderSize(downloadSpeed)+"/s"
                }
            }
            onClicked: {
                listView.currentIndex = index
            }
            background: Rectangle {
                anchors.fill: parent
                color: highlighted ? zitemSelectedBgColor :
                                     (parent.hovered ? (parent.pressed ? zitemPressedBgColor : zitemHoverBgColor) : zitemBgColor)
            }
        }
        model: listModel
        clip: true
        onCurrentIndexChanged: {
            currItemStatus = listModel.get(currentIndex).status
            console.log(currItemStatus)
        }
    }

    UI.ZSnackbar{
        id: snackbar
    }
    Connections{
        target: aria2
        onMsgSignal:{

            snackbar.open(qsTrStrings[msg])
        }
    }
    Connections{
        target: aria2
        onListenerUrl:{
            zingGG.text = url
            dialog.zopen()
            window.showWindow.start()
            window.requestActivate()
        }
    }
    Connections{
        target: aria2
        onProcessSignal:{
            var taskArray = []
            var tempItems = {}
            for(var j = 1;j < process.length;j++){
                var tasks = process[j][0]
                for(var i = 0; i < tasks.length;i++){

                    var path = tasks[i]['files'][0]['path']
                    var url = tasks[i]['files'][0]['uris'][0]['uri']
                    var fileName = path.substring(path.lastIndexOf('/')+1,path.length)
                    taskArray.push({
                                       "gid": tasks[i]['gid'],
                                       "url": url,
                                       "status": tasks[i]['status'],
                                       "totalLength":Number(tasks[i]['totalLength']),
                                       "completedLength":Number(tasks[i]['completedLength']),
                                       "downloadSpeed":Number(tasks[i]['downloadSpeed']),
                                       "fileName": fileName,
                                       "path2": path,
                                       "connections": tasks[i]['connections'],
                                   })
                    tempItems[tasks[i]['gid']] = 1
                }
            }


            for(var i = listModel.count - 1;i >= 0;i--){
                var gid = listModel.get(i).gid
                var ex = listModel.get(i).gid in tempItems
                if(!ex){
                    delete items2[gid]
                    listModel.remove(i)
                }
            }


            for(var i = 0;i < taskArray.length;i++){
                var item = taskArray[i]
                var index = item['gid'] in items2

                if(index){
                    listModel.setProperty(items2[item['gid']],'completedLength',item['completedLength'])
                    listModel.setProperty(items2[item['gid']],'downloadSpeed',item['downloadSpeed'])
                    listModel.setProperty(items2[item['gid']],'status',item['status'])
                    listModel.setProperty(items2[item['gid']],'totalLength',item['totalLength'])
                    listModel.setProperty(items2[item['gid']],'fileName',item['fileName'])
                    listModel.setProperty(items2[item['gid']],'connections',item['connections'])
                    listModel.setProperty(items2[item['gid']],'path2',item['path2'])
                }else{
                    console.log(JSON.stringify(item))
                    items2[item['gid']] = listModel.count
                    listModel.append(item)
                }
            }
        }
    }
}
