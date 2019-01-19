import QtQuick 2.10
import QtQuick.Controls 2.3

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
