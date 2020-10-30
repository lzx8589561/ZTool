import QtQuick 2.10
import QtQuick.Controls 2.3

ZText {
    signal zclicked()
    property string zhref
    property alias hovered: mouseArea.containsMouse
    property string toolTip: ""
    color: hovered ? Qt.darker(ZTheme.primaryColor, 1.2) : ZTheme.primaryColor
    ToolTip.visible:((toolTip != "") && hovered)
    ToolTip.delay: 200
    ToolTip.text: toolTip

    MouseArea{
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
            if(zhref != null){
                Qt.openUrlExternally(zhref)
            }
            zclicked()
        }
    }
}
