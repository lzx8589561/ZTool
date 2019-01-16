import QtQuick 2.11
import QtQuick.Controls 2.4

ComboBox {
    id: control
    model: ["First", "Second", "Third"]
    property color zpressedColor: Qt.darker(ZTheme.primaryColor, 1.2)
    property color zcolor: ZTheme.primaryColor
    signal zitemClicked()


    delegate: ItemDelegate {
        width: control.width
        contentItem: ZText {
            text: modelData
            color: control.zcolor
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        highlighted: control.highlightedIndex === index
        onClicked: {
            currentIndex = index
            zitemClicked()
        }
    }

    indicator: ZText{
        font.family: ZFontIcon.fontFontAwesome.name
        font.pixelSize: 25
        text: ZFontIcon.fa_caret_down
        anchors{
            top: parent.top
            topMargin: (control.availableHeight - font.pixelSize) / 2
            bottom: parent.bottom
            right: parent.right
            rightMargin: 5
        }
        color: control.pressed ? control.zpressedColor : control.zcolor
        rotation: down ? 180 : 0
        Behavior on rotation {
            NumberAnimation { duration: 100 }
        }
    }

    contentItem: ZText {
        leftPadding: 5
        rightPadding: control.indicator.width + control.spacing

        text: control.displayText
        font.bold: false
        color: control.pressed ? control.zpressedColor : control.zcolor
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: ZTheme.comboBoxWidth
        implicitHeight: ZTheme.comboBoxHeight
        border.color: control.pressed ? control.zpressedColor : control.zcolor;
        border.width: control.visualFocus ? 2 : 1
        radius: ZTheme.radius
    }

    popup: Popup {
        y: control.height - 1
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            border.color: control.zcolor
            radius: ZTheme.radius
        }
    }
}
