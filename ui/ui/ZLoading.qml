import QtQuick 2.10
import QtQuick.Controls 2.3

ZLayer {
    property alias zautoChangeColor: canvas.autoChangeColor
    property alias zcircleColor: canvas.color
    property alias ztitleText: titleText.text

    Rectangle {
        id: process
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: "#00000000"
        width: 40
        height: 40

        Canvas {
            id: canvas
            property real spinnerWidth: 3

            property bool autoChangeColor: true

            property color color: "#fafafa"

            anchors.fill: parent

            renderStrategy: Canvas.Threaded
            antialiasing: true
            onPaint: drawSpinner();

            opacity:  visible ? 1.0 : 0

            Behavior on opacity {
                PropertyAnimation {
                    duration: 800
                }
            }

            Connections {
                target: canvas
                onColorChanged: canvas.requestPaint()
                onSpinnerWidthChanged: canvas.requestPaint()
            }

            QtObject {
                id: internal

                property real arcEndPoint: 0
                onArcEndPointChanged: canvas.requestPaint();

                property real arcStartPoint: 0
                onArcStartPointChanged: canvas.requestPaint();

                property real rotate: 0
                onRotateChanged: canvas.requestPaint();

                property real longDash: 3 * Math.PI / 2
                property real shortDash: 19 * Math.PI / 10
            }

            NumberAnimation {
                target: internal
                properties: "rotate"
                from: 0
                to: 2 * Math.PI
                loops: Animation.Infinite
                running: canvas.visible
                easing.type: Easing.Linear
                duration: 3000
            }

            SequentialAnimation {
                running: canvas.visible
                loops: Animation.Infinite

                ParallelAnimation {
                    NumberAnimation {
                        target: internal
                        properties: "arcEndPoint"
                        from: 0
                        to: internal.longDash
                        easing.type: Easing.InOutCubic
                        duration: 800
                    }

                    NumberAnimation {
                        target: internal
                        properties: "arcStartPoint"
                        from: internal.shortDash
                        to: 2 * Math.PI - 0.001
                        easing.type: Easing.InOutCubic
                        duration: 800
                    }
                }

                ParallelAnimation {
                    NumberAnimation {
                        target: internal
                        properties: "arcEndPoint"
                        from: internal.longDash
                        to: 2 * Math.PI - 0.001
                        easing.type: Easing.InOutCubic
                        duration: 800
                    }

                    NumberAnimation {
                        target: internal
                        properties: "arcStartPoint"
                        from: 0
                        to: internal.shortDash
                        easing.type: Easing.InOutCubic
                        duration: 800
                    }
                }
            }

            function drawSpinner() {
                var ctx = canvas.getContext("2d");
                ctx.reset();
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                ctx.strokeStyle = canvas.color
                ctx.lineWidth = canvas.spinnerWidth
                ctx.lineCap = "butt";

                ctx.translate(canvas.width / 2, canvas.height / 2);
                ctx.rotate(internal.rotate);

                ctx.arc(0, 0, Math.min(canvas.width, canvas.height) / 2 - ctx.lineWidth,
                        internal.arcStartPoint,
                        internal.arcEndPoint,
                        false);

                ctx.stroke();
            }
        }
        SequentialAnimation {
            running: canvas.autoChangeColor && process.visible
            loops: Animation.Infinite

            ColorAnimation {
                from: "red"
                to: "blue"
                target: canvas
                properties: "color"
                easing.type: Easing.InOutQuad
                duration: 2400
            }

            ColorAnimation {
                from: "blue"
                to: "green"
                target: canvas
                properties: "color"
                easing.type: Easing.InOutQuad
                duration: 1560
            }

            ColorAnimation {
                from: "green"
                to: "#FFCC00"
                target: canvas
                properties: "color"
                easing.type: Easing.InOutQuad
                duration:  840
            }

            ColorAnimation {
                from: "#FFCC00"
                to: "red"
                target: canvas
                properties: "color"
                easing.type: Easing.InOutQuad
                duration:  1000
            }
        }
    }
    ZText{
        id: titleText
        anchors{
            top: process.bottom
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
        text: "正在加载请稍后"
    }
}
