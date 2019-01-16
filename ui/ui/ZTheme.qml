pragma Singleton
import QtQuick 2.11

QtObject {
    property color primaryColor: "#2B579A"
    property string accentColor: "#448aff"
    property string fontFamily: "微软雅黑"
    property int fontPixelSize: 12
    property bool dark: false

    // 边角弧度
    property real radius: 0

    // 按钮宽/高
    property real buttonHeight: 30
    property real buttonWidth: 80

    // 下拉框宽/高
    property real comboBoxHeight: 30
    property real comboBoxWidth: 90

    // 滑块把手宽度
    property real sliderHandleWidth: 20

    // 进度条高度
    property real progressBarHeight: 6
}
