import QtQuick 2.10
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "./ui" as UI

Item {

    property ListModel listModel: ListModel {
    }

    UI.ZLoading{
        id: loading
        parent: root
        ztitleText: qsTr("loading...")
    }

    property string zviewBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.05)
    property string zitemBgColor: "white"
    property string zitemHoverBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.1)
    property string zitemSelectedBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.2)
    property string zitemPressedBgColor: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.3)

    property var localNodes: null
    property var editNode: {
        "add":"cloud.ilt.me",
        "aid":"2","host":"cloud.ilt.me",
        "id":"b99711a8-9f99-4471-8fd6-0c8f9f2363bf",
        "net":"ws",
        "oldps":"wulabing_cloud.ilt.me",
        "path":"/90066c89/",
        "port":"443",
        "prot":"vmess",
        "ps":"wulabing_cloud.ilt.me",
        "tls":"tls",
        "type":"none"
    }
    property int confirmLabelWidth: 60
    property int confirmEditWidth: 250

    UI.ZConfirm{
        id: dialog
        ztitleText: qsTr('编辑节点')
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
                            text: qsTr("别名")
                        }

                        UI.ZTextInput{
                            id: psTextInput
                            Layout.fillWidth: true
                            width: confirmEditWidth
                            text: editNode.ps
                        }
                    }

                    RowLayout{
                        spacing: 20

                        UI.ZText{
                            Layout.preferredWidth: confirmLabelWidth
                            text: qsTr("地址")
                        }

                        UI.ZTextInput{
                            id: addTextInput
                            Layout.fillWidth: true
                            width: confirmEditWidth
                            text: editNode.add
                            // Layout.preferredWidth: 300
                        }
                    }
                    

                    RowLayout{
                        spacing: 20
                        UI.ZText{
                            Layout.preferredWidth: confirmLabelWidth
                            text: qsTr("端口")
                        }

                        UI.ZTextInput{
                            id: portTextInput
                            Layout.fillWidth: true
                            width: confirmEditWidth
                            text: editNode.port
                        }
                    }

                    RowLayout{
                        spacing: 20
                        UI.ZText{
                            Layout.preferredWidth: confirmLabelWidth
                            text: qsTr("用户ID")
                        }

                        UI.ZTextInput{
                            id: idTextInput
                            Layout.fillWidth: true
                            width: confirmEditWidth
                            text: editNode.id
                        }
                    }

                    RowLayout{
                        spacing: 20
                        UI.ZText{
                            Layout.preferredWidth: confirmLabelWidth
                            text: qsTr("额外ID")
                        }

                        UI.ZTextInput{
                            id: aidTextInput
                            Layout.fillWidth: true
                            width: confirmEditWidth
                            text: editNode.aid
                        }
                    }

                    RowLayout{
                        spacing: 20
                        UI.ZText{
                            Layout.preferredWidth: confirmLabelWidth
                            text: qsTr("加密方式")
                        }

                        UI.ZComboBox{
                            id: typeComboBox
                            Layout.fillWidth: true
                            width: confirmEditWidth
                            model: ["auto", "aes-128-gcm","chacha20-poly1305","none"]
                            Component.onCompleted: {
                                // currentIndex = find(editNode.type)
                            }
                        }
                    }


                    RowLayout{
                        spacing: 20
                        UI.ZText{
                            Layout.preferredWidth: confirmLabelWidth
                            text: qsTr("传输协议")
                        }

                        UI.ZComboBox{
                            id: netComboBox
                            Layout.fillWidth: true
                            width: confirmEditWidth
                            model: ["tcp", "kcp","ws","h2","quic"]
                            Component.onCompleted: {
                                // currentIndex = find(editNode.net)
                            }
                        }
                    }

                    RowLayout{
                        spacing: 20
                        UI.ZText{
                            Layout.preferredWidth: confirmLabelWidth
                            text: qsTr("伪装域名")
                        }

                        UI.ZTextInput{
                            id: hostTextInput
                            Layout.fillWidth: true
                            width: confirmEditWidth
                            text: editNode.host
                        }
                    }

                    RowLayout{
                        spacing: 20
                        UI.ZText{
                            Layout.preferredWidth: confirmLabelWidth
                            text: qsTr("路径")
                        }

                        UI.ZTextInput{
                            id: pathTextInput
                            Layout.fillWidth: true
                            width: confirmEditWidth
                            text: editNode.path
                        }
                    }

                    RowLayout{
                        spacing: 20
                        UI.ZText{
                            Layout.preferredWidth: confirmLabelWidth
                            text: qsTr("TLS")
                        }

                        UI.ZComboBox{
                            id: tlsComboBox
                            Layout.fillWidth: true
                            width: confirmEditWidth
                            model: ["", "tls"]
                            Component.onCompleted: {
                                // currentIndex = find(editNode.net)
                            }
                        }
                    }
                }
            }
                
        }

        onZaccepted: {
            editNode.oldps = editNode.ps
            editNode.add = addTextInput.text
            editNode.port = portTextInput.text
            editNode.id = idTextInput.text
            editNode.aid = aidTextInput.text
            editNode.type = typeComboBox.displayText
            editNode.net = netComboBox.displayText
            editNode.ps = psTextInput.text
            editNode.path = pathTextInput.text
            editNode.host = hostTextInput.text
            editNode.tls = tlsComboBox.displayText

            console.log('修改之后：',JSON.stringify(editNode))
            if(V2rayManager.editNode(editNode) == ''){
                mainSnackbar.open(qsTr('修改成功'))
                selNode()
            }
            // netComboBox.currentIndex = netComboBox.find(editNode.net)
            // typeComboBox.currentIndex = typeComboBox.find(editNode.type)
            
        }
    }

    property var protocolLabelStr: qsTr("协议：")
    property var nameLabelStr: qsTr('名称：')
    property var addrLabelStr: qsTr("地址：")
    property var enableButtonStr: qsTr("启用")
    property var editButtonStr: qsTr("编辑")
    property var delButtonStr: qsTr("删除")

    ListView {
        id: listView
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: bottomLay.top
        width: 200

        property string currItemStatus: null

        Rectangle{
            anchors.fill: parent
            color: zviewBgColor
            z: -1
        }
        delegate: ItemDelegate {
            highlighted: ListView.isCurrentItem
            width: listView.width;
            height: 100
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
                    height: parent.height / 3
                    width: 140
                    text: nameLabelStr + name
                    clip: true
                    elide: Text.ElideMiddle
                }

                UI.ZText {
                    id: protocolLabel
                    font.pixelSize: nameLabel.font.pixelSize
                    color: UI.ZTheme.primaryColor
                    anchors.top: nameLabel.bottom
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    width: nameLabel.width
                    height: nameLabel.height
                    text: protocolLabelStr + protocol
                    clip: true
                    elide: Text.ElideMiddle
                }
                
                UI.ZText {
                    id: urlLabel
                    font.pixelSize: nameLabel.font.pixelSize
                    color: UI.ZTheme.primaryColor
                    anchors.top: protocolLabel.bottom
                    anchors.topMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    width: nameLabel.width
                    height: nameLabel.height
                    text: addrLabelStr + url
                    clip: true
                    elide: Text.ElideMiddle
                }

                UI.ZButton {
                    id: enableButton
                    // style: 'success'
                    text: enableButtonStr
                    anchors.top: parent.top
                    anchors.topMargin: 2
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    width: 50
                    height: parent.height / 3 - 4

                    onClicked: {
                        listView.currentIndex = index
                        setting.proxy_node = name
                        var r = V2rayManager.changeNode(name)
                        if(r == ''){
                            mainSnackbar.open(qsTr('切换成功，正在重启'))
                        }
                    }
                }

                UI.ZButton {
                    id: editButton
                    text: editButtonStr
                    anchors.top: enableButton.bottom
                    anchors.topMargin: 4
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    width: enableButton.width
                    height: enableButton.height

                    onClicked: {
                        editNode = Object.assign({}, localNodes[name])
                        netComboBox.currentIndex = netComboBox.find(editNode.net)
                        typeComboBox.currentIndex = typeComboBox.find(editNode.type)
                        tlsComboBox.currentIndex = tlsComboBox.find(editNode.tls)
                        dialog.zopen()
                    }
                }

                UI.ZButton {
                    id: delButton
                    // style: 'error'
                    text: delButtonStr
                    anchors.top: editButton.bottom
                    anchors.topMargin: 4
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    width: enableButton.width
                    height: enableButton.height

                    onClicked: {
                        if(setting.proxy_node == name){
                            mainSnackbar.open(qsTr('不能删除当前节点'))
                            return
                        }

                        V2rayManager.delNode(name)
                        selNode()
                    }
                }
            }
            onClicked: {
                // listView.currentIndex = index
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
        anchors.bottom: bottomLay.top
        clip: true
        contentHeight: textArea.height

        ScrollBar.vertical: ScrollBar {
            parent: sview.parent
            anchors.top: sview.top
            anchors.right: sview.right
            anchors.bottom: sview.bottom
            policy: sview.contentHeight > sview.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        }
  
        TextEdit {
            id: textArea
            selectByMouse: true
            antialiasing: true
            font.pixelSize: 10
            font.family:"arial"
            text: ""
            width: sview.width
            wrapMode: TextEdit.Wrap

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                cursorShape: Qt.IBeamCursor
                onClicked: {
                    if (mouse.button === Qt.RightButton)
                        var start = textArea.selectionStart
                        var end = textArea.selectionEnd
                        contextMenu.popup()
                        textArea.select(start,end)
                }

                Menu {
                    id: contextMenu
                    MenuItem { 
                        text: qsTr("复制")
                        onTriggered: textArea.copy()
                    }
                }
            }
        }
  }

  property var parseSuccessStr: qsTr("解析成功，请重启代理")
  property var linkErrorStr: qsTr("无法解析的链接格式")
  property var parseErrorStr: qsTr("解析失败")
  property var nonsupportProtocolStr: qsTr("不支持的协议类型")

  property var proxyMode: setting.proxy_mode
  property var pacUpdSuccessStr: qsTr("更新PAC成功")
  property var pacUpdErrorStr: qsTr("更新失败，请在代理开启后更新")

  Rectangle {
        id: bottomLay
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        color: Qt.rgba(UI.ZTheme.primaryColor.r, UI.ZTheme.primaryColor.g, UI.ZTheme.primaryColor.b, 0.2)

        
        RowLayout{
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 10
            layoutDirection: Qt.RightToLeft

            UI.ZCheckBox{
                id:checkBoxProxy
                text: qsTr("全局代理")
                checked: proxyMode == 'ProxyOnly'
                onClicked: {
                    loading.zopen()
                    
                    if(checked){
                        setting.proxy_mode = 'ProxyOnly'
                        V2rayManager.start()
                    }else{
                        setting.proxy_mode = 'Off'
                        V2rayManager.stop()
                    }
                }
            }

            UI.ZCheckBox{
                id:checkBoxPac
                text: qsTr("PAC")
                checked: proxyMode == 'PacOnly'
                onClicked: {
                    
                    if(V2rayManager.checkPac() == 'error'){
                        mainSnackbar.open(qsTr('PAC异常，请先更新PAC'))
                        checked = false
                        return
                    }
                    loading.zopen()
                    if(checked){
                        setting.proxy_mode = 'PacOnly'
                        V2rayManager.start()
                    }else{
                        setting.proxy_mode = 'Off'
                        V2rayManager.stop()
                    }
                }
            }

            UI.ZButton{
                text: qsTr("剪贴板导入")
                onClicked: {
                    var r = V2rayManager.parse()
                    if(r === ''){
                        mainSnackbar.open(parseSuccessStr)
                        selNode()
                    }else if(r === '无法解析的链接格式'){
                        mainSnackbar.open(linkErrorStr)
                    }else if(r === '解析失败'){
                        mainSnackbar.open(parseErrorStr)
                    }else if(r === '不支持的协议类型'){
                        mainSnackbar.open(nonsupportProtocolStr)
                    }
                }
            }

            UI.ZButton{
                text: qsTr("PAC更新")
                onClicked: {
                    loading.zopen()
                    V2rayManager.updPac()
                }
            }
        }
    }
    Connections{
        target: V2rayManager
        onV2rayLogSignal:{
            if(sview.contentY >= sview.contentHeight - sview.height){
                textArea.append(log)
                sview.contentY = sview.contentHeight > sview.height ? sview.contentHeight - sview.height : 0
            }else{
                textArea.append(log)
            }
            
        }
        onStartedSignal:{
            proxyMode = setting.proxy_mode
            loading.zclose()
        }
        onStopedSignal:{
            proxyMode = setting.proxy_mode
            loading.zclose()
        }
        onUpdPacStateSignal:{
            loading.zclose()
            if(state == 'success'){
                mainSnackbar.open(pacUpdSuccessStr)
            }else if(state == 'error'){
                mainSnackbar.open(pacUpdErrorStr)
            }
        }
    }
    Connections{
        target: root

        // 监听语言变化，修复位置按钮错位问题
        onLangChangeSignal:{
            selNode()
        }
    }
    Component.onCompleted:{
        if(setting.proxy_mode != 'Off'){
            V2rayManager.start()
        }else{
            V2rayManager.stop()
        }
        selNode()
        
    }

    function selNode(){
        listModel.clear()
        localNodes = V2rayManager.sel().local
        for(var index in Object.keys(localNodes)){
            var name = Object.keys(localNodes)[index]
            var item = localNodes[name]
            listModel.append({
                name:item['ps'],
                protocol:item['prot'],
                url:item['host'],
                checked:false,
            })

            if(setting.proxy_node == item['ps']){
                listView.currentIndex = index
            }
        }
    }
}
