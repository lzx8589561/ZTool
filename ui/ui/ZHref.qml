import QtQuick 2.11
import QtQuick.Controls 2.4

ZText {
    signal zclicked()
    property string zhref: null
    property alias hovered: mouseArea.containsMouse
    color: hovered ? Qt.darker(ZTheme.primaryColor, 1.2) : ZTheme.primaryColor

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
