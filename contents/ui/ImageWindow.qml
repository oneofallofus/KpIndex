import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: imageWindow
    property string imageSource
    visible: true
    width: 480
    height: 480
    color: "black" // Set the window background color to black
    flags: Qt.FramelessWindowHint // Make the window frameless

    // Close button text
    Rectangle {
        width: parent.width
        height: 40
        color: "black"
        anchors.top: parent.top

        Text {
            text: "Close window"
            anchors.centerIn: parent
            font.pixelSize: 20 // Increase font size
            font.bold: true // Make the font bold
            color: "#c8c8c8"
            MouseArea {
                cursorShape: Qt.PointingHandCursor // Change cursor to a hand when hovering over the text
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.color = "white" // Change the color on hover for a visual effect
                onExited: parent.color = "#c8c8c8" // Revert the color when the mouse exits
                onClicked: imageWindow.close()
            }
        }
    }

    Image {
        source: imageSource
        anchors.top: parent.top
        anchors.topMargin: 40 // Start 40 pixels from the top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40 // Add a bottom margin of 40 pixels
        fillMode: Image.PreserveAspectFit
    }

    // Link to KpIndex information
    Text {
        text: "What is KpIndex?"
        font.pixelSize: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10 // Adjust margin as needed
        anchors.horizontalCenter: parent.horizontalCenter

        color: "#c8c8c8"
        MouseArea {
            cursorShape: Qt.PointingHandCursor // Change cursor to a hand when hovering over the text
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.color = "white" // Change the color on hover for a visual effect
            onExited: parent.color = "#c8c8c8" // Revert the color when the mouse exits
            onClicked: {
                Qt.openUrlExternally("https://www.swpc.noaa.gov/products/planetary-k-index")
            }
        }
    }
}
