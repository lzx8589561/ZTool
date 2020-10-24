import QtQuick 2.10
import QtQuick.Controls 2.3

Text {
    text: ""
    font.pixelSize: styles[style].size
    font.family: ZTheme.fontFamily
    font.bold: styles[style].bold
    property string style: "body"

    property var styles: {
        "h1" :{
            "size": 20,
            "bold": false
        },
        "h2":{
            "size": 16,
            "bold": false
        },
        "h3":{
            "size": 12,
            "bold": false
        },
        "body":{
            "size": ZTheme.fontPixelSize,
            "bold": false
        },
        "title":{
            "size": 12,
            "bold": true
        }
    }
}
