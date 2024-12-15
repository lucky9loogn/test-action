import Qt.labs.platform
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import BleHelper
import FluentUI

FluWindow {
    id: window
    title: qsTr("BLE Helper")
    width: 300
    height: 400
    fixSize: true
    showMinimize: false

    Component.onCompleted: {
        window.stayTop = true;
    }

    FluImage {
        width: 240
        height: 240
        sourceSize: Qt.size(480, 480)
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
        }
        source: "qrc:/resources/images/ic_crash.png"
    }

    FluText {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 24
            rightMargin: 24
            topMargin: 232
        }
        wrapMode: Text.WordWrap
        elide: Text.ElideNone
        text: qsTr("Sorry for the trouble! The application ran into a problem and needs to restart.")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    ColumnLayout {
        spacing: 12
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: 24
            leftMargin: 24
            rightMargin: 24
        }

        FluFilledButton {
            Layout.fillWidth: true
            text: qsTr("Restart")
            onClicked: {
                FluRouter.exit(931);
            }
        }

        FluButton {
            Layout.fillWidth: true
            text: qsTr("Close")
            onClicked: {
                FluRouter.exit();
            }
        }
    }
}
